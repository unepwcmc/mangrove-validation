class MangroveValidation.Models.Island extends Backbone.Model
  paramRoot: 'island'

  defaults:
    name: null

class MangroveValidation.Collections.IslandsCollection extends Backbone.Collection
  model: MangroveValidation.Models.Island
  url: '/islands'

  # Get the islands for the given search term
  search: (query) ->
    
    #TODO actually search
    @reset([{name: 'result 1', island_id:1}, {name: 'result 2', island_id: 5}])

  # Gets the island for the given ID, resets the collection to just that island and returns it
  getAndResetBy: (id) ->
    
    #TODO actually get the island from the DB
    @reset([{name: 'result 1', island_id:1}])
    return @.models[0]
