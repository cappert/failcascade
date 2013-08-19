class RUtilities
  def self.r
    @r ||= RinRuby.new(false, false) # output, interactive mode
  end

  def self.extension_of_series(series, additional_items = 10)
    case series.length
    when 0
      return (1..additional_items).map { 0 }
    when 1
      series = 7.times.map{ series.first }
    else
      while series.length < 7
        series.unshift (series[0] + series[0] - series[1])
      end
    end

    r.series = series

    r.eval <<-RCODE
      library("forecast")

      forecastedSeries <- forecast(ets(ts(series)), h=#{additional_items})

      results <- summary(forecastedSeries)[[1]]
    RCODE

    Array(r.results)
  end
end
