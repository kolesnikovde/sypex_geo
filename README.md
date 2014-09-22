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

    $ SXGEO_DB=./SxGeo.dat SXGEO_CITY_DB=./SxGeoCity.dat rspec

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
