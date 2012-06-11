# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Check if user signed in
window.checkUserSignedIn = ->
  $.getJSON '/me', (data) ->
    $("#login-btn").text("Logout #{data.email}")
      .attr('id', "logout-btn")
      .attr('href', "/users/sign_out")
      .attr('data-method', 'delete')

# Show the user login page in a modal
window.VALIDATION.showUserLogin = ->
  $.fancybox.open('/users/sign_in', {type: 'iframe', padding: 0, margin: [60, 20, 20, 20], maxWidth: 600, minHeight: 380, closeBtn: false})

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

  $('#show-downloads-btn').click (e) ->
    $('#download-modal').modal()

  $('#login-btn').click () ->
    window.VALIDATION.showUserLogin()

