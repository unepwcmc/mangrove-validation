class MangroveValidation.Routers.LayersRouter extends Backbone.Router
  initialize: (options) ->
    @layers = new MangroveValidation.Collections.LayersCollection()
    @mapView = new MangroveValidation.Views.Layers.MapView(@layers)
    @mapControlsView = new MangroveValidation.Views.Layers.MapControlsView()
    @searchView = new MangroveValidation.Views.Layers.SearchView(@layers)
    @searchResultsView = new MangroveValidation.Views.Layers.SearchResultsView(@layers)

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    @view = new MangroveValidation.Views.Layers.IndexView(layers: @layers)
    $("#layers").html(@view.render().el)

    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

  show: (id) ->
    alert("This is island #{id}")
    layer = @layers.get(id)

    @view = new MangroveValidation.Views.Layers.ShowView(model: layer)
    $("#layers").html(@view.render().el)

  edit: (id) ->
    layer = @layers.get(id)

    @view = new MangroveValidation.Views.Layers.EditView(model: layer)
    $("#layers").html(@view.render().el)
