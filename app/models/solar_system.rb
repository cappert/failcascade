class SolarSystem
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :constellation_id, type: String
  field :constellation_name, type: String
  field :region_id, type: String
  field :region_name, type: String
  field :security, type: Float, default: ->{ 1.0 }
  field :owner_alliance_id, type: String
  field :owner_alliance_ticker, type: String

  def self.update_from_api
    rows, update_time = extract_data_from EveApi.sovereignty

    rows.each_with_index do |data, index|
      p "#{index}..." if index % 100 == 0

      solar_system = where(_id: data['solarSystemID']).first

      next unless solar_system # not 0.0

      alliance = Alliance.where(_id: data['allianceID']).first

      solar_system.owner_alliance_id = data['allianceID']
      solar_system.owner_alliance_ticker = alliance.try :Aticker

      solar_system.save
    end
  end

  private

  def self.extract_data_from(api_response)
    time = Time.parse "#{api_response['currentTime']} UTC"
    rows = api_response['result']['rowset']['row'].map{ |row| row.slice *%w(solarSystemID allianceID) }
    return rows, time
  end
end
