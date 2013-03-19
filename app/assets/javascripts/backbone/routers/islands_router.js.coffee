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
    "new"      : "new"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"
    "password/:id" : "reset_password"

  index: ->
    if (@sidePanelManager.isEmpty())
      # Show the modal is this is the first view loaded
      $('#landingModal').modal()

    @island.set({id: null})

    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IndexView())
    $(@sidePanelElem).addClass('disabled')

  new: ->
    @island = new MangroveValidation.Models.Island
    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: @island))
    MangroveValidation.bus.trigger('changeIslandView','edit')

  show: (id) ->
    @island.set({id: id})
    @island.fetch(
      success: (model, response, options) =>
        @sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: model))
        $(@sidePanelElem).removeClass('disabled')
      error: (model, xhr, options) =>
        @index()
    )

  baseLayout: ->
    @mapView = new MangroveValidation.Views.Islands.MapView(@island)
    @searchResultsView = new MangroveValidation.Views.Islands.SearchView @islands, $(".navbar-search"), MangroveValidation.Views.Islands.SearchView::setSearchTarget

  reset_password: (id) ->
    window.VALIDATION.showResetPassword(id)
