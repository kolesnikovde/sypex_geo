require 'ipaddr'
require 'sypex_geo/version'

module SypexGeo
  TYPE_COUNTRY = 0
  TYPE_REGION  = 1
  TYPE_CITY    = 2

  COUNTRY_CODES = %w[
    AP EU AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AZ BA BB BD BE BF BG
    BH BI BJ BM BN BO BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN
    CO CR CU CV CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM
    FO FR FX GA GB GD GE GF GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN
    HR HT HU ID IE IL IN IO IQ IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW
    KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD MG MH MK ML MM MN MO MP
    MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA
    PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RU RW SA SB SC SD SE SG
    SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC TD TF TG TH TJ TK TM TN TO TL
    TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT RS ZA
    ZM ME ZW A1 A2 O1 AX GG IM JE BL MF
  ]

  class DatabaseError < StandardError
  end

  class Database
    attr_reader :version

    def initialize(path)
      @file = File.open(path, 'rb')

      setup!
    end

    def lookup(ip, full = false)
      if seek = search(ip)
        read_location(seek, full)
      end
    end

    def inspect
      "#<#{self.class}:0x#{object_id} @version=#{@version}>"
    end

    protected

    def setup!
      if header = @file.read(40)
        id, @version, @time, @type, @charset,
        @b_idx_len, @m_idx_len, @range, @db_items, @id_len,
        @max_region, @max_city, @region_size, @city_size,
        @max_country, @country_size,
        @pack_size = header.unpack('a3CNCCCnnNCnnNNnNn')
      end

      raise DatabaseError.new, 'Wrong file format' unless id == 'SxG'

      @pack = @file.read(@pack_size).split("\0")
      @b_idx_arr = @file.read(@b_idx_len * 4).unpack('N*')
      @m_idx_arr = @file.read(@m_idx_len * 4).scan(/.{1,4}/m)

      @block_len = 3 + @id_len
      @db_begin = @file.tell
      @regions_begin = @db_begin + @db_items * @block_len
      @cities_begin = @regions_begin + @region_size
    end

    def search(ip)
      ip1n = ip.to_i

      return if ip1n == 0 or ip1n == 127 or ip1n >= 224

      ipn = IPAddr.new(ip).hton
      blocks_min, blocks_max = @b_idx_arr[ip1n - 1], @b_idx_arr[ip1n]

      if blocks_max - blocks_min > @range
        part = search_idx(ipn, blocks_min / @range, (blocks_max / @range) - 1)
        min = part > 0 ? part * @range : 0
        max = part > @m_idx_len ? @db_items : (part + 1) * @range
        min = blocks_min if min < blocks_min
        max = blocks_max if max > blocks_max
      else
        min = blocks_min
        max = blocks_max
      end

      search_db(ipn, min, max)
    end

    def search_idx(ipn, min, max)
      idx = @m_idx_arr

      while max - min > 8
        offset = (min + max) >> 1

        if ipn > idx[offset]
          min = offset
        else
          max = offset
        end
      end

      while ipn > idx[min]
        break if min >= max
        min += 1
      end

      min
    end

    def search_db(ipn, min, max)
      len = max - min
      @file.pos = @db_begin + min * @block_len
      search_db_chunk(@file.read(len * @block_len), ipn, 0, len - 1)
    end

    def search_db_chunk(data, ipn, min, max)
      block_len = @block_len

      if max - min > 1
        ipn = ipn[1, 3]

        while max - min > 8
          offset = (min + max) >> 1

          if ipn > data[offset * block_len, 3]
            min = offset
          else
            max = offset
          end
        end

        while ipn >= data[min * block_len, 3]
          min += 1
          break if min >= max
        end
      else
        min += 1
      end

      data[min * block_len - @id_len, @id_len].unpack('H*').first.hex
    end

    def read_data(seek, limit, type)
      @file.pos = (type == TYPE_REGION ? @regions_begin : @cities_begin) + seek
      Pack.parse(@pack[type], @file.read(limit))
    end

    def read_country(seek)
      read_data(seek, @max_country, TYPE_COUNTRY)
    end

    def read_region(seek)
      read_data(seek, @max_region, TYPE_REGION)
    end

    def read_city(seek)
      read_data(seek, @max_city, TYPE_CITY)
    end

    def read_location(seek, full = false)
      region = nil
      city = nil
      country = nil

      if seek < @country_size
        country = read_country(seek)
      elsif city = read_city(seek)
        region_seek = city.delete(:region_seek)
        country_id = city.delete(:country_id)
        country = { id: country_id, iso: COUNTRY_CODES[country_id - 1] }
      end

      if full and region_seek
        region = read_region(region_seek)
        country = read_country(region.delete(:country_seek))
      end

      { city: city, region: region, country: country }
    end
  end

  class MemoryDatabase < Database
    def setup!
      super

      @db = @file.read(@db_items * @block_len)
      @regions_db = @file.read(@region_size) if @region_size > 0
      @cities_db = @file.read(@city_size) if @city_size > 0
    end

    def search_db(ipn, min, max)
      search_db_chunk(@db, ipn, min, max)
    end

    def read_data(seek, limit, type)
      raw = (type == TYPE_REGION ? @regions_db : @cities_db)[seek, limit]
      Pack.parse(@pack[type], raw)
    end
  end

  module Pack
    def self.parse(pack, data)
      result = {}
      pos = 0

      pack.split('/').each do |p|
        type, name = p.split(':')

        if data.nil? or data.empty?
          result[name] = type[0] =~ /b|c/ ? '' : 0
        else
          if type[0] == 'b'
            len = data.index("\0", pos) - pos
            val = data[pos, len].force_encoding('UTF-8')
            len += 1
          else
            len = type_length(type)
            val = unpack(type, data[pos, len])
          end

          result[name] = val.is_a?(Array) ? val[0] : val
          pos += len
        end
      end

      Hash[result.map{ |k, v| [ k.to_sym, v ] }]
    end

    protected

    def self.type_length(type)
      case type[0]
      when /t|T/   then 1
      when /s|S|n/ then 2
      when /m|M/   then 3
      when 'd'     then 8
      when 'c'     then type[1..-1].to_i
      else 4
      end
    end

    def self.unpack(type, val)
      case type[0]
      when 't' then val.unpack('c')
      when 'T' then val.unpack('C')
      when 's' then val.unpack('s')
      when 'S' then val.unpack('S')
      when 'm' then (val + (val[2].ord >> 7) > 0 ? "\xFF" : "\0").unpack('l')
      when 'M' then (val + "\0").unpack('L')
      when 'i' then val.unpack('l')
      when 'I' then val.unpack('L')
      when 'f' then val.unpack('f')
      when 'd' then val.unpack('d')
      when 'n' then val.unpack('s')[0] / (10 ** type[1].to_i)
      when 'N' then val.unpack('l')[0] / (10 ** type[1].to_i)
      when 'c' then val.rstrip
      end
    end
  end
end
