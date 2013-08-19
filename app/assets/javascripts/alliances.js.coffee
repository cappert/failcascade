jQuery ->
  topChart = $ '#top-alliance-chart'

  $('#top-alliances dt').each ->
    topEntry     = $ this
    allianceLine = -> topChart.highcharts().series[topEntry.data 'index'].graph
    topEntry.on 'mouseenter', -> allianceLine().animate {'stroke-width': '5'}, 'easing'
    topEntry.on 'mouseleave', -> allianceLine().animate {'stroke-width': '2'}, 'easing'
