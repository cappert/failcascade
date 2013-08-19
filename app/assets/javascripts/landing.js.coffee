jQuery ->

  form = $('#main-search')
  if form.length > 0
    form.find('.input-group-addon').on 'click', -> form[0].submit()
    form.find('input').autocomplete
      source: '/alliances'
      select: (e, ui) ->
        if ui.item
          window.location = "/alliances/#{ui.item.value}"
