MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.EditView extends Backbone.View
  template : JST["backbone/templates/islands/edit"]
  id: 'island-attributes'

  events :
    "submit #edit-island" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (island) =>
        @model = island
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    @$("form").backboneLink(@model)
    return this
