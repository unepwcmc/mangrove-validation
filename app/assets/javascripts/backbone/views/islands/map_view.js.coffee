MangroveValidation.Views.Islands ||= {}

# = Map View
# Creates and manages the map and showing of layers
class MangroveValidation.Views.Islands.MapView extends Backbone.View
  template: JST["backbone/templates/islands/map"]

  initialize: (islands) ->
    @islands = islands
    # Google Maps
    @map = new google.maps.Map($('#map_canvas')[0], window.VALIDATION.mapOptions)

    # Bus binding
    MangroveValidation.bus.bind("zoomIn:MapControlsView", @zoomIn)
    MangroveValidation.bus.bind("zoomOut:MapControlsView", @zoomOut)
    MangroveValidation.bus.bind("zoomToBounds", @zoomToBounds)

    # Bind zoom behavior
    google.maps.event.addListener @map, 'zoom_changed', @handleZoomChange

    # CartoDB Layers
    ## Show all islands in subtle colour
    @showAllSubtleLayers()

    # Bind to island events
    @islands.on('reset', @render)

    google.maps.event.addListener @map, 'click', @handleMapClick

  # Adds cartodb layer of all islands in subtle colour
  showAllSubtleLayers: ->
    query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE}"
    color = '#00FFFF'
    layerParams =
      map_canvas: 'map_canvas'
      map: @map
      user_name: 'carbon-tool'
      table_name: window.CARTODB_TABLE
      query: query
      tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.5;line-width:0;line-opacity:0.6;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:8}"

    @allIslandsLayer = new google.maps.CartoDBLayer layerParams

  renderCurrentIslands: ->
    islandsIds = @islands.map (island) ->
      island.get('id')

    if _.isEmpty(islandsIds)
      query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE}"
    else
      query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE island_id in (#{islandsIds.join()})"
      
    color = '#FFFF00'

    layerParams =
      map_canvas: 'map_canvas'
      map: @map
      user_name: 'carbon-tool'
      table_name: window.CARTODB_TABLE
      query: query
      tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.9;line-width:0;line-opacity:0.8;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:8}"

    @currentIslandLayer = new google.maps.CartoDBLayer layerParams

  handleMapClick: (event) =>
    if true #TODO: Not in geom edit mode
      @navigateToIslandAtPoint(event.latLng)
    else
      if @map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer] && window.VALIDATION.mapPolygon && window.VALIDATION.selectedLayer != 'hide'
        path = window.VALIDATION.mapPolygon.getPath()
        path.push(event.latLng)
        if path.length > 0
          $('#main_menu .erase-polygon').removeClass('disabled')
        if path.length > 2
          $('#main_menu .submit-polygon').removeClass('disabled')

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

  handleZoomChange: () =>
    if window.VALIDATION.selectedLayer != 'hide' && @map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer]
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon
    else if @map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer]
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .select-layer').removeClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon
    else
      $('#main_menu .zoom').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon

  render: =>
    @renderCurrentIslands()
    this

  zoomIn: =>
    @map.setZoom(@map.getZoom() + 1)

  zoomOut: =>
    @map.setZoom(@map.getZoom() - 1)

  zoomToBounds: (bounds) =>
    @map.fitBounds(bounds)
