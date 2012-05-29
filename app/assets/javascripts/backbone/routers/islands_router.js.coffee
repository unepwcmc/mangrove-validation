class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()

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
    @islands.getAndResetById(id)
    island = new MangroveValidation.Models.Island({id: id})
    island.fetch()

    @view = new MangroveValidation.Views.Islands.IslandView(model: island)
    $("#right-main").html(@view.render().el)

  edit: (id) ->
    island = @islands.get(id)

    @view = new MangroveValidation.Views.Islands.EditView(model: island)
    $("#islands").html(@view.render().el)

  baseLayout: ->
    # Search box
    $("#search").typeahead
      source: (typeahead, query) =>
        @islands.search query, (collection, response) ->
          typeahead.process(response)
      items: 4
      property: 'name'
      onselect: (obj) ->
        window.router.navigate("#{obj.id}", true)
    $("#search").focus (e) =>
      $(e.target).val('')
      @islands.search(null)
      @islands.getAndResetById(null)
    # Prevent search form submission
    $(".navbar-search").submit (e) ->
      e.preventDefault()

    @mapView = new MangroveValidation.Views.Islands.MapView(@islands)
    @mapControlsView = new MangroveValidation.Views.Islands.MapControlsView()
    @searchResultsView = new MangroveValidation.Views.Islands.SearchResultsView(@islands)
