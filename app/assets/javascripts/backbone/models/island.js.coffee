class MangroveValidation.Models.Island extends Backbone.Model
  paramRoot: 'island'

  defaults:
    name: null

class MangroveValidation.Collections.IslandsCollection extends Backbone.Collection
  model: MangroveValidation.Models.Island

  url: ->
    params = {}
    params.query = @query if @query
    params.id = @island_id if @island_id

    if _.isEmpty(params)
      '/islands'
    else
      "/islands?#{$.param(params)}"

  # Get the islands for the given search term
  search: (query) ->
    if(@query == query)
      return false

    @query = query
    @fetch({add: false})

  # Gets the island for the given ID
  # Returns the only island
  getAndResetById: (island_id) ->
    if(@island_id == island_id)
      return false

    @island_id = island_id
    @fetch({add: false})
    @get(island_id)
