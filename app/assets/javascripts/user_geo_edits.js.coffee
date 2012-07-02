# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Check if user signed in
window.checkUserSignedIn = ->
  $.getJSON '/me', (data) ->
    $('<li><a id="show-downloads-btn" href="#">Download data</a></li>').insertBefore($('#login-btn').parent())

    $("#login-btn").text("Logout #{data.email}")
      .attr('id', "logout-btn")
      .attr('href', "/users/sign_out")
      .attr('data-method', 'delete')


# Show the user login page in a modal
window.VALIDATION.showUserLogin = ->
  $.fancybox.open('/users/sign_in', {type: 'iframe', padding: 0, margin: [60, 20, 20, 20], maxWidth: 600, minHeight: 380, closeBtn: false})

update_available_downloads = () ->
  $.ajax
    url: '/download/available'
    success: (data) ->
      $('#user-downloads').html(data)
    dataType: 'html'

poll_downloads = () ->
  setTimeout (->
    update_available_downloads()
    poll_downloads()
  ), 30000

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

  $('.add-island').click () ->
    window.router.navigate("/#new", true)

  $('#login-btn').click () ->
    window.VALIDATION.showUserLogin()

  $(document).on 'click', '#show-downloads-btn', () =>
    $('#download-modal').modal()
    update_available_downloads()
    poll_downloads()

  # Downloads buttons
  $('#download-option-strip a').click (e) ->
    e.preventDefault()

    $.ajax(
      url: $(e.target).attr('href')
      success: ->
        $('#user-download-feedback').removeClass('alert-danger').addClass('alert-success')
        $('#user-download-feedback').text('Started building your download, you will received and email when finished')
        $('#user-download-feedback').slideDown()
        setTimeout("$('#user-download-feedback').slideUp('slow')", 2000)
        update_available_downloads()
        poll_downloads()
      error: ->
        $('#user-download-feedback').removeClass('alert-success').addClass('alert-danger')
        $('#user-download-feedback').text('Unable to build your download, please try again')
        $('#user-download-feedback').slideDown()
        setTimeout("$('#user-download-feedback').slideUp('slow')", 2000)
    )
