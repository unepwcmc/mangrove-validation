MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.AttributeEditView extends Backbone.View
  template : JST["backbone/templates/islands/edit"]
  id: 'island-attributes'

  events :
    "submit #edit-island" : "update"

  update : (e) =>
    e.preventDefault()
    e.stopPropagation()
    if @model.isNew()
      @doSave()
    else
      # if model isn't new, check user intends to edit entire extent
      @model.getBounds (bounds) =>
        confirm_view = new MangroveValidation.Views.Islands.ConfirmEditView(bounds, @doSave)
        $(@el).append(confirm_view.render().el)

  doSave: =>
    @model.save(null,
      success : (island) =>
        @model = island
        window.router.navigate("#{@model.get('id')}/", true)
        MangroveValidation.bus.trigger('changeIslandView','show')
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    @$("form").backboneLink(@model)
    return this
