MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.LayerView extends Backbone.View
  template: JST["backbone/templates/layers/layer"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
