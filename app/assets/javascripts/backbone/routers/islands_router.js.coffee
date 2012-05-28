class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    #@islands.fetch()

    # Base layout
    @baseLayout()

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    @view = new MangroveValidation.Views.Islands.IndexView(islands: @islands)
    $("#islands").html(@view.render().el)

    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

  show: (id) ->
    island = new MangroveValidation.Models.Island({id: id})
    island.fetch()

    @view = new MangroveValidation.Views.Islands.ShowView(model: island)
    $("#right-panel").html(@view.render().el)

  edit: (id) ->
    island = @islands.get(id)

    @view = new MangroveValidation.Views.Islands.EditView(model: island)
    $("#islands").html(@view.render().el)

  baseLayout: ->
    # Search box
    typeahead_items = 4

    $("#search").typeahead
      source: (typeahead, query) ->
        $.ajax
          url: "http://carbon-tool.cartodb.com/api/v2/sql?q=SELECT island_id AS id, name FROM gid_development_copy WHERE name ILIKE '%25#{query}%25' GROUP BY island_id, name LIMIT #{typeahead_items}&api_key=#{window.CARTODB_API_KEY}"
          success: (data) =>
            typeahead.process(data['rows'])
      items: typeahead_items
      property: 'name'
      onselect: (obj) ->
        window.router.navigate("#{obj.id}", true)

    @mapView = new MangroveValidation.Views.Islands.MapView(@islands)
    @mapControlsView = new MangroveValidation.Views.Islands.MapControlsView()
    @searchResultsView = new MangroveValidation.Views.Islands.SearchResultsView(@islands)
