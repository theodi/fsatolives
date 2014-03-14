require_relative 'mongoid_setup'

class Towns
  include Mongoid::Document
  
  field :name, type: String
  field :county, type: String
end