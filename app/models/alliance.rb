class Alliance
  include Mongoid::Document

  field :_id, type: String
  field :name, type: String
  field :ticker, type: String
  field :current_member_count, type: Integer
  field :target_member_count, type: Integer
  field :peak_member_count, type: Integer
  field :actual_member_count, type: Hash, default: ->{ {} }
  field :predicted_member_count, type: Hash, default: ->{ {} }
  field :predicted_min_member_count, type: Hash, default: ->{ {} }
  field :predicted_max_member_count, type: Hash, default: ->{ {} }
  field :growth_ratio, type: Float, default: ->{ 1.0 }
  field :predicted_collapse, type: Date
  field :established, type: Date
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

    Alliance.where(updated_at: updated_at).desc(:current_member_count).each do |alliance|
      alliance.update_predictions
      alliance.save
    end
  end

  def remove_duplicates
    Alliance.where(ticker: self.ticker).nin(_id: self._id).destroy_all
  end

  def update_predictions
    prediction_base = actual_member_count.slice actual_member_count.keys.max

    self.predicted_member_count = prediction_base.dup
    self.predicted_min_member_count = prediction_base.dup
    self.predicted_max_member_count = prediction_base.dup

    predictions = RUtilities.extension_of_series(actual_member_count.sort.map{ |k,v| v }, 4*7)

    predictions.each_with_index do |prediction, index|
      key = (updated_at + (index + 1).days).to_date.to_s
      self.predicted_member_count[key]     = [prediction[:predicted].to_i, 0].max
      self.predicted_min_member_count[key] = [prediction[:min].to_i, 0].max
      self.predicted_max_member_count[key] = [prediction[:max].to_i, 0].max
    end

    self.target_member_count = self.predicted_member_count.sort.last.last
    self.growth_ratio = target_member_count > 0 ?  target_member_count.to_f / current_member_count.to_f : 0
    self.predicted_collapse = self.predicted_member_count.sort.find{ |date, members| members == 0 }.try :first
  end

  def chart_data(metric)
    self.send(metric).sort.map { |k,v| [ Date.parse(k).downtimestamp, v ] }
  end

  def chart_series
    [
      { name: 'Actual',    data: chart_data(:actual_member_count),    color: '#777777' },
      { name: 'Predicted', data: chart_data(:predicted_member_count), color: '#999999', zIndex: 1 },
      { name: 'Possible',  data: predicted_member_range,              color: '#999999', zIndex: 0, type: 'arearange', linkedTo: ':previous', fillOpacity: 0.1 },
    ]
  end

  def combined_member_count
    actual_member_count.merge predicted_member_count
  end

  def predicted_member_range
    max_counts = predicted_max_member_count.sort.map(&:second)
    chart_data(:predicted_min_member_count).map.each_with_index { |pair, index| [ pair[0], pair[1], max_counts[index] ] }
  end

  def full_name
    "#{name} <#{ticker}>"
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
      alliance.established = data['startDate']
      alliance.peak_member_count = [ alliance.peak_member_count, alliance.current_member_count ].max

      alliance.remove_duplicates

      alliance.save
    end
  end

  def self.extract_data_from(api_response)
    time = Time.parse "#{api_response['currentTime']} UTC"
    rows = api_response['result']['rowset']['row'].map{ |row| row.slice *%w(name shortName allianceID memberCount startDate) }
    return rows, time
  end
end
