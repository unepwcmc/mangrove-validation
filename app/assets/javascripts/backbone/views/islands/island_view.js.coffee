MangroveValidation.Views.Islands ||= {}

# Side panel view of island,
# manages display of show/edit/geom_edit sub-views
class MangroveValidation.Views.Islands.IslandView extends Backbone.View
  template: JST["backbone/templates/islands/island"]

  initialize: (options) ->
    # The sub-view to show can be passed as a param, default show
    @currentView = options.view
    @currentView ||= 'show'

    # Bind to island events
    @model.on('change', @render)

  tagName: "div"

  render: =>
    $(@el).html(@template(@model.toJSON() ))

    # Switch to render the sub view
    if @currentView == 'edit'
      view = new MangroveValidation.Views.Islands.EditView({model: @model})
    else if @currentView == 'show'
      view = new MangroveValidation.Views.Islands.ShowView({model: @model})

    $('#tabbed-content').html(view.render().el)

    return this
