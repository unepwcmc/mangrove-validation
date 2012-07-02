MangroveValidation.Views.Islands ||= {}

# Side panel view when nothing is selected
class MangroveValidation.Views.Islands.IndexView extends Backbone.View
  template: JST["backbone/templates/islands/no_island_selected"]

  initialize: () ->

  render: =>
    @$el.html(@template())

    return this
