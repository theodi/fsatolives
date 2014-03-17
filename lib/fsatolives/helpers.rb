class FsaToLives

  def self.parse_address(inspection)
    address_lines(inspection).delete_if{ |line| line.blank?}.join(", ")
  end
  
  def self.fetch_place(inspection, type)
    address_lines(inspection).each do |line|
      return line if type.where(name: line).count > 0        
    end
    return nil
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