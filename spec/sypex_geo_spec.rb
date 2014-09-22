# coding: utf-8

require './spec/spec_helper'
require 'sypex_geo'
require 'ipaddr'

describe SypexGeo do
  let(:demo_ip) do
    # Random Moscow IP.
    '80.90.64.1'
  end

  let(:invalid_db_file) do
    File.expand_path(__FILE__ + '/../support/invalid.dat')
  end

  shared_examples 'geo db' do
    describe '#initialize' do
      it 'raises error if database is invalid' do
        expect do
          described_class.new(invalid_db_file)
        end.to raise_error(SypexGeo::DatabaseError)
      end
    end

    describe '#query' do
      it 'returns nil if IP address is reserved' do
        expect(subject.query('0.0.0.0')).to be_nil
        expect(subject.query('127.0.0.0')).to be_nil
        expect(subject.query('224.0.0.0')).to be_nil
        expect(subject.query('255.0.0.0')).to be_nil
      end

      it 'raises error if IP address is invalid' do
        error = if IPAddr.const_defined?('InvalidAddressError')
                  IPAddr::InvalidAddressError
                else
                  ArgumentError
                end

        expect do
          subject.query('1.invalid')
        end.to raise_error(error)
      end
    end
  end

  shared_examples 'city db' do
    it_behaves_like 'geo db'

    let(:city_info) do
      {
        id: 524901,
        country_id: 185,
        lat: 55.75222,
        lon: 37.61556,
        name_ru: 'Москва',
        name_en: 'Moscow',
        region_seek: 11795
      }
    end

    let(:region_info) do
      {
        id: 524894,
        iso: 'RU-MOW',
        name_ru: 'Москва',
        name_en: 'Moskva',
        country_seek: 9128
      }
    end

    let(:country_info) do
      {
        id: 185,
        iso: 'RU',
        lat: 60.0,
        lon: 100.0,
        name_ru: 'Россия',
        name_en: 'Russia'
      }
    end

    let(:country_code) do
      'RU'
    end

    it { should be_city }
    it { should_not be_country }

    describe '#query' do
      it 'returns location info' do
        location = subject.query(demo_ip)

        expect(location.city).to eq(city_info)
        expect(location.region).to eq(region_info)
        expect(location.country).to eq(country_info)
        expect(location.country_code).to eq(country_code)
      end
    end
  end

  shared_examples 'country db' do
    it_behaves_like 'geo db'

    let(:country_code) do
      'RU'
    end

    it { should be_country }
    it { should_not be_city }

    describe '#query' do
      it 'returns country code' do
        expect(subject.query(demo_ip).country_code).to eq(country_code)
      end
    end
  end

  describe SypexGeo::Database do
    if ENV['SXGEO_CITY_DB']
      context 'city db' do
        subject { SypexGeo::Database.new(ENV['SXGEO_CITY_DB']) }

        it_behaves_like 'city db'
      end
    end

    if ENV['SXGEO_DB']
      context 'country db' do
        subject { SypexGeo::Database.new(ENV['SXGEO_DB']) }

        it_behaves_like 'country db'
      end
    end
  end
end
