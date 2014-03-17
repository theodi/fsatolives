class FsaToLives
  
  def self.get_authority(id)
    url = "http://api.ratings.food.gov.uk/Authorities/#{id}"
    JSON.parse(open(url, "x-api-version" => "2").read)
  end
  
  def self.authorities
    url = "http://api.ratings.food.gov.uk/Authorities"
    authorities = JSON.parse(open(url, "x-api-version" => "2").read)
    authorities['authorities']
  end
  
end