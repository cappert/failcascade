jQuery ->
  topChart = $ '#top-alliance-chart'

  $('#top-alliances dt').each ->
    topEntry     = $ this
    allianceLine = -> topChart.highcharts().series[topEntry.data 'index'].graph
    topEntry.on 'mouseenter', -> allianceLine().animate {'stroke-width': '5'}, 'easing'
    topEntry.on 'mouseleave', -> allianceLine().animate {'stroke-width': '2'}, 'easing'


  searchField = $('#search-field')
  searchField.select2
    placeholder: 'that terrible alliance'
    ajax:
      url: '/'
      dataType: 'json'
      data: (term) -> { q: term }
      results: (data) -> { results: data }

    searchField.on 'change', -> window.location = "/#{searchField.val()}"
