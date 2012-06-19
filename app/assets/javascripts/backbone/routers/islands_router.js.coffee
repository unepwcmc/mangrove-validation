class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @island = new MangroveValidation.Models.Island()

    @sidePanelElem = '#right-main'
    @sidePanelManager = new MangroveValidation.ViewManager(@sidePanelElem)

    # Base layout
    @baseLayout()

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    if (@sidePanelManager.isEmpty())
      # Show the modal is this is the first view loaded
      $('#landingModal').modal()

    @island.set({id: null})

    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IndexView())
    $(@sidePanelElem).addClass('disabled')

  show: (id) ->
    @island.set({id: id})
    @island.fetch()

    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: @island))
    $(@sidePanelElem).removeClass('disabled')

  baseLayout: ->
    @mapView = new MangroveValidation.Views.Islands.MapView(@island)
    @searchResultsView = new MangroveValidation.Views.Islands.SearchView @islands, $(".navbar-search"), MangroveValidation.Views.Islands.SearchView::setSearchTarget
