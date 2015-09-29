[![Gem Version](https://badge.fury.io/rb/sypex_geo.svg)](http://badge.fury.io/rb/sypex_geo)
[![Build Status](https://travis-ci.org/kolesnikovde/sypex_geo.svg?branch=master)](https://travis-ci.org/kolesnikovde/sypex_geo)
[![Code Climate](https://codeclimate.com/github/kolesnikovde/sypex_geo/badges/gpa.svg)](https://codeclimate.com/github/kolesnikovde/sypex_geo)
[![Test Coverage](https://codeclimate.com/github/kolesnikovde/sypex_geo/badges/coverage.svg)](https://codeclimate.com/github/kolesnikovde/sypex_geo)

# SypexGeo

[Sypex Geo IP database](http://sypexgeo.net) adapter for Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'sypex_geo'

And then execute:

    $ bundle

## Usage

```ruby
require 'sypex_geo'

db = SypexGeo::Database.new('./SxGeoCity.dat')
location = db.query('<IPv4 address>')

location.city
# => {
#   id: 524901,
#   lat: 55.75222,
#   lon: 37.61556,
#   name_ru: 'Москва',
#   name_en: 'Moscow'
# }

location.region
# => {
#   id: 524894,
#   iso: 'RU-MOW',
#   name_ru: 'Москва',
#   name_en: 'Moskva'
# }

location.country
# => {
#   id: 185,
#   iso: 'RU',
#   lat: 60.0,
#   lon: 100.0,
#   name_ru: 'Россия',
#   name_en: 'Russia'
# }

location.country_code
# => 'RU'
```

## Testing

```sh
$ wget http://sypexgeo.net/files/SxGeoCountry.zip && unzip SxGeoCountry.zip
$ wget http://sypexgeo.net/files/SxGeoCity_utf8.zip && unzip SxGeoCity_utf8.zip
$ SXGEO_DB=./SxGeo.dat SXGEO_CITY_DB=./SxGeoCity.dat rspec
```

## License

MIT
