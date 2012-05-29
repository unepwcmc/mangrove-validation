# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Check if user signed in
window.checkUserSignedIn = ->
  $.getJSON '/me', (data) ->
    $(".logout").show().tooltip({title: "Logout #{data.email}", placement: 'bottom'})


jQuery ->
  # Check if user signed in
  checkUserSignedIn()

  # All aboard the event bus!
  MangroveValidation.bus = _.extend({}, Backbone.Events)

  # Init routers
  window.router = new MangroveValidation.Routers.IslandsRouter()
  Backbone.history.start()
  
  $('[href^=#]').click (e) ->
    e.preventDefault()

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
      $("select.knowledge").val('').parents('.control-group').removeClass('error').find('.help-block').remove()
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
      $("select.knowledge").val('').parents('.control-group').removeClass('error').find('.help-block').remove()
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

      $('#main_menu .submit-or-erase').slideDown()
      $("select.knowledge").val('').parents('.control-group').removeClass('error').find('.help-block').remove()
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
      $('#main_menu .edit-area').addClass('active')
      $('#main_menu ul.dropdown-menu li').removeClass('hide')

  $('#main_menu .submit-polygon').click ->
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
    $("form#new_layer input#layer_knowledge").val($(".knowledge").val())

    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')

    # Submit form
    $('form#new_layer').submit()

  $('form#new_layer').bind('ajax:success', (evt, data, status, xhr) ->
    window.VALIDATION.mapPolygon.getPath().clear()

    # Update layers
    random_number = Math.floor(Math.random()*100)
    _.each window.VALIDATION.layers, (layer, layer_name) ->
      _.each layer.editions, (edition_properties, edition) ->
        name = `(edition == 'base' ? layer_name : layer_name + '_' + edition)`
        if window.VALIDATION[name].isVisible()
          window.VALIDATION[name].update("#{window.VALIDATION["#{name}_params"].query} AND #{random_number} = #{random_number}")

    $("#alert-message .alert").removeClass('alert-error').addClass('alert-success').html("Successfully submitted, thank you for your contribution.")
    $("#alert-message").show()
    setTimeout("$('#alert-message').fadeOut('slow')", 2000)

    $("select.knowledge").val('').parents('.control-group').removeClass('error').find('.help-block').remove()
  ).bind('ajax:error', (evt, data, status, xhr) ->
    if data.status == 401 || data.status == 403 # Unauthorized OR Forbidden
      $.fancybox.open('/users/sign_in', {type: 'iframe', padding: 0, margin: [60, 20, 20, 20], maxWidth: 600, minHeight: 380, closeBtn: false})
    else
      $("#alert-message .alert").removeClass('alert-success').addClass('alert-error').html("There was some error while trying to submit the data.")
      $("#alert-message").show()
      setTimeout("$('#alert-message').fadeOut('slow')", 2000)
      
      # Errors
      errors = $.parseJSON(data.responseText).errors

      $('select.knowledge').parents('.control-group').removeClass('error').find('.help-block').remove()
      $.each(errors.knowledge || [], (index, value) ->
        $("select.knowledge").after($("<span class='help-block'>Source #{value}</span>")).parents("div.control-group").addClass("error")
      )

    $('#main_menu .submit-polygon, #main_menu .erase-polygon').removeClass('disabled')
  )

  $('#main_menu .erase-polygon').click ->
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    window.VALIDATION.mapPolygon.getPath().clear()

  # Map menu buttons

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


