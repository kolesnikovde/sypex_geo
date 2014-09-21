require 'ipaddr'

module SypexGeo
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
      @db = @file.read(@db_items * @block_len)
      @regions_db = @file.read(@region_size) if @region_size > 0
      @cities_db = @file.read(@city_size) if @city_size > 0
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
      data = @db
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
      raw = (type == TYPE_REGION ? @regions_db : @cities_db)[seek, limit]
      Pack.parse(@pack[type], raw)
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

      if @country_size == 0
        country = { id: seek, iso: COUNTRY_CODES[seek - 1] }
      else
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
      end

      { city: city, region: region, country: country }
    end
  end
end
