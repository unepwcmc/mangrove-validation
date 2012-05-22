MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.NewView extends Backbone.View
  template: JST["backbone/templates/layers/new"]

  events:
    "submit #new-layer": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (layer) =>
        @model = layer
        window.location.hash = "/#{@model.id}"

      error: (layer, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
