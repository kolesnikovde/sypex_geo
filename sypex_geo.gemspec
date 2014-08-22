lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sypex_geo/version'

Gem::Specification.new do |spec|
  spec.name          = 'sypex_geo'
  spec.version       = SypexGeo::VERSION
  spec.authors       = ['Kolesnikov Danil']
  spec.email         = ['kolesnikovde@gmail.com']
  spec.summary       = 'Sypex Geo IP database adapter for Ruby.'
  spec.description   = 'Sypex Geo IP database adapter for Ruby.'
  spec.homepage      = 'https://github.com/kolesnikovde/sypex_geo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~> 3'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
