MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.IndexView extends Backbone.View
  template: JST["backbone/templates/islands/index"]

  initialize: () ->
    #@options.islands.bind('reset', @addAll)

  addAll: () =>
    @options.islands.each(@addOne)

  addOne: (island) =>
    view = new MangroveValidation.Views.Islands.IslandView({model : island})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(islands: @options.islands.toJSON() ))
    @addAll()

    return this
