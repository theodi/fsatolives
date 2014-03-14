require 'csv'
require 'db/towns'
require 'db/counties'

class Import
  
  def self.perform
    CSV.foreach(File.join("data", "50kgaz2013.txt"), col_sep: ":", encoding:'iso-8859-1:utf-8') do |row|
      Towns.create({ name: row[2], county: row[13] }) if ["T", "C", "O"].include?(row[14])
      Counties.create({ name: row[13], short_name: row[12] }) if Counties.where( name: row[13] ).count == 0
    end
  end
  
end