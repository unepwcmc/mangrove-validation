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

    # Map display variables
    @unselected_color = '#00FFFF'
    @selected_color = '#FFFF00'
    @unselected_validated_color = '#00FF00'
    @selected_validated_color = '#00FF00'

    @base_carto_css = "##{window.CARTODB_TABLE}{polygon-fill:#{@unselected_color};line-color:#{@unselected_color};polygon-opacity:0.1;line-width:1;line-opacity:0.7;}
        ##{window.CARTODB_TABLE} [status = 'validated'] {line-color: #{@unselected_validated_color};polygon-fill: #{@unselected_validated_color};}
        ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:3}"

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
      if !@allIslandsLayer? || @currentlyShownIslandId != @island.get('id')
        # If layer doesn't exist, or the current island has changed, build representative cartoCSS

        @currentlyShownIslandId = @island.get('id')

        # Add island highlighting (or don't)
        if @currentlyShownIslandId?
          carto_css = @base_carto_css + "##{window.CARTODB_TABLE} [island_id = #{@currentlyShownIslandId}] {line-color: #{@selected_color};polygon-fill:#{@selected_color}; polygon-opacity:0.4}
            ##{window.CARTODB_TABLE} [island_id = #{@island.get('id')}][status='validated'] {line-color: #{@selected_validated_color};polygon-fill: #{@selected_validated_color};}"
        else
          carto_css = @base_carto_css

        # base layer query
        query = "SELECT cartodb_id, the_geom_webmercator, status, island_id FROM #{window.CARTODB_TABLE} WHERE status IS NOT NULL"

        siteOptions =
          getTileUrl: (coord, zoom) ->
            console.log "http://carbon-tool.cartodb.com/tiles/#{window.CARTODB_TABLE}/#{zoom}/#{coord.x}/#{coord.y}.png?sql=#{query}&style=#{encodeURIComponent(carto_css)}"
            "http://carbon-tool.cartodb.com/tiles/#{window.CARTODB_TABLE}/#{zoom}/#{coord.x}/#{coord.y}.png?sql=#{query}&style=#{encodeURIComponent(carto_css)}"
          tileSize: new google.maps.Size(256, 256)

        @allIslandsLayer.unbindAll() if @allIslandsLayer?
        @allIslandsLayer = new google.maps.ImageMapType(siteOptions)

      # Show the layer
      @map.overlayMapTypes.setAt 0, @allIslandsLayer
    else
      @map.overlayMapTypes.setAt 0, null

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
      dataType: 'json'
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
    if @allIslandsLayer?
      @allIslandsLayer.unbindAll()
      @allIslandsLayer = null

    @render()

