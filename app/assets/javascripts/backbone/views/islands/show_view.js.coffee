MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.ShowView extends Backbone.View
  template: JST["backbone/templates/islands/show"]

  initialize: ->
    @model.bind('reset', @render)

  render: =>
    $(@el).html(@template(@model.toJSON() ))
    return this
