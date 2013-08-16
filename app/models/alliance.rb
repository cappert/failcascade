class Alliance
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :ticker, type: String
  field :actual_member_count, type: Hash, default: ->{ {} }
  field :predicted_member_count, type: Hash, default: ->{ {} }
  field :updated_at, type: ActiveSupport::TimeWithZone

  def self.update_from_api
    update_and_predict EveApi.alliances
  end

  def self.update_from_file(path)
    api_equivalent = MultiXml.parse(File.read path)['eveapi']['result']['rowset']['row']
    update_and_predict api_equivalent
  end

  def update_predictions
    self.predicted_member_count = actual_member_count.slice updated_at.to_date

    RUtilities.extension_of_series(actual_member_count.values, 4*7).each_with_index do |prediction, index|
      prediction_date = updated_at + (index + 1).days
      predicted_member_count[prediction_date.to_date] = prediction.to_i
    end
  end

  private

  def self.update_and_predict(api_rows)
    update_time = Time.current
    extract_data_from(api_rows).each do |data|
      alliance = where(_id: data['allianceID']).first_or_initialize
      alliance.name = data['name']
      alliance.ticker = data['shortName']
      alliance.updated_at = update_time
      alliance.actual_member_count[update_time.to_date] = data['memberCount'].to_i
      alliance.update_predictions
      alliance.save
    end
  end

  def self.extract_data_from(api_rows)
    api_rows.map{ |row| row.slice *%w(name shortName allianceID memberCount) }
  end
end
