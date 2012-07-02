class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @island = new MangroveValidation.Models.Island()

    @sidePanelManager = new MangroveValidation.ViewManager("#right-main")

    # Base layout
    @baseLayout()

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"
    "password/:id" : "reset_password"

  index: ->
    @view = new MangroveValidation.Views.Islands.IndexView(islands: @islands)
    $("#islands").html(@view.render().el)

    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

    $('#landingModal').modal()

  show: (id) ->
    #@islands.getAndResetById(id)
    @island.set({id: id})
    @island.fetch()

    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: @island))

  baseLayout: ->
    @mapView = new MangroveValidation.Views.Islands.MapView(@island)
    @searchResultsView = new MangroveValidation.Views.Islands.SearchView @islands, $(".navbar-search"), MangroveValidation.Views.Islands.SearchView::setSearchTarget

  reset_password: (id) ->
    window.VALIDATION.showResetPassword(id)
