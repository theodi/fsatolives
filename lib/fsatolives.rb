$:.unshift File.dirname(__FILE__)

require 'open-uri'
require 'json'
require 'date'
require 'csv'
require 'zip'
require 'active_support/core_ext/hash'
require 'db/towns'
require 'db/counties'

class FsaToLives
  
  def self.perform(id)
    authority = get_authority(id)
    inspections = get_inspections(authority['FileName'])
    zip_files(id, {
        "businesses" => to_csv(businesses(inspections)),
        "inspections" => to_csv(inspections(inspections)),
        "feed_info" => to_csv(feed_info(authority))
      })
  end
  
  def self.get_authority(id)
    url = "http://api.ratings.food.gov.uk/Authorities/#{id}"
    JSON.parse(open(url, "x-api-version" => "2").read)
  end
  
  def self.authorities
    url = "http://api.ratings.food.gov.uk/Authorities"
    authorities = JSON.parse(open(url, "x-api-version" => "2").read)
    authorities['authorities']
  end
  
  def self.get_inspections(url)
    response = open(url).read
    inspections = Hash.from_xml(response)
    inspections['FHRSEstablishment']['EstablishmentCollection']['EstablishmentDetail']
  end
  
  def self.feed_info(authority)
    rows = []
    rows << [
        'feed_date',
        'feed_version',
        'municipality_name',
        'municipality_url',
        'contact_email'
      ]
    rows << [
        date_format(Date.today.to_s),
        '0.4.1',
        authority['Name'],
        authority['Url'],
        authority['Email']
      ]
  end
  
  def self.businesses(inspections)
    rows = []
    rows << [
      'business_id',
      'name',
      'address',
      'city',
      'state',
      'postal_code',
      'latitude',
      'longitude',
      'phone_number'
    ]
    inspections.each do |inspection|
      lat = inspection['Geocode']['Latitude'] rescue nil
      lng = inspection['Geocode']['Longitude'] rescue nil
      rows << [
        inspection['FHRSID'],
        inspection['BusinessName'],
        parse_address(inspection),
        fetch_city(inspection),
        fetch_province(inspection),
        inspection['PostCode'],
        lat,
        lng,
        nil
      ]
    end
    rows
  end
  
  def self.inspections(inspections)
    rows = []
    rows << [
        'business_id',
        'score',
        'date',
        'description',
        'type'
      ]
    inspections.each do |inspection|
      rows << [
          inspection['FHRSID'],
          get_score(inspection['RatingValue']),
          date_format(inspection['RatingDate']),
          nil,
          nil
        ]
    end
    rows
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
  
  def self.parse_address(inspection)
    address_lines(inspection).delete_if{ |line| line.blank?}.join(", ")
  end
  
  def self.fetch_city(inspection)
    address_lines(inspection).each do |line|
      return line if Towns.where(name: line).count > 0        
    end
  end
  
  def self.fetch_province(inspection)
    address_lines(inspection).each do |line|
      return line if Counties.where(name: line).count > 0
    end
  end
  
  def self.get_score(score)
    score.to_i * 20
  end
  
  def self.date_format(date)
    Date.parse(date).strftime("%Y%m%d")
  end
  
  def self.address_lines(inspection)
    [
      inspection['AddressLine1'],
      inspection['AddressLine2'],
      inspection['AddressLine3'],
      inspection['AddressLine4'],
      inspection['PostCode']
    ]
  end
  
end