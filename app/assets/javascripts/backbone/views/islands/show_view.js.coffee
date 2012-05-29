MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.ShowView extends Backbone.View
  template: JST["backbone/templates/islands/show"]

  events:
    'click #edit-attributes': 'showEdit'
  
  showEdit: ->
    MangroveValidation.bus.trigger('changeIslandView','edit')

  render: =>
    $(@el).html(@template(@model.toJSON() ))
    return this
