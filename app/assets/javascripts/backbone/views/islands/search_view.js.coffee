MangroveValidation.Views.Islands ||= {}

# = Search View
# Handles the search box
class MangroveValidation.Views.Islands.SearchView extends Backbone.View
  events:
    'keyup input[type=text]': 'doSearch'

  initialize: (collection, element, onSelect) ->
    @collection = collection
    @setElement(element,true)
    @onSelect = onSelect

  setReallocateTarget: (obj) ->
    $('#to_island_name').text(obj.name)

  setSearchTarget: (obj) ->
    window.router.navigate("#{obj.id}", true)

  doSearch: =>
    @$el.children("input[type=text]").typeahead
      # Override typeahead's matcher
      # It can't handle the fact that what we're requesting
      # is different from what we're getting back (sending ID,
      # getting name).
      matcher: (item) ->
        return true
      source: (typeahead, query) =>
        @collection.search query, (collection, response) ->
          typeahead.process(response)
      items: 4
      property: 'name'
      onselect: @onSelect
