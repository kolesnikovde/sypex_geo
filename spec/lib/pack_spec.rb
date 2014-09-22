require 'spec_helper'
require 'sypex_geo'

describe SypexGeo::Pack do
  describe '#parse' do
    it 'reads int8' do
      expect(SypexGeo::Pack.new('t:value').parse("\xff")[:value]).to eq(-1)
    end

    it 'reads uint8' do
      expect(SypexGeo::Pack.new('T:value').parse("\xff")[:value]).to eq(255)
    end

    it 'reads int16' do
      expect(SypexGeo::Pack.new('s:value').parse("\xff\xff")[:value]).to eq(-1)
    end

    it 'reads uint16' do
      expect(SypexGeo::Pack.new('S:value').parse("\xff\xff")[:value]).to eq(65535)
    end

    it 'reads int24' do
      expect(SypexGeo::Pack.new('m:value').parse("\xff\xff\xff")[:value]).to eq(-1)
    end

    it 'reads uint24' do
      expect(SypexGeo::Pack.new('M:value').parse("\xff\xff\xff")[:value]).to eq(16777215)
    end

    it 'reads int32' do
      expect(SypexGeo::Pack.new('i:value').parse("\xff\xff\xff\xff")[:value]).to eq(-1)
    end

    it 'reads uint32' do
      expect(SypexGeo::Pack.new('I:value').parse("\xff\x00\x00\x00")[:value]).to eq(255)
    end

    it 'reads float' do
      expect(SypexGeo::Pack.new('f:value').parse("\x85\xEBUA")[:value].round(2)).to eq(13.37)
    end

    it 'reads double' do
      expect(SypexGeo::Pack.new('d:value').parse("\xF6(\\\x8F\xC25E@")[:value].round(2)).to eq(42.42)
    end

    it 'reads decimal16' do
      expect(SypexGeo::Pack.new('n2:value').parse("\x00\xff")[:value]).to eq(-2.56)
    end

    it 'reads decimal32' do
      expect(SypexGeo::Pack.new('N2:value').parse("\xff\x00\xff\x00")[:value]).to eq(167119.35)
    end

    it 'reads chars' do
      parsed = SypexGeo::Pack.new('c3:val1/c3:val2').parse('foobar')

      expect(parsed[:val1]).to eq('foo')
      expect(parsed[:val2]).to eq('bar')
    end

    it 'reads blob' do
      parsed = SypexGeo::Pack.new('b:val1/b:val2').parse("foo\0bar\0")

      expect(parsed[:val1]).to eq('foo')
      expect(parsed[:val2]).to eq('bar')
    end
  end
end
