require 'mongoid'
$:.unshift File.dirname(__FILE__)

Mongoid.load!(File.join(File.dirname(__FILE__), "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)