MangroveValidation.Views.Islands ||= {}

# = Search View
# Handles the search box
class MangroveValidation.Views.Islands.SearchView extends Backbone.View
  el: '#search-box'

  events:
    'keyup #search-query': 'doSearch'

  initialize: (islands) ->
    @islands = islands

  doSearch: =>
    @islands.search(this.$('#search-query').val())
