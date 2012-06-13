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
    @bindTo(MangroveValidation.bus, "zoomToBounds", @zoomToBounds)
    @bindTo(MangroveValidation.bus, "toggleMapLayers", @toggleMapLayers)
    @bindTo(MangroveValidation.bus, "addToMap", @addToMap)
    @bindTo(MangroveValidation.bus, "layersChanged", @redrawLayers)

    # Bind to island events
    @island.on('change', @render)

    google.maps.event.addListener @map, 'click', @handleMapClick

    @render()

  # Adds cartodb layer of all islands in subtle colour
  showIslandOverlays: ->
    if @showLayers
      # Build the layers if they don't exist
      # Original layer
      query = "SELECT cartodb_id, the_geom_webmercator, status, island_id FROM #{window.CARTODB_TABLE} WHERE status IS NOT NULL"
      color = '#00FFFF'
      carto_css = "##{window.CARTODB_TABLE}{polygon-fill:#{color};line-color:#{color};polygon-opacity:0.5;line-width:1;line-opacity:0.7;}
          ##{window.CARTODB_TABLE} [status = 'validated'] {line-color: #00FF00;polygon-fill: #00FF00;}
          ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:3}"

      # Add island highlighting
      if @island.get('id')
        carto_css += "##{window.CARTODB_TABLE} [island_id = #{@island.get('id')}] {line-color: #FFFF00;polygon-fill: #FFFF00;}
          ##{window.CARTODB_TABLE} [island_id = #{@island.get('id')}][status='validated'] {line-color: #33FF33;polygon-fill: #33FF33;}"

      layerParams =
        map_canvas: 'map_canvas'
        map: @map
        user_name: 'carbon-tool'
        table_name: window.CARTODB_TABLE
        query: query
        tile_style: carto_css

      # Remove existing layer and show new
      @allIslandsLayer.setMap(null) if @allIslandsLayer?
      @allIslandsLayer = new CartoDBLayer layerParams
      @allIslandsLayer.show()
    else
      @allIslandsLayer.hide() if @allIslandsLayer?

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
    @showIslandOverlays()
    this

  addToMap: (object) =>
    object.setMap(@map)

  zoomToBounds: (bounds) =>
    @map.fitBounds(bounds)

  # show or hide map overlays
  toggleMapLayers: (enable) =>
    @showLayers = enable
    @render()

  # Redraw the layers
  redrawLayers: () =>
    # Remove existing layers and set to null to force redraws
    @allIslandsLayer.hide() && @allIslandsLayer = null if @allIslandsLayer?
    @currentIslandLayer.hide() && @currentIslandLayer = null if @currentIslandLayer?

    @render()

