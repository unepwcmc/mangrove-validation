MangroveValidation.Views.Islands ||= {}

# Side panel view of island,
# manages display of show/edit/geom_edit sub-views
class MangroveValidation.Views.Islands.IslandView extends Backbone.View
  template: JST["backbone/templates/islands/island"]

  initialize: ->
    # Bind to island events
    @model.on('change', @render)

  tagName: "div"

  render: =>
    $(@el).html(@template(@model.toJSON() ))

    view = new MangroveValidation.Views.Islands.EditView({model: @model})

    $('#tabbed-content').html(view.render().el)

    return this
