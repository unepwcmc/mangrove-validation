MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.IndexView extends Backbone.View
  template: JST["backbone/templates/layers/index"]

  initialize: () ->
    @options.layers.bind('reset', @addAll)

  addAll: () =>
    @options.layers.each(@addOne)

  addOne: (layer) =>
    view = new MangroveValidation.Views.Layers.LayerView({model : layer})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(layers: @options.layers.toJSON() ))
    @addAll()

    return this
