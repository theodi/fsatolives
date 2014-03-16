$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'import'
require 'fsatolives'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :import do
  Import.perform
end

task :create do
  if ENV['id']
    FsaToLives.perform(ENV['id'])
  else
    p "Please enter an ID eg: `rake create id=1`"
  end
end

task :list_authorities do 
  authorities = FsaToLives.authorities
  authorities.sort_by! { |a| a['Name'] }
  authorities.each {|a| puts "#{a['Name']} - #{a['LocalAuthorityId']}" }
end