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

db = SypexGeo::Database.new('./sypex_geo_city_max.dat')
db.lookup(<IPv4 address>)
# => {
#   city: {
#     id: 524901,
#     lat: 55,
#     lon: 37,
#     name_ru: 'Москва',
#     name_en: 'Moscow',
#     okato: '45'
#   },
#   country: {
#     id: 185,
#     iso: 'RU'
#   },
#   region: nil
# }

# Query details.
db.lookup(<IPv4 address>, true)
# => {
#   city: {
#     id: 524901,
#     lat: 55,
#     lon: 37,
#     name_ru: 'Москва',
#     name_en: 'Moscow',
#     okato: '45'
#   },
#   region: {
#     id: 524894,
#     name_ru: 'Москва',
#     name_en: 'Moskva',
#     lat: 55,
#     lon: 37,
#     iso: 'RU-MOW',
#     timezone: 'Europe/Moscow',
#     okato: '45'
#   },
#   country: {
#     id: 185,
#     iso: 'RU',
#     continent: 'EU',
#     lat: 60,
#     lon: 100,
#     name_ru: 'Россия',
#     name_en: 'Russia',
#     timezone: 'Europe/Moscow'
#   }
# }

# "memory_mode"
db = SypexGeo::MemoryDatabase.new('./sypex_geo_city_max.dat')
db.lookup(<IPv4 address>)
```

## Testing

    $ SYPEXGEO_CITY_MAX_DB=./sypexgeo_city_max.dat rspec

## License

Copyright (c) 2014 Kolesnikov Danil

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
