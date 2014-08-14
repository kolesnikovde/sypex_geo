if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.order = 'random'
end
