jQuery ->
  plotLines = [ { color: '#AAAAAA', width: 1, value: $('body').data('downtimestamp') } ]
  $('.chart').each ->
    chart = $ this
    chart.highcharts
      title:
        text: null
      xAxis:
        type: 'datetime'
        plotLines: plotLines
      yAxis:
        title:
          text: 'Member count'
        min: 0
      plotOptions:
        line:
          marker:
            enabled: false
      series: chart.data('series')
