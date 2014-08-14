require 'sypex_geo'

describe SypexGeo do
  let(:demo_ip) do
    # Random Moscow IP.
    '80.90.64.1'
  end

  let(:default_db_file) do
    File.expand_path(__FILE__ + '/../support/sypexgeo_city_max.dat')
  end

  let(:invalid_db_file) do
    File.expand_path(__FILE__ + '/../support/invalid.dat')
  end

  let(:db_file) do
    ENV['SYPEXGEO_CITY_MAX_DB'] || default_db_file
  end

  let(:city_info) do
    {
      city: {
        id: 524901,
        lat: 55,
        lon: 37,
        name_ru: 'Москва',
        name_en: 'Moscow',
        okato: '45'
      },
      country: {
        id: 185,
        iso: 'RU'
      },
      region: nil
    }
  end

  let(:location_info) do
    {
      city: {
        id: 524901,
        lat: 55,
        lon: 37,
        name_ru: 'Москва',
        name_en: 'Moscow',
        okato: '45'
      },
      region: {
        id: 524894,
        name_ru: 'Москва',
        name_en: 'Moskva',
        lat: 55,
        lon: 37,
        iso: 'RU-MOW',
        timezone: 'Europe/Moscow',
        okato: '45'
      },
      country: {
        id: 185,
        iso: 'RU',
        continent: 'EU',
        lat: 60,
        lon: 100,
        name_ru: 'Россия',
        name_en: 'Russia',
        timezone: 'Europe/Moscow'
      }
    }
  end

  shared_examples 'geoip_database' do
    describe '#initialize' do
      it 'raises error if database is invalid' do
        expect do
          subject.class.new(invalid_db_file)
        end.to raise_error(SypexGeo::DatabaseError)
      end
    end

    describe '#lookup' do
      it 'returns nil if IP address is reserved' do
        expect(subject.lookup('0.0.0.0')).to be_nil
        expect(subject.lookup('127.0.0.0')).to be_nil
        expect(subject.lookup('224.0.0.0')).to be_nil
        expect(subject.lookup('255.0.0.0')).to be_nil
      end

      it 'raises IPAddr::InvalidAddressError if IP address is invalid' do
        expect do
          subject.lookup('1.invalid')
        end.to raise_error(IPAddr::InvalidAddressError)
      end

      it 'returns city info' do
        expect(subject.lookup(demo_ip)).to eq(city_info)
      end

      it 'returns detailed location info if specified' do
        expect(subject.lookup(demo_ip, true)).to eq(location_info)
      end
    end
  end

  describe SypexGeo::Database do
    subject(:db) { SypexGeo::Database.new(db_file) }

    it_behaves_like 'geoip_database'
  end

  describe SypexGeo::MemoryDatabase do
    subject(:db) { SypexGeo::MemoryDatabase.new(db_file) }

    it_behaves_like 'geoip_database'
  end
end
