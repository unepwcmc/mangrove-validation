MangroveValidation.Views.Layers ||= {}

# = Search View
# Visualise search results
class MangroveValidation.Views.Layers.SearchResultsView extends Backbone.View
  el: '#search-results'
  template: JST["backbone/templates/layers/search_results"]

  initialize: (layers) ->
    @layers = layers

    # Bind to layer events
    @layers.on('reset', @render)

  render: =>
    $(this.el).html(@template({results: @layers.toJSON()}))
    $(this.el).show()

