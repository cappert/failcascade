class SolarSystem
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :constellation_id, type: String
  field :constellation_name, type: String
  field :region_id, type: String
  field :region_name, type: String
  field :security, type: Float, default: ->{ 1.0 }
end
