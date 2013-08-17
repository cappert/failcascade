class Alliance
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :ticker, type: String
  field :current_member_count, type: Integer
  field :actual_member_count, type: Hash, default: ->{ {} }
  field :predicted_member_count, type: Hash, default: ->{ {} }
  field :updated_at, type: ActiveSupport::TimeWithZone

  def self.update_from_api
    update_and_predict EveApi.alliances
  end

  def self.update_from_file(path)
    api_equivalent = MultiXml.parse(File.read path)['eveapi']
    update_and_predict api_equivalent
  end

  def update_predictions
    self.predicted_member_count = actual_member_count.slice updated_at.to_date

    RUtilities.extension_of_series(actual_member_count.values, 4*7).each_with_index do |prediction, index|
      prediction_date = updated_at + (index + 1).days
      predicted_member_count[prediction_date.to_date] = prediction.to_i
    end
  end

  def remove_duplicates
    Alliance.where(ticker: self.ticker).nin(_id: self._id).destroy_all
  end

  private

  def self.update_and_predict(api_response)
    rows, update_time = extract_data_from api_response
    rows.each do |data|
      alliance = where(_id: data['allianceID']).first_or_initialize

      alliance.name = data['name']
      alliance.ticker = data['shortName']
      alliance.updated_at = update_time
      alliance.current_member_count = data['memberCount'].to_i
      alliance.actual_member_count[update_time.to_date] = data['memberCount'].to_i

      alliance.update_predictions
      alliance.remove_duplicates

      alliance.save
    end
  end

  def self.extract_data_from(api_response)
    time = Time.parse "#{api_response['currentTime']} UTC"
    rows = api_response['result']['rowset']['row'].map{ |row| row.slice *%w(name shortName allianceID memberCount) }
    return rows, time
  end
end
