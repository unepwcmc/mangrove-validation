class MangroveValidation.Models.Island extends Backbone.Model
  paramRoot: 'island'

  defaults:
    name: null

  url: ->
    "http://carbon-tool.cartodb.com/api/v2/sql?q=SELECT island_id AS id, name FROM gid_development_copy WHERE island_id = #{@id} LIMIT 1&api_key=#{window.CARTODB_API_KEY}"

  parse: (resp) ->
    resp.rows[0]

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
