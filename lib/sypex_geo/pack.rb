module SypexGeo
  class Pack
    def initialize(pack)
      setup_pack(pack)
    end

    def parse(data)
      Hash[@keys.zip(process(data.unpack(@format)))]
    end

    protected

    def setup_pack(pack)
      @keys = []
      @format = ''
      @processors = []

      pack.split('/').each do |part|
        chunk, key = part.split(':')
        parser = chunk_parser(chunk)

        @keys       << key.to_sym
        @format     << parser.shift
        @processors << (parser.empty? ? nil : parser)
      end
    end

    def process(vals)
      vals.each_with_index.map do |val, i|
        if processor = @processors[i]
          name = processor.shift
          args = processor
          args.unshift(val)
          send(name, *args)
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
      when 'm' then [ 'a3', :parse_int24 ]
      when 'M' then [ 'a3', :parse_uint24 ]
      when 'i' then [ 'l' ]
      when 'I' then [ 'L' ]
      when 'f' then [ 'f' ]
      when 'd' then [ 'D' ]
      when 'n' then [ 'a2', :parse_decimal, 's', chunk[1] ]
      when 'N' then [ 'a4', :parse_decimal, 'l', chunk[1] ]
      when 'c' then [ 'a' + chunk[1], :parse_string ]
      when 'b' then [ 'Z*', :parse_string ]
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
