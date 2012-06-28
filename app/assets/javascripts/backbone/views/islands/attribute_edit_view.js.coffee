MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.AttributeEditView extends Backbone.View
  template : JST["backbone/templates/islands/edit"]
  id: 'island-attributes'

  events :
    "submit #edit-island" : "update"

  update : (e) =>
    e.preventDefault()
    e.stopPropagation()
    @model.getBounds (bounds) =>
      confirm_view = new MangroveValidation.Views.Islands.ConfirmEditView(bounds, @doSave)
      $(@el).append(confirm_view.render().el)

  doSave: =>
    @model.save(null,
      success : (island) =>
        @model = island
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    @$("form").backboneLink(@model)
    return this
