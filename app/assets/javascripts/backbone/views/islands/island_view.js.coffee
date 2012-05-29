MangroveValidation.Views.Islands ||= {}

# Side panel view of island,
# manages display of show/edit/geom_edit sub-views
class MangroveValidation.Views.Islands.IslandView extends Backbone.View
  template: JST["backbone/templates/islands/island"]

  events:
    'click #tabs li': 'tabClicked'

  initialize: (options) ->
    # The sub-view to show can be passed as a param, default show
    @currentView = options.view
    @currentView ||= 'show'

    # Zoom to the bounds of the island
    @model.getBounds (bounds) ->
      MangroveValidation.bus.trigger('zoomToBounds', bounds)

    # Bind to island events
    @model.on('change', @render)
    MangroveValidation.bus.on('changeIslandView', @changeView)

  tagName: "div"

  tabClicked: (event) =>
    tabLi = $(event.target)
    # Check that we've got the li, not a child
    if tabLi.prop('tagName') != 'LI'
      tabLi = tabLi.parent()

    # Switch view if not current
    if tabLi.prop('id') == 'geometry-tab'
      @changeView('geometry') if @currentView != 'geometry'
    else if tabLi.prop('id') == 'attributes-tab'
      @changeView('show') if @currentView == 'geometry'
      

  changeView: (view) =>
    # Change the current view and render
    @currentView = view
    @render()

  render: =>
    viewParams = @model.toJSON()
    if @currentView == 'geometry'
      viewParams.activeTab = 'geometry'
    else
      viewParams.activeTab = 'attributes'
    $(@el).html(@template(viewParams))

    # Create a sub-view based on the currentView
    if @currentView == 'show'
      view = new MangroveValidation.Views.Islands.ShowView({model: @model})
    else if @currentView == 'edit'
      view = new MangroveValidation.Views.Islands.EditView({model: @model})
    else if @currentView == 'geometry'
      view = new MangroveValidation.Views.Islands.GeometryEditView({model: @model})

    $('#tabbed-content').html(view.render().el)

    return this
