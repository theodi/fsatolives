require_relative 'mongoid_setup'

class Counties
  include Mongoid::Document
  
  field :name, type: String
  field :short_name, type: String
  field :code, type: String
end