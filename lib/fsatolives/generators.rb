class FsaToLives

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
        fetch_place(inspection, Towns),
        fetch_place(inspection, Counties),
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

end