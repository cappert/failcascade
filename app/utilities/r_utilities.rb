class RUtilities
  def self.r
    @r ||= RinRuby.new(false, false) # output, interactive mode
  end

  def self.extension_of_series(series, additional_items = 10)
    if series.empty?
      return (1..additional_items).map { 0 }
    end

    while series.length < 4 # If there are less than four elements, the R code will fail. Pad the series with existing elements to appease it.
      series.unshift series.first
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
