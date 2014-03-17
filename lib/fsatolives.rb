$:.unshift File.dirname(__FILE__)

require 'open-uri'
require 'json'
require 'date'
require 'csv'
require 'zip'
require 'active_support/core_ext/hash'
require 'db/towns'
require 'db/counties'
require 'fsatolives/authorities'
require 'fsatolives/generators'
require 'fsatolives/helpers'
require 'fsatolives/import'

class FsaToLives
  
  def self.perform(ids)
    ids.each do |id|
      create_zip(id)
    end
  end
  
  def self.create_zip(id)
    authority = get_authority(id)
    inspections = get_inspections(authority['FileName'])
    zip_files(id, {
        "businesses" => to_csv(businesses(inspections)),
        "inspections" => to_csv(inspections(inspections)),
        "feed_info" => to_csv(feed_info(authority))
      })
  end
  
  def self.get_inspections(url)
    response = open(url).read
    inspections = Hash.from_xml(response)
    inspections['FHRSEstablishment']['EstablishmentCollection']['EstablishmentDetail']
  end
  
  def self.to_csv(array)
    file = Tempfile.new('fsa_to_lives')
    CSV.open(file, "w") do |csv|
      array.each { |row| csv << row }
    end
    file
  end
  
  def self.zip_files(id, files)
    Zip::File.open("lives-#{id}-#{Date.today.to_s}.zip", Zip::File::CREATE) do |zipfile|
      files.each do |filename, tempfile|
        zipfile.add("#{filename}.csv", tempfile)
      end
    end
  end
  
end