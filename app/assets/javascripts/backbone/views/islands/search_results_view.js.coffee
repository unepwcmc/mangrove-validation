MangroveValidation.Views.Islands ||= {}

# = Search View
# Visualise search results
class MangroveValidation.Views.Islands.SearchResultsView extends Backbone.View
  el: '#search-results'
  template: JST["backbone/templates/islands/search_results"]

  initialize: (islands) ->
    @islands = islands

    # Bind to island events
    @islands.on('reset', @render)

  render: =>
    $(this.el).html(@template({results: @islands.toJSON()}))
    $(this.el).show()

