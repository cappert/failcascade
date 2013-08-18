class Alliance
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :ticker, type: String
  field :current_member_count, type: Integer
  field :actual_member_count, type: Hash, default: ->{ {} }
  field :predicted_member_count, type: Hash, default: ->{ {} }
  field :growth_ratio, type: Float, default: ->{ 1.0 }
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
      alliance.update_predictions
      alliance.save
    end
  end

  def remove_duplicates
    Alliance.where(ticker: self.ticker).nin(_id: self._id).destroy_all
  end

  def update_predictions
    self.predicted_member_count = actual_member_count.slice actual_member_count.keys.max

    predictions = RUtilities.extension_of_series(actual_member_count.sort.map{ |k,v| v }, 4*7)
    predictions = predictions.map{ |prediction| [prediction.to_i, 0].max }

    self.growth_ratio = predictions.last > 0 ?  predictions.last.to_f / predictions.first.to_f : 0

    predictions.each_with_index do |prediction, index|
      prediction_date = updated_at + (index + 1).days
      self.predicted_member_count[prediction_date.to_date] = prediction
    end
  end

  def chart_series
    [
      { name: 'Actual',    data: actual_member_count.sort.map{ |k,v| [Date.parse(k).to_time.to_i * 1000, v] } },
      { name: 'Predicted', data: predicted_member_count.sort.map{ |k,v| [Date.parse(k).to_time.to_i * 1000, v] } }
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
