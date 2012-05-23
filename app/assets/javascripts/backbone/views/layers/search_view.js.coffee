MangroveValidation.Views.Layers ||= {}

# = Search View
# Handles the search box
class MangroveValidation.Views.Layers.SearchView extends Backbone.View
  el: '#search-box'

  events:
    'keyup #search-query': 'doSearch'

  initialize: (layers) ->
    @layers = layers

  doSearch: =>
    @layers.search(this.$('#search-query').val())
