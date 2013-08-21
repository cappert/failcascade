jQuery ->
  $('.chart').each ->
    chart = $ this
    chart.highcharts
      title:
        text: null
      xAxis:
        type: 'datetime'
        plotLines: [ { color: '#777777', width: 1, value: chart.data('updatestamp') } ]
      yAxis:
        title:
          text: 'Member count'
        min: 0
      plotOptions:
        line:
          marker:
            enabled: false
      series: chart.data('series')
