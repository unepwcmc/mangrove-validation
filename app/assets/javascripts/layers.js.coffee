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
    window.VALIDATION.map.setZoom(window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer])

  $('#main_menu .validate').click ->
    # Add button clicked
    if $(this).hasClass('active')
      window.VALIDATION.mapPolygon.setMap(null)
      window.VALIDATION.mapPolygon = null
      
      # Current action
      window.VALIDATION.currentAction = null
      
      $('#tools .btn').removeClass('active')
      $('#main_menu .submit-or-erase').slideUp()
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    else
      $('#tools .btn').removeClass('active')
      $(this).addClass('active')

      window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#08c', fillColor: '#08c'}))
      window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

      # Current action
      window.VALIDATION.currentAction = window.VALIDATION.actions['validate']

      $('#main_menu .submit-or-erase').slideDown()
      $('#main_menu .edit-area').html('<i class="icon-pencil icon-white"></i> Edit area <span class="caret"></span>').removeClass('btn-success btn-danger active').addClass('btn-warning')
      $('#main_menu ul.dropdown-menu li.divider').addClass('hide').next('li').addClass('hide')

  $('#main_menu .add-area').click ->
    # Add button clicked
    $('#main_menu .edit-area').html('<i class="icon-plus icon-white"></i> Add new area <span class="caret"></span>').removeClass('btn-warning btn-danger').addClass('btn-success')

    if $(this).hasClass('active')
      window.VALIDATION.mapPolygon.getPath().clear()
      window.VALIDATION.mapPolygon.setMap(null)
      window.VALIDATION.currentAction = null

      # Deactivate button, hide submit/erase
      $('#tools .btn').removeClass('active')
      $('#main_menu .submit-or-erase').slideUp()
    else
      $('#tools .btn').removeClass('active')
      $(this).addClass('active')

      # Google Maps Polygon
      window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
      window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#46a546', fillColor: '#46a546'}))
      window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

      # Current action
      window.VALIDATION.currentAction = window.VALIDATION.actions['add']

      $('#main_menu .submit-or-erase').slideDown()
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
      $('#main_menu .edit-area').addClass('active')
      $('#main_menu ul.dropdown-menu li').removeClass('hide')

  $('#main_menu .delete-area').click ->
    $('#main_menu .edit-area').html('<i class="icon-trash icon-white"></i> Delete area <span class="caret"></span>').removeClass('btn-warning btn-success').addClass('btn-danger')

    if $(this).hasClass('active')
      window.VALIDATION.mapPolygon.getPath().clear()
      window.VALIDATION.mapPolygon.setMap(null)
      window.VALIDATION.currentAction = null

      # Deactivate button, hide submit/erase
      $('#tools .btn').removeClass('active')
      $('#main_menu .submit-or-erase').slideUp()
    else
      $('#tools .btn').removeClass('active')
      $(this).addClass('active')

      # Google Maps Polygon
      window.VALIDATION.mapPolygon.setMap(null) if window.VALIDATION.mapPolygon
      window.VALIDATION.mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#9d261d', fillColor: '#9d261d'}))
      window.VALIDATION.mapPolygon.setMap(window.VALIDATION.map)

      # Current action
      window.VALIDATION.currentAction = window.VALIDATION.actions['delete']

      $('#main_menu .submit-or-erase').slideDown();
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

      _.each window.VALIDATION.layers, (id, layer) ->
        if layer == window.VALIDATION.selectedLayer
          window.VALIDATION[layer].show()
          window.VALIDATION["#{layer}_validated"].show()
          window.VALIDATION["#{layer}_added"].show()
        else
          window.VALIDATION[layer].hide()
          window.VALIDATION["#{layer}_validated"].hide()
          window.VALIDATION["#{layer}_added"].hide()
    else
      $(this).addClass('btn-danger')
      $(this).find('i').addClass('icon-white')

      _.each window.VALIDATION.layers, (id, layer) ->
        window.VALIDATION[layer].hide()
        window.VALIDATION["#{layer}_validated"].hide()
        window.VALIDATION["#{layer}_added"].hide()

  $('#map_menu .layer-switcher .dropdown-menu a').click ->
    $(this).parents('.layer-switcher').find('#selected-layer').html($(this).html())

    unless window.VALIDATION.selectedLayer == $(this).data('layer')
      window.VALIDATION.selectedLayer = $(this).data('layer')

      _.each window.VALIDATION.layers, (layer, name) ->
        if name == window.VALIDATION.selectedLayer
          window.VALIDATION[name].show()
          window.VALIDATION["#{name}_validated"].show()
          window.VALIDATION["#{name}_added"].show()
        else
          window.VALIDATION[name].hide()
          window.VALIDATION["#{name}_validated"].hide()
          window.VALIDATION["#{name}_added"].hide()

    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer]
      $('#main_menu .actions').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon
    else
      $('#main_menu .zoom').removeClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      $('#main_menu .actions').addClass('hide')
      window.VALIDATION.mapPolygon.setEditable(false) if window.VALIDATION.mapPolygon

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

    $("form#new_layer input#layer_name").val(window.VALIDATION.layers[window.VALIDATION.selectedLayer].id)
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
    if window.VALIDATION.selectedLayer != 'hide' && window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer]
      $('#main_menu .zoom').addClass('hide')
      $('#main_menu .select-layer').addClass('hide')
      $('#main_menu .actions').removeClass('hide')
      window.VALIDATION.mapPolygon.setEditable(true) if window.VALIDATION.mapPolygon
    else if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer]
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
  _.each window.VALIDATION.layers, (layer, layer_name) ->
    _.each layer.editions, (edition_properties, edition) ->
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
        map: window.VALIDATION.map
        user_name: 'carbon-tool'
        table_name: window.CARTODB_TABLE
        query: query
        tile_style: "##{window.CARTODB_TABLE}{#{edition_properties.style}}"

      window.VALIDATION[name] = new google.maps.CartoDBLayer $.extend({}, window.VALIDATION["#{name}_params"])
      window.VALIDATION[name].hide() if edition_properties.hide

  google.maps.event.addListener window.VALIDATION.map, 'click', (event) ->
    if window.VALIDATION.map.getZoom() >= window.VALIDATION.minEditZoom[window.VALIDATION.selectedLayer] && window.VALIDATION.mapPolygon && window.VALIDATION.selectedLayer != 'hide'
      path = window.VALIDATION.mapPolygon.getPath()
      path.push(event.latLng)
      if path.length > 0
        $('#main_menu .erase-polygon').removeClass('disabled')
      if path.length > 2
        $('#main_menu .submit-polygon').removeClass('disabled')
