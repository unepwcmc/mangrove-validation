MangroveValidation.Views.Islands ||= {}

# Side panel view of island,
# manages display of show/edit/geom_edit sub-views
class MangroveValidation.Views.Islands.IslandView extends Backbone.View
  template: JST["backbone/templates/islands/island"]

  events:
    'click #tabs li': 'tabClicked'
    'click .delete': 'deleteIsland'

  initialize: (options) ->
    # The sub-view to show can be passed as a param, default show
    @currentView = options.view
    @currentView ||= 'show'

    @tabbedContentManager = new MangroveValidation.ViewManager("#tabbed-content")

    # Zoom to the bounds of the island
    @model.getBounds (bounds) ->
      MangroveValidation.bus.trigger('zoomToBounds', bounds)

    # Bind to island events
    @bindTo(@model, 'change', @render)
    @bindTo(MangroveValidation.bus, 'changeIslandView', @changeView)

  tagName: "div"

  tabClicked: (event) =>
    tabLi = $(event.target)
    # Check that we've got the li, not a child
    if tabLi.prop('tagName') != 'LI'
      tabLi = tabLi.parent()

    # Switch view if not current
    if tabLi.prop('id') == 'geometry-tab'
      if @model.get('id')?
        @changeView('geometry') if @currentView != 'geometry'
      else
        alert("You must save this island before you can edit its geometry")
    else if tabLi.prop('id') == 'attributes-tab'
      @changeView('show') if @currentView == 'geometry'

  changeView: (view) =>
    # Change the current view and render
    @currentView = view
    @render()

  deleteIsland: (e) ->
    if confirm('Are you sure you want to delete this island?')
      @model.destroy(
        success: -> window.router.navigate("/", true)
      )

  # On close, close the tabbed content view
  onClose: =>
    @tabbedContentManager.currentView.close()

  render: =>
    @$el.parent().removeClass('disabled')

    viewParams = @model.toJSON()
    if @currentView == 'geometry'
      viewParams.activeTab = 'geometry'
    else
      viewParams.activeTab = 'attributes'
    @$el.html(@template(viewParams))

    if @currentView == 'edit'
      @model.off('change', @render)
      $('#name').focus()
    else
      @model.on('change', @render)

    # Create a sub-view based on the currentView
    if @currentView == 'show'
      view = new MangroveValidation.Views.Islands.ShowView({model: @model})
    else if @currentView == 'edit'
      view = new MangroveValidation.Views.Islands.AttributeEditView({model: @model})
    else if @currentView == 'geometry'
      view = new MangroveValidation.Views.Islands.GeometryEditView({model: @model})

    @tabbedContentManager.showView(view)

    return this
