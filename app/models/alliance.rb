class Alliance
  include Mongoid::Document

  PREDICTION_RANGE = 4*7
  MONGODB_MAX      = 9223372036854775807

  field :_id, type: String
  field :name, type: String
  field :ticker, type: String
  field :current_member_count, type: Integer
  field :target_member_count, type: Integer
  field :peak_member_count, type: Integer, default: ->{ 0 }
  field :actual_member_count, type: Hash, default: ->{ {} }
  field :predicted_member_count, type: Hash, default: ->{ {} }
  field :predicted_min_member_count, type: Hash, default: ->{ {} }
  field :predicted_max_member_count, type: Hash, default: ->{ {} }
  field :growth_ratio, type: Float, default: ->{ 1.0 }
  field :predicted_collapse, type: Date
  field :established, type: Date
  field :collapsed, type: Boolean, default: ->{ false }
  field :significant, type: Boolean, default: ->{ true }
  field :sov_held, type: Integer, default: ->{ 0 }
  field :updated_at, type: ActiveSupport::TimeWithZone

  def self.update_from_api
    rows, update_time = extract_data_from EveApi.alliances

    rows.each_with_index do |data, index|
      p "#{index}..." if index % 100 == 0

      alliance = where(_id: data['allianceID']).first_or_initialize

      alliance.name = data['name']
      alliance.ticker = data['shortName']
      alliance.updated_at = update_time
      alliance.actual_member_count[update_time.to_date.to_s] = data['memberCount'].to_i
      alliance.established = data['startDate']

      alliance.update_metadata

      alliance.update_predictions if alliance.should_update_predictions?

      alliance.save

      Alliance.where(ticker: alliance.ticker).nin(_id: alliance._id).destroy_all
    end

    Alliance.lt(updated_at: update_time).update_all(collapsed: true)
  end

  def self.count_sov
    data = SolarSystem.count_by_holder

    Alliance.nin(_id: data.keys).update_all(sov_held: 0)
    Alliance.in(_id: data.keys).each do |alliance|
      alliance.sov_held = data[alliance._id]
      alliance.save
    end
  end

  def self.noticeable
    where(collapsed: false, significant: true)
  end

  def noticeable?
    !collapsed? && significant?
  end

  def to_param
    ticker
  end

  def significance_member_count
    [ peak_member_count / 15, 50 ].max
  end

  def update_metadata
    self.current_member_count = actual_member_count[ actual_member_count.keys.max ]
    self.peak_member_count    = [ peak_member_count, current_member_count ].max
    self.significant          = current_member_count > significance_member_count
  end

  def should_update_predictions?
    noticeable? && (predicted_member_count.empty? || actual_member_count.keys.max > predicted_member_count.keys.min)
  end

  def normalized_member_count(value)
    cap = [peak_member_count.to_i * 30, MONGODB_MAX].min
    [[value.to_i, 0].max, cap].min
  end

  def update_predictions
    prediction_base = actual_member_count.slice actual_member_count.keys.max

    self.predicted_member_count = prediction_base.dup
    self.predicted_min_member_count = prediction_base.dup
    self.predicted_max_member_count = prediction_base.dup

    predictions = RUtilities.extension_of_series(actual_member_count.sort.map{ |k,v| v }, PREDICTION_RANGE)

    predictions.each_with_index do |prediction, index|
      key = (updated_at + (index + 1).days).to_date.to_s
      self.predicted_member_count[key]     = normalized_member_count prediction[:predicted]
      self.predicted_min_member_count[key] = normalized_member_count prediction[:min]
      self.predicted_max_member_count[key] = normalized_member_count prediction[:max]
    end

    self.target_member_count = predicted_member_count.sort.last.last
    self.growth_ratio        = target_member_count > 0 ?  target_member_count.to_f / current_member_count.to_f : 0

    if target_member_count < significance_member_count
      self.predicted_collapse = self.predicted_member_count.sort.find{ |date, members| members < significance_member_count }.try :first
    else
      self.predicted_collapse = nil
    end
  end

  def chart_data(metric)
    self.send(metric).sort.map { |k,v| [ Date.parse(k).downtimestamp, v ] }
  end

  def chart_series
    series = [ { name: 'Actual',    data: chart_data(:limited_actual_member_count), color: '#777777' } ]

    if noticeable?
      series << { name: 'Predicted', data: chart_data(:predicted_member_count), color: '#999999', zIndex: 1 }
      series << { name: 'Possible',  data: predicted_member_range,              color: '#999999', zIndex: 0, type: 'arearange', linkedTo: ':previous', fillOpacity: 0.1 }
    end

    series
  end

  def limited_actual_member_count
    actual_member_count.slice *actual_member_count.keys.sort.last(PREDICTION_RANGE)
  end

  def combined_member_count
    limited_actual_member_count.merge predicted_member_count
  end

  def predicted_member_range
    max_counts = predicted_max_member_count.sort.map(&:second)
    chart_data(:predicted_min_member_count).map.each_with_index { |pair, index| [ pair[0], pair[1], max_counts[index] ] }
  end

  def full_name
    "#{name} <#{ticker}>"
  end

  def updatestamp
    updated_at && updated_at.to_date.downtimestamp
  end

  private

  def self.extract_data_from(api_response)
    time = Time.parse "#{api_response['currentTime']} UTC"
    rows = api_response['result']['rowset']['row'].map{ |row| row.slice *%w(name shortName allianceID memberCount startDate) }
    return rows, time
  end
end
