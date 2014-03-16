require 'spec_helper'

describe FsaToLives do
  
  it "gets a list of authorities", :vcr do
    authorities = FsaToLives.authorities
    authorities.count.should == 406
    authorities.first['Name'].should == "Cambridge City"
    authorities.first['FriendlyName'].should == "cambridge-city"
    authorities.first['FileName'].should == "http://ratings.food.gov.uk/OpenDataFiles/FHRS027en-GB.xml"
  end
  
  it "gets a single authority", :vcr do
    authority = FsaToLives.get_authority(1)
    authority['Name'].should == "Cambridge City"
    authority['FriendlyName'].should == "cambridge-city"
    authority['FileName'].should == "http://ratings.food.gov.uk/OpenDataFiles/FHRS027en-GB.xml"
  end
  
  it "returns authority data in LIVES format" do
    Timecop.freeze(Date.parse("2014-03-14"))
    
    authority = {
      "LocalAuthorityId"=>1,
     "LocalAuthorityIdCode"=>"027",
     "Name"=>"Cambridge City",
     "FriendlyName"=>"cambridge-city",
     "Url"=>"http://www.cambridge.gov.uk",
     "SchemeUrl"=>"",
     "Email"=>"env.health@cambridge.gov.uk",
     "RegionName"=>"East Counties",
     "FileName"=>"http://ratings.food.gov.uk/OpenDataFiles/FHRS027en-GB.xml",
     "FileNameWelsh"=>nil,
     "EstablishmentCount"=>1211,
     "CreationDate"=>"2010-08-17T15:30:24.87",
     "LastPublishedDate"=>"2014-03-14T00:04:05.487",
     "SchemeType"=>1,
     "links"=>
      [{"rel"=>"self", "href"=>"http://api.ratings.food.gov.uk/authorities/1"}]
    }
    
    FsaToLives.feed_info(authority).should == [
        [
          'feed_date',
          'feed_version',
          'municipality_name',
          'municipality_url',
          'contact_email'
        ],
        [
          "20140314",
          "0.4.1",
          "Cambridge City",
          "http://www.cambridge.gov.uk",
          "env.health@cambridge.gov.uk"
        ]
      ]
      
    Timecop.return
  end
  
  it "gets a list of inspections", :vcr do
    url = "http://ratings.food.gov.uk/OpenDataFiles/FHRS027en-GB.xml"
    inspections = FsaToLives.get_inspections(url)
    inspections.count.should == 1211
    inspections.first['FHRSID'].should_not == nil
    inspections.first['BusinessName'].should_not == nil
    inspections.first['AddressLine1'].should_not == nil
    inspections.first['AddressLine2'].should_not == nil
    inspections.first['PostCode'].should_not == nil
    inspections.first['RatingValue'].should_not == nil
    inspections.first['Geocode']['Longitude'].should_not == nil
    inspections.first['Geocode']['Latitude'].should_not == nil
  end
  
  context "address parse" do
    
    it "with one line" do
      lines = {
        "AddressLine1" => "123 High Street"
      }
      FsaToLives.parse_address(lines).should == "123 High Street"
    end
    
    it "with two lines" do
      lines = {
        "AddressLine1" => "123 High Street",
        "AddressLine2" => "Anytown"
      }
      FsaToLives.parse_address(lines).should == "123 High Street, Anytown"
    end
    
    it "with three lines" do
      lines = {
        "AddressLine1" => "123 High Street",
        "AddressLine2" => "Anytown",
        "AddressLine3" => "Anyshire"
      }
      FsaToLives.parse_address(lines).should == "123 High Street, Anytown, Anyshire"
    end
    
    it "with four lines" do
      lines = {
        "AddressLine1" => "123 High Street",
        "AddressLine2" => "Anytown",
        "AddressLine3" => "Anyplace",
        "AddressLine4" => "Anyshire"
      }
      FsaToLives.parse_address(lines).should == "123 High Street, Anytown, Anyplace, Anyshire"
    end
    
    it "with five lines" do
      lines = {
        "AddressLine1" => "123 High Street",
        "AddressLine2" => "Anytown",
        "AddressLine3" => "Anyplace",
        "AddressLine4" => "Anyshire",
        "PostCode"     => "ANY 123"
      }
      FsaToLives.parse_address(lines).should == "123 High Street, Anytown, Anyplace, Anyshire, ANY 123"
    end
    
    it "with mixed lines" do
      lines = {
        "AddressLine1" => "123 High Street",
        "AddressLine4" => "Anytown",
        "PostCode"     => "ANY 123"
      }
      FsaToLives.parse_address(lines).should == "123 High Street, Anytown, ANY 123"
    end
    
  end
  
  it "returns a town from a hash of address lines" do
    FsaToLives.fetch_place({
      "AddressLine1" => "123 High Street",
      "AddressLine2" => "Coleshill",
      "AddressLine3" => "Birmingham",
      "PostCode"     => "ANY 123"
    }, Towns).should == "Coleshill"
  end
  
  it "returns a county from a hash of address lines" do
    FsaToLives.fetch_place({
      "AddressLine1" => "123 High Street",
      "AddressLine2" => "Coleshill",
      "AddressLine3" => "Birmingham",
      "PostCode"     => "ANY 123"
    }, Counties).should == "Birmingham"
  end
  
  it "returns a score in LIVES format" do
    FsaToLives.get_score("5").should == 100
    FsaToLives.get_score("4").should == 80
    FsaToLives.get_score("3").should == 60
    FsaToLives.get_score("2").should == 40
    FsaToLives.get_score("1").should == 20
    FsaToLives.get_score("0").should == 0
  end
  
  it "returns a date in the correct format" do
    FsaToLives.date_format("2013-01-01").should == "20130101"
  end
  
  context "with insepctions" do
    
    before(:each) do
      @inspections = [
       {"FHRSID"                     =>"507036",
        "LocalAuthorityBusinessID"   =>"PI/000075684",
        "BusinessName"               =>"2nd View Cafe - Waterstones",
        "BusinessType"               =>"Restaurant/Cafe/Canteen",
        "BusinessTypeID"             =>"1",
        "AddressLine1"               =>"20-22 Sidney Street",
        "AddressLine2"               =>"Cambridge",
        "AddressLine3"               =>"Cambridgeshire",
        "PostCode"                   =>"CB2 3HG",
        "RatingValue"                =>"4",
        "RatingKey"                  =>"fhrs_5_en-GB",
        "RatingDate"                 =>"2013-07-09",
        "LocalAuthorityCode"         =>"027",
        "LocalAuthorityName"         =>"Cambridge City",
        "LocalAuthorityWebSite"      =>"http://www.cambridge.gov.uk",
        "LocalAuthorityEmailAddress" =>"env.health@cambridge.gov.uk",
        "Scores"                     =>{"Hygiene"=>"0", "Structural"=>"5", "ConfidenceInManagement"=>"0"},
        "SchemeType"                 =>"FHRS",
        "Geocode"                    =>
         {"Longitude"                =>"0.12086200000000", "Latitude"=>"52.20630700000000"}},
       {"FHRSID"                     =>"506015",
        "LocalAuthorityBusinessID"   =>"PI/000004022",
        "BusinessName"               =>"5 Chapel Street B&B",
        "BusinessType"               =>"Hotel/bed & breakfast/guest house",
        "BusinessTypeID"             =>"7842",
        "AddressLine1"               =>"5 Chapel Street",
        "AddressLine2"               =>"Cambridge",
        "AddressLine3"               =>"Cambridgeshire",
        "PostCode"                   =>"CB4 1DY",
        "RatingValue"                =>"5",
        "RatingKey"                  =>"fhrs_5_en-GB",
        "RatingDate"                 =>"2012-10-25",
        "LocalAuthorityCode"         =>"027",
        "LocalAuthorityName"         =>"Cambridge City",
        "LocalAuthorityWebSite"      =>"http://www.cambridge.gov.uk",
        "LocalAuthorityEmailAddress" =>"env.health@cambridge.gov.uk",
        "Scores"                     =>{"Hygiene"=>"0", "Structural"=>"0", "ConfidenceInManagement"=>"0"},
        "SchemeType"                 =>"FHRS",
        "Geocode"                    =>
         {"Longitude"                =>"0.14030500000000", "Latitude"=>"52.21739400000000"}}
      ]
    end
  
    it "returns business information in LIVES format" do
      FsaToLives.businesses(@inspections).should == [
        [
          'business_id',
          'name',
          'address',
          'city',
          'state',
          'postal_code',
          'latitude',
          'longitude',
          'phone_number'
        ],
        [
          '507036',
          '2nd View Cafe - Waterstones',
          '20-22 Sidney Street, Cambridge, Cambridgeshire, CB2 3HG',
          'Cambridge',
          'Cambridgeshire',
          'CB2 3HG',
          '52.20630700000000',
          '0.12086200000000',
          nil
        ],
        [
          '506015',
          '5 Chapel Street B&B',
          '5 Chapel Street, Cambridge, Cambridgeshire, CB4 1DY',
          'Cambridge',
          'Cambridgeshire',
          'CB4 1DY',
          '52.21739400000000',
          '0.14030500000000',
          nil
        ]
      ]
    end
    
    it "returns inspection information in LIVES format" do 
      FsaToLives.inspections(@inspections).should == [
          [
            'business_id',
            'score',
            'date',
            'description',
            'type'
          ],
          [
            '507036',
            80,
            '20130709',
            nil,
            nil
          ],
          [
            '506015',
            100,
            '20121025',
            nil,
            nil
          ]
        ]
    end
    
  end
  
  it "writes a csv from an array" do
    array = [
        [
          'business_id',
          'score',
          'date',
          'description',
          'type'
        ],
        [
          '507036',
          '80',
          '20130709',
          nil,
          nil
        ],
        [
          '506015',
          '100',
          '20121025',
          nil,
          nil
        ]
      ]
    
    csv = CSV.generate do |csv|
      array.each { |a| csv << a }
    end
        
    Tempfile.should_receive(:new).once
    CSV.should_receive(:open).once.and_return(csv)
    FsaToLives.to_csv(array)
  end
  
  context "creating zip files" do
    
    before(:each) do
      @file1 = Tempfile.new('file1')
      @file1.write('1,2,3')
      @file1.rewind

      @file2 = Tempfile.new('file2')
      @file2.write('3,4,5')
      @file2.rewind
    end
    
    it "creates the correct filename" do
      Timecop.freeze(Date.parse("2014-03-14"))
      
      Zip::File.should_receive(:open).once.with("lives-1-2014-03-14.zip", Zip::File::CREATE)
      
      FsaToLives.zip_files("1", {
        "file1" => @file1,
        "file2" => @file2
      })

      Timecop.return
    end
    
    it "zips the correct files" do
      Zip::File.any_instance.should_receive(:add).exactly(2).times
      
      FsaToLives.zip_files("1", {
        "file1" => @file1,
        "file2" => @file2
      })
    end
  end
    
end