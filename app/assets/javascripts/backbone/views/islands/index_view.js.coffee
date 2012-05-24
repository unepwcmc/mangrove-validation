MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.IndexView extends Backbone.View
  template: JST["backbone/templates/islands/index"]

  events:
    'click #select-mangroves': 'selectMangroves'
    'click #select-corals':  'selectCorals'
    'click #select-salt-marshes':  'selectSaltMarshes'
    

  initialize: () ->
    @options.islands.bind('reset', @addAll)

  selectMangroves: () ->
    $('#map_menu .island-switcher .dropdown-menu a[data-island="mangroves"]').click()

  selectCorals: () ->
    $('#map_menu .island-switcher .dropdown-menu a[data-island="corals"]').click()

  selectSaltMarshes: () ->
    $('#map_menu .island-switcher .dropdown-menu a[data-island="saltmarshes"]').click()

  addAll: () =>
    @options.islands.each(@addOne)

  addOne: (island) =>
    view = new MangroveValidation.Views.Islands.IslandView({model : island})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(islands: @options.islands.toJSON() ))
    @addAll()
    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

    return this
