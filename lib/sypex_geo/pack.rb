module SypexGeo
  class Pack
    def initialize(pack)
      @pack = pack
    end

    def parse(data)
      @data = data
      @pos = 0
      result = {}

      @pack.split('/').each do |part|
        chunk, name = part.split(':')
        result[name.to_sym] = parse_chunk(chunk)
      end

      result
    end

    protected

    def parse_chunk(chunk)
      case chunk[0]
      when 't' then read_int8(chunk)
      when 'T' then read_uint8(chunk)
      when 's' then read_int16(chunk)
      when 'S' then read_uint16(chunk)
      when 'm' then read_int24(chunk)
      when 'M' then read_uint24(chunk)
      when 'i' then read_int32(chunk)
      when 'I' then read_uint32(chunk)
      when 'f' then read_float(chunk)
      when 'd' then read_double(chunk)
      when 'n' then read_decimal16(chunk)
      when 'N' then read_decimal32(chunk)
      when 'c' then read_chars(chunk)
      when 'b' then read_blob(chunk)
      end
    end

    def read(len)
      @pos += len
      @data[@pos - len, len]
    end

    def read_string(len)
      read(len).strip.force_encoding('UTF-8')
    end

    def read_int8(chunk)
      read(1).unpack('c')[0]
    end

    def read_uint8(chunk)
      read(1).unpack('C')[0]
    end

    def read_int16(chunk)
      read(2).unpack('s')[0]
    end

    def read_uint16(chunk)
      read(2).unpack('S')[0]
    end

    def read_int24(chunk)
      raw = read(3)
      raw = raw + (raw[2].ord >> 7) > 0 ? "\xFF" : "\0"
      raw.unpack('l')[0]
    end

    def read_uint24(chunk)
      (read(3) + "\0").unpack('L')[0]
    end

    def read_int32(chunk)
      read(4).unpack('l')[0]
    end

    def read_uint32(chunk)
      read(4).unpack('L')[0]
    end

    def read_float(chunk)
      read(4).unpack('f')[0]
    end

    def read_double(chunk)
      read(8).unpack('d')[0]
    end

    def read_decimal16(chunk)
      read(2).unpack('s')[0].to_f / (10 ** chunk[1].to_i)
    end

    def read_decimal32(chunk)
      read(4).unpack('l')[0].to_f / (10 ** chunk[1].to_i)
    end

    def read_chars(chunk)
      read_string(chunk[1..-1].to_i)
    end

    def read_blob(chunk)
      read_string(@data.index("\0", @pos) - @pos + 1)
    end
  end
end
