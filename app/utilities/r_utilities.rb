class RUtilities
  def self.r
    @r ||= RinRuby.new(false, false) # output, interactive mode
  end

  def self.extension_of_series(series, additional_items = 10)
    case series.length
    when 0
      return (1..additional_items).map { 0 }
    when 1
      series = 8.times.map{ series.first }
    else
      while series.length < 8
        series.unshift (series[0] + series[0] - series[1])
      end
    end

    r.series = series

    r.eval <<-RCODE
      library("forecast")

      forecastedSeries <- forecast(ets(ts(series)), h=#{additional_items})

      predicted <- summary(forecastedSeries)[[1]]
      lows <- summary(forecastedSeries)[[2]]
      highs <- summary(forecastedSeries)[[3]]
    RCODE

    lows = Array(r.lows)
    predicted = Array(r.predicted)
    highs = Array(r.highs)

    predicted.map.each_with_index do |prediction, index|
      { min: lows[index], predicted: prediction, max: highs[index] }
    end
  end
end
