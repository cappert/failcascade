jQuery ->
  $('.chart').each ->
    chart = $ this
    chart.highcharts
      title:
        text: null
      xAxis:
        type: 'datetime'
      yAxis:
        title:
          text: 'Member count'
        min: 0
      plotOptions:
        line:
          marker:
            enabled: false
      series: chart.data('series')
