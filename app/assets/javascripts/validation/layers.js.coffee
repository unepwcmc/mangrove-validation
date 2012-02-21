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

  $('#main_menu .add-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Add new area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-danger').addClass('btn-success')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

  $('#main_menu .delete-area').click ->
    $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Delete area')
    $('#main_menu .spotted-error').button('toggle') unless $('#main_menu .spotted-error').hasClass('active')
    $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-info btn-success').addClass('btn-danger')
    $('#main_menu .validate').button('toggle') if $('#main_menu .validate').hasClass('active')

  $('#main_menu .spotted-error').click ->
    if $('#main_menu .spotted-error').hasClass('active')
      $('#main_menu .spotted-error').html('<i class="icon-flag icon-white"></i> Spotted error?').button('toggle')
      $('#main_menu .spotted-error, #main_menu .spotted-error-toggle').removeClass('btn-success btn-danger').addClass('btn-info')
    else
      $('#helpModal').modal('show')

  # Map menu buttons
  $('#map_menu .zoom-in').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() + 1)

  $('#map_menu .zoom-out').click ->
    window.VALIDATION.map.setZoom(window.VALIDATION.map.getZoom() - 1)

window.VALIDATION.initializeGoogleMaps = ->
  mapOptions =
    center: new google.maps.LatLng(-34.397, 150.644)
    zoom: window.VALIDATION.defaultZoom
    mapTypeId: google.maps.MapTypeId.ROADMAP
    mapTypeControl: false
    panControl: false
    zoomControl: false
    rotateControl: false

  window.VALIDATION.map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);

  google.maps.event.addListener window.VALIDATION.map, 'zoom_changed', ->
    if(window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom)
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .actions').removeClass('hide')
    else
      $('#main_menu .zoom').removeClass('hide')
      $('#main_menu .actions').addClass('hide')
