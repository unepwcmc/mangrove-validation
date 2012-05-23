MangroveValidation.Views.Layers ||= {}

# = Map View
# Creates and manages the map and showing of layers
class MangroveValidation.Views.Layers.MapView extends Backbone.View
  template: JST["backbone/templates/layers/map"]

  initialize: (layers) ->
    @layers = layers
    # Google Maps
    @map = new google.maps.Map($('#map_canvas')[0], window.VALIDATION.mapOptions)

    # Bus binding
    MangroveValidation.bus.bind("zoomIn:MapControlsView", @zoomIn)
    MangroveValidation.bus.bind("zoomOut:MapControlsView", @zoomOut)

    # Bind zoom behavior
    google.maps.event.addListener @map, 'zoom_changed', @handleZoomChange

    # CartoDB Layers
    ## Show all layers in subtle colour
    @showAllSubtleLayers()

    # Bind to layer events
    @layers.on('reset', @render)

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

    @allLayersLayer = new google.maps.CartoDBLayer $.extend({}, layerParams)

  renderCurrentLayers: ->
    # Get the layer IDs to filter by
    layerIds = @layers.map (layer) ->
      layer.get('layer_id')
    query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name in (#{layerIds.join()})"
    color = '#FF0000'
    layerParams =
      map_canvas: 'map_canvas'
      map: @map
      user_name: 'carbon-tool'
      table_name: window.CARTODB_TABLE
      query: query
      tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{color};polygon-opacity:0.9;line-width:0;line-opacity:0.8;line-color:#{color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:8}"

    @allLayersLayer = new google.maps.CartoDBLayer $.extend({}, layerParams)

  handleMapClick: (event) =>
    if @map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer] && window.VALIDATION.mapPolygon && window.VALIDATION.selectedLayer != 'hide'
      path = window.VALIDATION.mapPolygon.getPath()
      path.push(event.latLng)
      if path.length > 0
        $('#main_menu .erase-polygon').removeClass('disabled')
      if path.length > 2
        $('#main_menu .submit-polygon').removeClass('disabled')

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
    @renderCurrentLayers()
    this



  zoomIn: =>
    @map.setZoom(@map.getZoom() + 1)

  zoomOut: =>
    @map.setZoom(@map.getZoom() - 1)
