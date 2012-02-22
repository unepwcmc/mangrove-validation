# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('[href^=#]').click (e) ->
    e.preventDefault()

  window.VALIDATION.initializeGoogleMaps()
  $('#landingModal').modal({backdrop: true, show: true})
  $('#helpModal').modal({backdrop: true, show: false})

  # Main menu buttons
  $('#main_menu .validate').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Spotted error?')
    $('#main_menu .spotted-error').button('toggle') if $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-success btn-danger').addClass('btn-info')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    if $(this).hasClass('active')
      window.VALIDATION.mapPolygon = null
      $('#main_menu .submit-polygon').addClass('disabled hide')
    else
      window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#08c', fillColor: '#08c'}))
      window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)
      $('#main_menu .submit-polygon').removeClass('hide')

  $('#main_menu .add-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Add new area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-danger').addClass('btn-success')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#46a546', fillColor: '#46a546'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    $('#main_menu .submit-polygon').addClass('disabled').removeClass('hide')

  $('#main_menu .delete-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Delete area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-success').addClass('btn-danger')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#9d261d', fillColor: '#9d261d'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    $('#main_menu .submit-polygon').addClass('disabled').removeClass('hide')

  $('#main_menu .spotted-error').click ->
    if $('#main_menu .spotted-error').hasClass('active')
      $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Spotted error?').button('toggle')
      $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-success btn-danger').addClass('btn-info')

      window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
      window.VALIDATION.mapPolygon = null
      $('#main_menu .submit-polygon').addClass('disabled hide')
    else
      $('#helpModal').modal('show')

  $('#main_menu .submit-polygon').click ->
    unless $(this).hasClass('disabled')
      $('#submitModal').modal('show')

  # Map menu buttons
  $('#map_menu .zoom-in').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() + 1)

  $('#map_menu .zoom-out').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() - 1)

  $('#map_menu .hide-data-layers').click ->
    window.VALIDATION.mangroves.hide()
    window.VALIDATION.corals.hide()

  $('#map_menu .show-mangroves').click ->
    window.VALIDATION.mangroves.show()
    window.VALIDATION.corals.hide()

  $('#map_menu .show-corals').click ->
    window.VALIDATION.mangroves.hide()
    window.VALIDATION.corals.show()

  # Submit modal
  $('#submitModal .submit-data').click ->
    $('#submitModal .modal-body .progress').removeClass('hide')
    # Remove event for closing the modal
    $('#submitModal').undelegate('[data-dismiss="modal"]', 'click.dismiss.modal').delegate '[data-dismiss="modal"]', 'click.dismiss.modal', (event) ->
      event.preventDefault()
    # Remove event for clicking on the backdrop
    $('.modal-backdrop').unbind('click').click ->
      event.preventDefault()
    # Remove event for clicking on the keyboard ESC
    $(document).off('keyup.dismiss.modal')

window.VALIDATION.initializeGoogleMaps = ->
  # Google Maps
  window.VALIDATION.map = new google.maps.Map(document.getElementById('map_canvas'), window.VALIDATION.mapOptions)

  google.maps.event.addListener window.VALIDATION.map, 'zoom_changed', ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .actions').removeClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon
    else
      $('#main_menu .zoom').removeClass('hide')
      $('#main_menu .actions').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon

  # CartoDB Layers
  window.VALIDATION.mangroves = new google.maps.CartoDBLayer({
    map_canvas: 'map_canvas',
    map: window.VALIDATION.map,
    user_name: 'carbon-tool',
    table_name: 'fake_coral_data',
    #query: "SELECT cartodb_id,the_geom FROM test",
    #tile_style: "#test{line-color:#f00;line-width:1;line-opacity:0.6;polygon-opacity:0.6;}",
    #map_key: "6087bc5111352713a81a48491078f182a0541f6c",
    #map_style: true,
    #infowindow: "SELECT cartodb_id,the_geom_webmercator,description FROM test WHERE cartodb_id={{feature}}",
    #auto_bound: true,
    #debug: false
  })

  window.VALIDATION.corals = new google.maps.CartoDBLayer({
    map_canvas: 'map_canvas',
    map: window.VALIDATION.map,
    user_name: "xavijam",
    table_name: 'test',
    query: "SELECT cartodb_id,the_geom_webmercator,description FROM test",
    tile_style: "#test{line-color:#0f0;line-width:1;line-opacity:0.6;polygon-opacity:0.6;}",
    map_key: "6087bc5111352713a81a48491078f182a0541f6c",
    map_style: true,
    infowindow: "SELECT cartodb_id,the_geom_webmercator,description FROM test WHERE cartodb_id={{feature}}",
    auto_bound: true,
    debug: false
  })
  # Default hidden
  window.VALIDATION.corals.hide()

  google.maps.event.addListener window.VALIDATION.map, 'click', (event) ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom && window.VALIDATION.mapPolygon
      path = window.VALIDATION.mapPolygon.getPath()
      path.push(event.latLng)
      if path.length > 2
        $('#main_menu .submit-polygon').removeClass('disabled')
