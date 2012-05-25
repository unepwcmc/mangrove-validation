class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @islands.fetch()

    # Base layout
    @baseLayout()

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    @view = new MangroveValidation.Views.Islands.IndexView(islands: @islands)
    $("#islands").html(@view.render().el)

    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

  show: (id) ->
    island = @islands.getAndResetBy(id)

    @view = new MangroveValidation.Views.Islands.ShowView(model: island)
    $("#right-panel").html(@view.render().el)

  edit: (id) ->
    island = @islands.get(id)

    @view = new MangroveValidation.Views.Islands.EditView(model: island)
    $("#islands").html(@view.render().el)

  baseLayout: ->
    # Search box
    @searchIslands = new MangroveValidation.Collections.IslandsCollection()
    @searchIslands.fetch
      success: (collection, response) ->
        $("#search").typeahead
          source: _.pluck(collection.toJSON(), 'name')
          items: 4

    @mapView = new MangroveValidation.Views.Islands.MapView(@islands)
    @mapControlsView = new MangroveValidation.Views.Islands.MapControlsView()
    @searchResultsView = new MangroveValidation.Views.Islands.SearchResultsView(@islands)
