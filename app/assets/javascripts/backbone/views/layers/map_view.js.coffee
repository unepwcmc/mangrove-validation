MangroveValidation.Views.Layers ||= {}

class MangroveValidation.Views.Layers.MapView extends Backbone.View
  template: JST["backbone/templates/layers/map"]

  initialize: () ->
    # Google Maps
    @map = new google.maps.Map($('#map_canvas')[0], window.VALIDATION.mapOptions)

    # Bind zoom behavior
    google.maps.event.addListener @map, 'zoom_changed', @handleZoomChange

    # CartoDB Layers
    _.each window.VALIDATION.layers, (layer, layer_name) =>
      _.each layer.editions, (edition_properties, edition) =>
        name = switch edition
          when 'base' then layer_name
          when 'validated' then "#{layer_name}_validated"
          when 'added' then "#{layer_name}_added"

        if edition_properties.action?
          query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=#{layer.id} AND status=#{edition_properties.status} AND action=#{edition_properties.action}"
        else
          query = "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=#{layer.id} AND status=#{edition_properties.status}"

        window.VALIDATION["#{name}_params"] =
          map_canvas: 'map_canvas'
          map: @map
          user_name: 'carbon-tool'
          table_name: window.CARTODB_TABLE
          query: query
          tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#{edition_properties.color};polygon-opacity:0.67;line-width:0;line-opacity:0.8;line-color:#{edition_properties.color}} ##{window.CARTODB_TABLE} [zoom <= 7] {line-width:2} ##{window.CARTODB_TABLE} [zoom <= 4] {line-width:8}"

        window.VALIDATION[name] = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION["#{name}_params"])
        window.VALIDATION[name].hide() if edition_properties.hide

    google.maps.event.addListener @map, 'click', @handleMapClick

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
