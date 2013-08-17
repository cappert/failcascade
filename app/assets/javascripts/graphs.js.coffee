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
      series: chart.data('series')

