class MangroveValidation.Routers.LayersRouter extends Backbone.Router
  initialize: (options) ->
    @layers = new MangroveValidation.Collections.LayersCollection()
    @layers.reset options.layers

  routes:
    "new"      : "newLayer"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newLayer: ->
    @view = new MangroveValidation.Views.Layers.NewView(collection: @layers)
    $("#layers").html(@view.render().el)

  index: ->
    @view = new MangroveValidation.Views.Layers.IndexView(layers: @layers)
    $("#layers").html(@view.render().el)

  show: (id) ->
    layer = @layers.get(id)

    @view = new MangroveValidation.Views.Layers.ShowView(model: layer)
    $("#layers").html(@view.render().el)

  edit: (id) ->
    layer = @layers.get(id)

    @view = new MangroveValidation.Views.Layers.EditView(model: layer)
    $("#layers").html(@view.render().el)
