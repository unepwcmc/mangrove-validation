MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.IndexView extends Backbone.View
  template: JST["backbone/templates/layers/index"]

  events:
    'click #select-mangroves': 'selectMangroves'
    'click #select-corals':  'selectCorals'
    'click #select-salt-marshes':  'selectSaltMarshes'
    

  initialize: () ->
    @options.layers.bind('reset', @addAll)

  selectMangroves: () ->
    $('#map_menu .layer-switcher .dropdown-menu a[data-layer="mangroves"]').click()

  selectCorals: () ->
    $('#map_menu .layer-switcher .dropdown-menu a[data-layer="corals"]').click()

  selectSaltMarshes: () ->
    $('#map_menu .layer-switcher .dropdown-menu a[data-layer="saltmarshes"]').click()

  addAll: () =>
    @options.layers.each(@addOne)

  addOne: (layer) =>
    view = new MangroveValidation.Views.Layers.LayerView({model : layer})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(layers: @options.layers.toJSON() ))
    @addAll()
    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

    return this
