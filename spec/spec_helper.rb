ENV["MONGOID_ENVIRONMENT"] = "test"

require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'vcr'
require 'pry'
require 'fsatolives'
require 'fakefs/safe'
require 'timecop'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = { :record => :once }
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  
  config.before(:each) do
    DatabaseCleaner.clean
    Towns.create(name: "Cambridge")
    Towns.create(name: "Coleshill")
    Towns.create(name: "Birmingham")
    Counties.create(name: "Birmingham")
    Counties.create(name: "Cambridgeshire")
  end
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = "random"
end