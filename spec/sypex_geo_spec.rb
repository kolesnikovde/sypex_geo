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

  let(:country_db_file) do
    ENV['SXGEO_DB']
  end

  let(:city_db_file) do
    ENV['SXGEO_CITY_DB']
  end

  let(:country_info) do
    {
      city: nil,
      country: {
        id: 185,
        iso: 'RU'
      },
      region: nil
    }
  end

  let(:city_info) do
    {
      city: {
        id: 524901,
        lat: 55,
        lon: 37,
        name_ru: 'Москва',
        name_en: 'Moscow'
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
        name_en: 'Moscow'
      },
      region: {
        id: 524894,
        name_ru: 'Москва',
        name_en: 'Moskva',
        iso: 'RU-MOW'
      },
      country: {
        id: 185,
        iso: 'RU',
        lat: 60,
        lon: 100,
        name_ru: 'Россия',
        name_en: 'Russia'
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

      it 'raises error if IP address is invalid' do
        error = if IPAddr.const_defined?('InvalidAddressError')
                  IPAddr::InvalidAddressError
                else
                  ArgumentError
                end

        expect do
          subject.lookup('1.invalid')
        end.to raise_error(error)
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
    describe 'city db' do
      subject(:db) { SypexGeo::Database.new(city_db_file) }

      it_behaves_like 'geoip_database'
    end

    describe 'country db' do
      subject(:db) { SypexGeo::Database.new(country_db_file) }

      it 'returns country code' do
        expect(subject.lookup(demo_ip)).to eq(country_info)
      end
    end
  end
end
