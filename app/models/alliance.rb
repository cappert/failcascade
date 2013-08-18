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
    update_from EveApi.alliances
    update_predictions
  end

  def self.update_from_file(path, predict: true)
    update_from MultiXml.parse(File.read path)['eveapi']
    update_predictions if predict
  end

  def self.update_predictions
    updated_at = Alliance.max(:updated_at)

    Alliance.where(updated_at: updated_at).each do |alliance|
      alliance.predicted_member_count = alliance.actual_member_count.slice alliance.actual_member_count.keys.max

      RUtilities.extension_of_series(alliance.actual_member_count.values, 4*7).each_with_index do |prediction, index|
        prediction_date = updated_at + (index + 1).days
        alliance.predicted_member_count[prediction_date] = [prediction.to_i, 0].max
      end

      alliance.save
    end
  end

  def remove_duplicates
    Alliance.where(ticker: self.ticker).nin(_id: self._id).destroy_all
  end

  def chart_series
    [
      { name: 'Actual',    data: actual_member_count.map{ |k,v| [Date.parse(k).to_time.to_i * 1000, v] }.sort_by{ |pair| pair.first } },
      { name: 'Predicted', data: predicted_member_count.map{ |k,v| [Date.parse(k).to_time.to_i * 1000, v] }.sort_by{ |pair| pair.first } }
    ]
  end

  private

  def self.update_from(api_response)
    rows, update_time = extract_data_from api_response
    rows.each do |data|
      alliance = where(_id: data['allianceID']).first_or_initialize

      alliance.name = data['name']
      alliance.ticker = data['shortName']
      alliance.updated_at = update_time
      alliance.current_member_count = data['memberCount'].to_i
      alliance.actual_member_count[update_time.to_date] = data['memberCount'].to_i

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
