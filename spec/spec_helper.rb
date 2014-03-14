require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'vcr'
require 'pry'
require 'fsatolives'
require 'fakefs/spec_helpers'


VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = { :record => :all }
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = "random"
end