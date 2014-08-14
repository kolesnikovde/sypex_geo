# SypexGeo

[Sypex Geo IP database](http://sypexgeo.net) adapter for Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'sypex_geo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sypex_geo

## Usage

    require 'sypex_geo'

    db = SypexGeo::Database.new('./sypex_geo_city_max.dat')
    db.lookup(<IPv4 address>)

    # "memory_mode"
    db = SypexGeo::MemoryDatabase.new('./sypex_geo_city_max.dat')
    db.lookup(<IPv4 address>)

## Testing

    SYPEXGEO_CITY_MAX_DB=./sypexgeo_city_max.dat rspec

## License

Licensed under the MIT License

Copyright (c) 2014 Kolesnikov Danil
