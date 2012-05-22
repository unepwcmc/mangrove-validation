MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.EditView extends Backbone.View
  template : JST["backbone/templates/layers/edit"]

  events :
    "submit #edit-layer" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (layer) =>
        @model = layer
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
