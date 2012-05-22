MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.ShowView extends Backbone.View
  template: JST["backbone/templates/layers/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
