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

  # Main menu buttons
  $('#map_menu .help').click ->
    $('#landingModal .modal-footer .btn').html('Continue')
    $('#landingModal').modal('show')

  $('#main_menu .zoom').click ->
    window.VALIDATION.map.panTo(window.VALIDATION.mapOptions.center)
    window.VALIDATION.map.setZoom(window.VALIDATION.minEditZoom)

  $('#main_menu .validate').click ->
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
      window.VALIDATION.currentAction = 0#'validate' (check app/models/enumerations/actions.rb)

      $('#main_menu .submit-or-erase').removeClass('hide').css('right', '182px')
      $('#main_menu .edit-area').html('<i class="icon-pencil icon-white"></i> Edit area <span class="caret"></span>').removeClass('btn-success btn-danger active').addClass('btn-warning')
      $('#main_menu ul.dropdown-menu li.divider').addClass('hide').next('li').addClass('hide')

  $('#main_menu .cancel-edit-area').click ->
    if($('#main_menu .edit-area').hasClass('active'))
      window.VALIDATION.mapPolygon = null
      
      # Current action
      window.VALIDATION.currentAction = null
      
      $('#main_menu .submit-or-erase').addClass('hide')
      $('#main_menu .edit-area').html('<i class="icon-pencil icon-white"></i> Edit area <span class="caret"></span>').removeClass('btn-success btn-danger active').addClass('btn-warning')
      $(this).parent('li').addClass('hide').prev('li.divider').addClass('hide')

  $('#main_menu .add-area').click ->
    $('#main_menu .edit-area').html('<i class="icon-plus icon-white"></i> Add new area <span class="caret"></span>').removeClass('btn-warning btn-danger').addClass('btn-success')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#46a546', fillColor: '#46a546'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    # Current action
    window.VALIDATION.currentAction = 1#'add' (check app/models/enumerations/actions.rb)

    $('#main_menu .submit-or-erase').removeClass('hide').css('right', '-5px')
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    $('#main_menu .edit-area').addClass('active')
    $('#main_menu ul.dropdown-menu li').removeClass('hide')

  $('#main_menu .delete-area').click ->
    $('#main_menu .edit-area').html('<i class="icon-trash icon-white"></i> Delete area <span class="caret"></span>').removeClass('btn-warning btn-success').addClass('btn-danger')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

    # Google Maps Polygon
    window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
    window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#9d261d', fillColor: '#9d261d'}))
    window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

    # Current action
    window.VALIDATION.currentAction = 2 #'delete' (check app/models/enumerations/actions.rb)

    $('#main_menu .submit-or-erase').removeClass('hide').css('right', '-5px')
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    $('#main_menu .edit-area').addClass('active')
    $('#main_menu ul.dropdown-menu li').removeClass('hide')

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
    if($(this).hasClass('active'))
      $(this).removeClass('btn-danger')
      $(this).find('i').removeClass('icon-white')

      if window.VALIDATION.selectedLayer == 0 #'mangrove' (check app/models/enumerations/names.rb)
        window.VALIDATION.mangroves.show()
        window.VALIDATION.mangroves_validated.show()
        window.VALIDATION.corals.hide()
        window.VALIDATION.corals_validated.hide()
      else
        window.VALIDATION.mangroves.hide()
        window.VALIDATION.mangroves_validated.hide()
        window.VALIDATION.corals.show()
        window.VALIDATION.corals_validated.show()
    else
      $(this).addClass('btn-danger')
      $(this).find('i').addClass('icon-white')

      window.VALIDATION.mangroves.hide()
      window.VALIDATION.mangroves_validated.hide()
      window.VALIDATION.corals.hide()
      window.VALIDATION.corals_validated.hide()

  $('#map_menu .show-mangroves').click ->
    $(this).addClass('btn-warning').siblings().removeClass('btn-success')

    unless $('#map_menu .hide-data-layers').hasClass('active')
      window.VALIDATION.mangroves.show()
      window.VALIDATION.mangroves_validated.show()
      window.VALIDATION.corals.hide()
      window.VALIDATION.corals_validated.hide()

    window.VALIDATION.selectedLayer = 0 #'mangrove' (check app/models/enumerations/names.rb)

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .actions').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon

  $('#map_menu .show-corals').click ->
    $(this).addClass('btn-success').siblings().removeClass('btn-warning')

    unless $('#map_menu .hide-data-layers').hasClass('active')
      window.VALIDATION.mangroves.hide()
      window.VALIDATION.mangroves_validated.hide()
      window.VALIDATION.corals.show()
      window.VALIDATION.corals_validated.show()

    window.VALIDATION.selectedLayer = 1 #'coral' (check app/models/enumerations/names.rb)

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom
      $('#main_menu .actions').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon

  $('#map_menu .use-satellite').click ->
    $(this).addClass('btn-info').siblings().removeClass('btn-info')

    window.VALIDATION.map.setOptions({mapTypeId: google.maps.MapTypeId.SATELLITE})

  $('#map_menu .use-hybrid').click ->
    $(this).addClass('btn-info').siblings().removeClass('btn-info')

    window.VALIDATION.map.setOptions({mapTypeId: google.maps.MapTypeId.HYBRID})

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
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom && window.VALIDATION.selectedLayer >= 0
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
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#B15F00;polygon-opacity:0.7;line-width:0}"
    # map_style: true

  window.VALIDATION.mangroves = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.mangroves_params)

  # Mangroves validated layer
  window.VALIDATION.mangroves_validated_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=0 AND status=1"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#FF8800;polygon-opacity:0.7;line-width:0}"
    # map_style: true

  window.VALIDATION.mangroves_validated = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.mangroves_validated_params)

  # Corals unverified layer
  window.VALIDATION.corals_params =
    map_canvas: 'map_canvas'
    map: window.VALIDATION.map
    user_name: 'carbon-tool'
    table_name: window.CARTODB_TABLE
    query: "SELECT the_geom_webmercator FROM #{window.CARTODB_TABLE} WHERE name=1 AND status=0"
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#A1A121;polygon-opacity:0.7;line-width:0}"
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
    tile_style: "##{window.CARTODB_TABLE}{polygon-fill:#fdfd34;polygon-opacity:0.7;line-width:0}"
    # map_style: true

  window.VALIDATION.corals_validated = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION.corals_validated_params)
  window.VALIDATION.corals_validated.hide() # Default hidden

  google.maps.event.addListener window.VALIDATION.map, 'click', (event) ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom && window.VALIDATION.mapPolygon && window.VALIDATION.selectedLayer >= 0
      path = window.VALIDATION.mapPolygon.getPath()
      path.push(event.latLng)
      if path.length > 0
        $('#main_menu .erase-polygon').removeClass('disabled')
      if path.length > 2
        $('#main_menu .submit-polygon').removeClass('disabled')
