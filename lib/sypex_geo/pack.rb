module SypexGeo
  module Pack
    def self.parse(pack, data)
      result = {}
      pos = 0

      pack.split('/').each do |p|
        type, name = p.split(':')

        if data.nil? or data.empty?
          val = type[0] =~ /b|c/ ? '' : 0
        else
          if type[0] == 'b'
            len = data.index("\0", pos) - pos + 1
            val = data[pos, len - 1].force_encoding('UTF-8')
          else
            len = type_length(type)
            val = unpack(type, data[pos, len])
            val = val[0] if val.is_a?(Array)
          end

          pos += len
        end

        result[name.to_sym] = val
      end

      result
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
