# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  # Tooltips
  $('#map_menu .btn').tooltip({placement: 'bottom'})

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
      
      # Current action
      window.VALIDATION.currentAction = null
      
      $('#main_menu .submit-or-erase').addClass('hide')
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    else
      window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#08c', fillColor: '#08c'}))
      window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

      # Current action
      window.VALIDATION.currentAction = 'validate'

      $('#main_menu .submit-or-erase').removeClass('hide')

  $('#main_menu .add-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Add new area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-danger').addClass('btn-success')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#46a546', fillColor: '#46a546'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    # Current action
    window.VALIDATION.currentAction = 'add'

    $('#main_menu .submit-or-erase').removeClass('hide')
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')

  $('#main_menu .delete-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Delete area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-success').addClass('btn-danger')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#9d261d', fillColor: '#9d261d'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    # Current action
    window.VALIDATION.currentAction = 'delete'

    $('#main_menu .submit-or-erase').removeClass('hide')
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')

  $('#main_menu .spotted-error').click ->
    if $('#main_menu .spotted-error').hasClass('active')
      $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Spotted error?').button('toggle')
      $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-success btn-danger').addClass('btn-info')

      window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
      window.VALIDATION.mapPolygon = null

      # Current action
      window.VALIDATION.currentAction = null

      $('#main_menu .submit-or-erase').addClass('hide')
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    else
      $('#helpModal').modal('show')

  $('#main_menu .submit-polygon').click ->
    unless $(this).hasClass('disabled')
      $('#submitModal .modal-body').removeClass('alert-error alert-success').find('.message').html('Please enter your email so we can attribute your contribution')
      $('#submitModal .modal-footer .submit-data').button('reset')
      $('#submitModal').modal('show')

  $('#main_menu .erase-polygon').click ->
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    window.VALIDATION.mapPolygon.getPath().clear()

  # Map menu buttons
  $('#map_menu .zoom-in').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() + 1)

  $('#map_menu .zoom-out').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() - 1)

  $('#map_menu .hide-data-layers').click ->
    $(this).siblings().removeClass('btn-primary')
    $(this).addClass('btn-danger')
    window.VALIDATION.mangroves.hide()
    window.VALIDATION.mangroves_validated.hide()
    window.VALIDATION.corals.hide()
    window.VALIDATION.corals_validated.hide()

    window.VALIDATION.selectedLayer = null

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .actions').addClass('hide')
      $('#main_menu .select-layer').removeClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon

  $('#map_menu .show-mangroves').click ->
    $(this).siblings().removeClass('btn-primary btn-danger')
    $(this).addClass('btn-primary')
    window.VALIDATION.mangroves.show()
    window.VALIDATION.mangroves_validated.show()
    window.VALIDATION.corals.hide()
    window.VALIDATION.corals_validated.hide()

    window.VALIDATION.selectedLayer = 'mangrove'

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .actions').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon

  $('#map_menu .show-corals').click ->
    $(this).siblings().removeClass('btn-primary btn-danger')
    $(this).addClass('btn-primary')
    window.VALIDATION.mangroves.hide()
    window.VALIDATION.mangroves_validated.hide()
    window.VALIDATION.corals.show()
    window.VALIDATION.corals_validated.show()

    window.VALIDATION.selectedLayer = 'coral'

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .actions').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon

  # Submit modal
  $('#submitModal .submit-data').click ->
    $(this).button('loading')
    $('#submitModal .modal-footer .close-modal').addClass('disabled')
    $('#submitModal .modal-header .close').addClass('hide')

    # Fill form
    $("form#new_layer input#layer_polygon").val ->
      coordinates = []
      path = window.VALIDATION.mapPolygon.getPath()
      path.forEach (coordinate) ->
        coordinates.push("#{coordinate.lng()} #{coordinate.lat()}")
      coordinates.push("#{path.getAt(0).lng()} #{path.getAt(0).lat()}") # Close the polygon
      "#{coordinates.join(',')}"

    $("form#new_layer input#layer_name").val(window.VALIDATION.selectedLayer)
    $("form#new_layer input#layer_action").val(window.VALIDATION.currentAction)

    # Remove event for closing the modal
    window.VALIDATION.submitModalEvents['submitModal'] = $('#submitModal').data('events').click[0]
    $('#submitModal').undelegate('[data-dismiss="modal"]', 'click.dismiss.modal', window.VALIDATION.submitModalEvents['submitModal']).delegate '[data-dismiss="modal"]', 'click.dismiss.modal', (event) ->
      event.preventDefault()

    # Remove event for clicking on the backdrop
    window.VALIDATION.submitModalEvents['modal-backdrop'] = $('.modal-backdrop').data('events').click[0]
    $('.modal-backdrop').unbind('click', window.VALIDATION.submitModalEvents['modal-backdrop']).click ->
      event.preventDefault()
    
    # Remove event for clicking on the keyboard ESC
    window.VALIDATION.submitModalEvents['document'] = $(document).data('events').keyup[0]
    $(document).off('keyup.dismiss.modal', window.VALIDATION.submitModalEvents['document'])

window.VALIDATION.initializeGoogleMaps = ->
  # Google Maps
  window.VALIDATION.map = new google.maps.Map(document.getElementById('map_canvas'), window.VALIDATION.mapOptions)

  google.maps.event.addListener window.VALIDATION.map, 'zoom_changed', ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom && window.VALIDATION.selectedLayer
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      $('#main_menu .actions').removeClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon
    else if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .select-layer').removeClass('hide')
      $('#main_menu .actions').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon
    else
      $('#main_menu .zoom').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      $('#main_menu .actions').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon

  # CartoDB Layers
  # Mangroves unverified layer
  window.VALIDATION.mangroves_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=0 AND status=0"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#FF8800;polygon-opacity:0.35;line-width:0}"
    # map_style: true

  window.VALIDATION.mangroves = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.mangroves_params)

  # Mangroves validated layer
  window.VALIDATION.mangroves_validated_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=0 AND status=1"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#FF8800;polygon-opacity:0.65;line-width:0}"
    # map_style: true

  window.VALIDATION.mangroves_validated = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.mangroves_validated_params)

  # Corals unverified layer
  window.VALIDATION.corals_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=1 AND status=0"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#FDFD34;polygon-opacity:0.7;line-opacity:1}"
    # map_style: true

  window.VALIDATION.corals = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.corals_params)
  window.VALIDATION.corals.hide() # Default hidden

  # Corals validated layer
  window.VALIDATION.corals_validated_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=1 AND status=1"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#491C16;polygon-opacity:0.7;line-opacity:1}"
    # map_style: true

  window.VALIDATION.corals_validated = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.corals_validated_params)
  window.VALIDATION.corals_validated.hide() # Default hidden

  google.maps.event.addListener window.VALIDATION.map, 'click', (event) ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom && window.VALIDATION.mapPolygon && window.VALIDATION.selectedLayer
      path = window.VALIDATION.mapPolygon.getPath()
      path.push(event.latLng)
      if path.length > 0
        $('#main_menu .erase-polygon').removeClass('disabled')
      if path.length > 2
        $('#main_menu .submit-polygon').removeClass('disabled')
