class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @island = new MangroveValidation.Models.Island()

    @sidePanelElem = '#right-main'
    @sidePanelManager = new Backbone.ViewManager(@sidePanelElem)

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

    $(@sidePanelElem).html(@sidePanelManager.showView(new MangroveValidation.Views.Islands.IndexView()))
    $(@sidePanelElem).addClass('disabled')

  new: ->
    window.checkUserSignedIn(
      success: =>
        @island = new MangroveValidation.Models.Island
        $(@sidePanelElem).html(@sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: @island)))
        MangroveValidation.bus.trigger('changeIslandView','edit')
      error: window.VALIDATION.showUserLogin
    )

  show: (id) ->
    @island.set({id: id})
    @island.fetch(
      success: (model, response, options) =>
        $(@sidePanelElem).html(@sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: model)))
        $(@sidePanelElem).removeClass('disabled')
      error: (model, xhr, options) =>
        @index()
    )

  reset_password: (id) ->
    window.VALIDATION.showResetPassword(id)

  baseLayout: ->
    @mapView = new MangroveValidation.Views.Islands.MapView(@island)
    @searchResultsView = new MangroveValidation.Views.Islands.SearchView @islands, $(".navbar-search"), MangroveValidation.Views.Islands.SearchView::setSearchTarget
