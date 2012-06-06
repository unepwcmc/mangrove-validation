MangroveValidation.Views.Islands ||= {}

# = Map View
# Creates and manages the map and showing of layers
class MangroveValidation.Views.Islands.MapView extends Backbone.View
  template: JST["backbone/templates/islands/map"]

  initialize: (island) ->
    @island = island
    # Google Maps
    @map = new google.maps.Map($('#map_canvas')[0], window.VALIDATION.mapOptions)

    @showLayers = true

    # Bus binding
    MangroveValidation.bus.bind("zoomToBounds", @zoomToBounds)
    MangroveValidation.bus.bind("toggleMapLayers", @toggleMapLayers)
    MangroveValidation.bus.bind("addToMap", @addToMap)

    # Bind to island events
    @island.on('change', @render)

    google.maps.event.addListener @map, 'click', @handleMapClick

    @render()

  # Adds cartodb layer of all islands in subtle colour
  showAllSubtleLayers: ->
    if @showLayers
      unless @originalIslandsLayer?
        # Build the layers if they don't exist
        # Original layer
        query = "SELECT cartodb_id, the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE status='original'"
        color = '#00FFFF'
        layerParams =
          map_canvas: 'map_canvas'
          map: @map
          user_name: 'carbon-tool'
          table_name: window.CARTODB_TABLE
          query: query
          tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.5;line-width:1;line-opacity:0.7;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:3}"

        @originalIslandsLayer = new CartoDBLayer layerParams

        # Validated layer
        query = "SELECT cartodb_id, the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE status='validated'"
        color = '#00FF00'
        layerParams =
          map_canvas: 'map_canvas'
          map: @map
          user_name: 'carbon-tool'
          table_name: window.CARTODB_TABLE
          query: query
          tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.5;line-width:1;line-opacity:0.7;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:3}"

        @validatedLayer = new CartoDBLayer layerParams

      @originalIslandsLayer.show()
      @validatedLayer.show()
    else
      @originalIslandsLayer.hide() if @originalIslandsLayer?
      @validatedLayer.hide() if @originalIslandsLayer?

  renderCurrentIslands: ->
    if @showLayers
      if @island.get('id')
        query = "SELECT cartodb_id, the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE island_id = #{@island.get('id')}"
      else
        @currentIslandLayer.hide() if @currentIslandLayer?
        return

      color = '#FFFF00'

      layerParams =
        map_canvas: 'map_canvas'
        map: @map
        user_name: 'carbon-tool'
        table_name: window.CARTODB_TABLE
        query: query
        tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.6;line-width:2;line-opacity:0.8;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:5}"

      @currentIslandLayer.setMap(null) if @currentIslandLayer?
      @currentIslandLayer = new CartoDBLayer(layerParams)
      @currentIslandLayer.show()
    else
      @currentIslandLayer.hide() if @currentIslandLayer?

  handleMapClick: (event) =>
    if window.VALIDATION.currentAction == null
      @navigateToIslandAtPoint(event.latLng)
    else
      if @map.getZoom() >= window.VALIDATION.minEditZoom
        MangroveValidation.bus.trigger('mapClickAt', event.latLng)
      else
        alert("You can't edit geometry this far out, please zoom in")

  # Asks cartobd for any islands at the given point
  # and navigates to the island show path if one is found
  navigateToIslandAtPoint: (point) ->
    query = "SELECT island_id FROM #{window.CARTODB_TABLE}
      WHERE ST_Intersects(the_geom, ST_GeomFromText('point(#{point.lng()} #{point.lat()})', 4326))
      LIMIT 1"

    $.ajax
      url: "#{window.CARTODB_API_ADDRESS}?q=#{query}"
      success: (data) ->
        if data.rows.length > 0
          # If we find a island, redirect to it
          window.router.navigate("#{data.rows[0].island_id}", true)
        else
          # If no island, redirect to root '/'
          window.router.navigate("/", true)

  render: =>
    @showAllSubtleLayers()
    @renderCurrentIslands()
    this

  addToMap: (object) =>
    object.setMap(@map)

  zoomToBounds: (bounds) =>
    @map.fitBounds(bounds)

  # show or hide map overlays
  toggleMapLayers: (enable) =>
    @showLayers = enable
    @render()
