require 'ipaddr'

module SypexGeo
  class DatabaseError < StandardError
  end

  class Database
    TYPE_COUNTRY = 1
    TYPE_CITY    = 3

    attr_reader :version, :time

    def initialize(path)
      @file = File.open(path, 'rb')

      parse_header
      setup
    end

    def query(ip)
      if position = search(ip)
        Result.new(position, self)
      end
    end

    def read_country(position)
      country_parser.parse(@cities_db[position, @country_size])
    end

    def read_region(position)
      region_parser.parse(@regions_db[position, @region_size])
    end

    def read_city(position)
      if position > @countries_db_size
        city_parser.parse(@cities_db[position, @city_size])
      else
        country = country_parser.parse(@cities_db[position, @country_size])
        city_parser.parse('').tap do |city|
          city[:lat] = country[:lat]
          city[:lon] = country[:lon]
          city[:country_id] = country[:id]
        end
      end
    end

    def country?
      @type == TYPE_COUNTRY
    end

    def city?
      @type == TYPE_CITY
    end

    def inspect
      to_s
    end

    protected

    def parse_header
      if header = @file.read(40)
        id, @version, @time, @type, @charset,
        @block_idx_size, @main_idx_size, @range, @db_records_count, @id_size,
        @region_size, @city_size, @regions_db_size, @cities_db_size,
        @country_size, @countries_db_size,
        @pack_size = header.unpack('a3CNCCCnnNCnnNNnNn')
      end

      raise DatabaseError.new, 'Wrong file format' unless id == 'SxG'
    end

    def setup
      @pack = @file.read(@pack_size).split("\0")
      @country_pack, @region_pack, @city_pack = @pack

      @block_idx = @file.read(@block_idx_size * 4).unpack('N*')
      @main_idx = @file.read(@main_idx_size * 4).scan(/.{1,4}/m)

      @db_record_size = 3 + @id_size
      @db = @file.read(@db_records_count * @db_record_size)
      @regions_db = @file.read(@regions_db_size) if @regions_db_size > 0
      @cities_db = @file.read(@cities_db_size) if @cities_db_size > 0
    end

    def search(ip)
      octet = ip.to_i
      return if octet == 0 or octet == 127 or octet >= @block_idx_size

      min, max = @block_idx[octet - 1], @block_idx[octet]
      range = @range
      ipn = IPAddr.new(ip).hton

      if max - min > range
        part = main_idx_search(ipn, min / range, (max / range) - 1)
        min = part > 0 ? part * range : 0
        max = part > @main_idx_size ? @db_records_count : (part + 1 ) * range
        min = @block_idx[octet - 1] if min < @block_idx[octet - 1]
        max = @block_idx[octet] if max > @block_idx[octet - 1]
      end

      db_search(ipn, min, max)
    end

    def main_idx_search(ipn, min, max)
      idx = @main_idx

      while max - min > 8
        mid = (min + max) / 2

        if ipn > idx[mid]
          min = mid
        else
          max = mid
        end
      end

      begin
        min += 1
      end while (ipn > idx[min]) && (min <= max)

      min
    end

    def db_search(ipn, min, max)
      db = @db
      db_record_size = @db_record_size
      octets = ipn[1, 3]

      while min < max
        mid = (min + max) / 2

        if octets > db[mid * db_record_size, 3]
          min = mid + 1
        else
          max = mid
        end
      end

      db[min * db_record_size - @id_size, @id_size].unpack('H*')[0].hex
    end

    def country_parser
      @country_parser ||= Pack.new(@country_pack)
    end

    def city_parser
      @city_parser ||= Pack.new(@city_pack)
    end

    def region_parser
      @region_parser ||= Pack.new(@region_pack)
    end
  end
end
