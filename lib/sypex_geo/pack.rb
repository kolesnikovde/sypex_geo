module SypexGeo
  class Pack
    def initialize(fmt)
      compile(fmt)
    end

    def parse(data)
      Hash[@keys.zip(process(data.unpack(@format)))]
    end

    protected

    def compile(fmt)
      @keys = []
      @format = ''
      @processors = []

      fmt.split('/').each do |part|
        chunk, key = part.split(':')
        format, processor = chunk_parser(chunk)

        @keys       << key.to_sym
        @format     << format
        @processors << processor
      end
    end

    def process(raw_values)
      raw_values.each_with_index.map do |val, i|
        if processor = @processors[i]
          processor.call(val)
        else
          val
        end
      end
    end

    def chunk_parser(chunk)
      case chunk[0]
      when 't' then [ 'c' ]
      when 'T' then [ 'C' ]
      when 's' then [ 's' ]
      when 'S' then [ 'S' ]
      when 'm' then [ 'a3', ->(val){ parse_int24(val) } ]
      when 'M' then [ 'a3', ->(val){ parse_uint24(val) } ]
      when 'i' then [ 'l' ]
      when 'I' then [ 'L' ]
      when 'f' then [ 'f' ]
      when 'd' then [ 'D' ]
      when 'n' then [ 'a2', ->(val){ parse_decimal(val, 's', chunk[1]) } ]
      when 'N' then [ 'a4', ->(val){ parse_decimal(val, 'l', chunk[1]) } ]
      when 'c' then [ 'a' + chunk[1], ->(val){ parse_string(val) } ]
      when 'b' then [ 'Z*', ->(val){ parse_string(val) } ]
      end
    end

    def parse_int24(val)
      val += (val[2].ord >> 7 > 0 ? "\xFF" : "\x00").force_encoding('BINARY')
      val.unpack('l')[0]
    end

    def parse_uint24(val)
      (val + "\x00").unpack('L')[0]
    end

    def parse_decimal(val, format, fract)
      val.unpack(format)[0].to_f / (10 ** fract.to_i)
    end

    def parse_string(val)
      val.strip.force_encoding('UTF-8')
    end
  end
end
