$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'fsatolives'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :import do
  FsaToLives.import
end

namespace :create do

  task :by_id do
    if ENV['ids']
      ids = ENV['ids'].split(",")
      FsaToLives.perform(ids)
    else
      p "Please enter the IDs of the authorities that you want to export as a comma seperated list eg: `rake create ids=1,2,4`"
    end
  end
  
  task :all do
    FsaToLives.authorities.each do |authority|
      FsaToLives.perform(authority['LocalAuthorityId'])
    end
  end

end

task :create => 'create:by_id'

task :list_authorities do 
  authorities = FsaToLives.authorities
  authorities.sort_by! { |a| a['Name'] }
  authorities.each {|a| puts "#{a['Name']} - #{a['LocalAuthorityId']}" }
end