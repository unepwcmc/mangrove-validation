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
  
  # Toggle map layers button
  $('#toggle-map-layers').click (e) ->
    target = $(e.target)
    MangroveValidation.bus.trigger("toggleMapLayers", !target.hasClass('active'))
    target.toggleClass('active')
    if target.hasClass('active')
      target.html('Hide Map Layers')
    else
      target.html('Show Map Layers')

  $('[href^=#]').click (e) ->
    e.preventDefault()

  $('#about-btn').click (e) ->
    $('#landingModal').modal()

  $('form#new_user_geo_edit').bind('ajax:error', (evt, data, status, xhr) ->
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
