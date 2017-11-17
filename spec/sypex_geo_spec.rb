# coding: utf-8

require 'spec_helper'
require 'sypex_geo'
require 'ipaddr'

describe SypexGeo do
  shared_examples 'geo db' do
    let(:invalid_db_file) do
      File.expand_path(__FILE__ + '/../support/invalid.dat')
    end

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

    describe '#inspect' do
      it 'does not dump whole db' do
        expect(subject.inspect).to eq(subject.to_s)
      end
    end
  end

  shared_examples 'city db' do
    it_behaves_like 'geo db'

    let(:demo_ip) do
      # Random Moscow IP.
      '80.90.64.1'
    end

    let(:city_info) do
      {
        id: 524901,
        country_id: 185,
        lat: 55.75222,
        lon: 37.61556,
        name_ru: 'Москва',
        name_en: 'Moscow'
      }
    end

    let(:region_info) do
      {
        id: 524894,
        iso: 'RU-MOW',
        name_ru: 'Москва',
        name_en: 'Moskva'
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

        city = location.city
        region = location.region
        country = location.country
        code = location.country_code

        city.delete(:region_seek)
        region.delete(:country_seek)

        expect(city).to eq(city_info)
        expect(region).to eq(region_info)
        expect(country).to eq(country_info)
        expect(code).to eq(country_code)
      end

      it 'returns same results for same IP' do
        location_a = subject.query(demo_ip)
        location_b = subject.query(demo_ip)

        expect(location_a.city[:name_en]).to eq(location_b.city[:name_en])
      end

      context 'random ip results ' do
        %w(51.187.93.98
           195.250.51.10
           71.138.87.212
           69.180.167.139
           33.217.182.174
           106.116.216.250
           177.220.41.166
           128.53.65.28
           44.230.230.185
           22.45.239.43).each do |ip|

           context ip do

            let(:result) { subject.query(ip).city }

            it "should have valid lat and lon" do
              expect(result[:lon]).to be_within(180).of(0)
              expect(result[:lat]).to be_within(90).of(0)
            end

            it "should have latin name_en" do
              expect(result[:name_en]).to match(/^[\p{Punct}\p{Space}\p{Latin}]*$/i)
            end

            it "should have cyrillic name_ru" do
              expect(result[:name_ru]).to match(/^[\p{Punct}\p{Cyrillic}\p{Latin}]*$/i)
            end

          end
        end
      end

      context 'return nil if ip not present' do
        let(:ip) { '78.172.97.26' }

        it 'should return nil for city' do
          expect(subject.query(ip).city).to eq(nil)
        end

        it 'should return nil for country' do
          expect(subject.query(ip).country).to eq(nil)
        end

        it 'should return nil for region' do
          expect(subject.query(ip).region).to eq(nil)
        end

        it 'should return nil for country code' do
          expect(subject.query(ip).country_code).to eq(nil)
        end
      end
    end
  end

  shared_examples 'country db' do
    it_behaves_like 'geo db'

    let(:demo_ip) do
      # Google Public DNS.
      '8.8.8.8'
    end

    let(:country_code) do
      'US'
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
