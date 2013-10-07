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
      solar_system.owner_alliance_ticker = alliance.try :ticker

      solar_system.save
    end
  end

  def self.count_by_holder
    map    = "function() { if(this.owner_alliance_id != '0'){ emit(this.owner_alliance_id, 1) } }"
    reduce = "function(key, values) { return values.length }"
    map_reduce(map, reduce).out(inline: true).each_with_object({}) do |item, results|
      results[item['_id']] = item['value'].to_i
    end
  end

  private

  def self.extract_data_from(api_response)
    time = Time.parse "#{api_response['currentTime']} UTC"
    rows = api_response['result']['rowset']['row'].map{ |row| row.slice *%w(solarSystemID allianceID) }
    return rows, time
  end
end
