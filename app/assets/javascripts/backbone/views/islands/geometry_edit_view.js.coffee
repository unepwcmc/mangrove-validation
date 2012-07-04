MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.GeometryEditView extends Backbone.View
  template : JST["backbone/templates/islands/geometry_edit"]
  id: 'geometry-edit'

  initialize: ->
    @bindTo(MangroveValidation.bus, 'mapClickAt', @addPoint)

    # These binding could stand to be refactored, the forms should really be inside the view itself
    # currently, these will leak memory
    $('form#new_user_geo_edit').bind('ajax:success', @afterPolySubmission)
    $('form#new_user_geo_edit').bind('ajax:error', @failedPolySubmission)

    $('#reallocate-geometry-form').bind('ajax:success', @afterReallocation)
    $('#reallocate-geometry-form').bind('ajax:error', @failedPolySubmission)

  events:
    "click #validate-btn": "startValidate"
    "click #add-area-btn": "startAdd"
    "click #delete-area-btn": "startDelete"
    "click #reallocate-btn": "startReallocate"
    "click #submit-polygon": "checkPolygonSubmission"
    "click #reallocate-polygon": "reallocatePolygon"
    "click .erase-polygon": "clearCurrentEdits"

  addPoint: (latLng) =>
    # Add a point to the current polygons path
    if @mapPolygon?
      path = @mapPolygon.getPath()
      path.push(latLng)
      $('.erase-polygon').removeClass('disabled')
      if path.length > 2
        $('#submit-polygon').removeClass('disabled')
        $('#reallocate-polygon').removeClass('disabled')

  startValidate: (event) =>
    @drawNewPolygon('validate', '#46a546', event)
    @showEditDialog()

  startAdd: (event) =>
    @drawNewPolygon('add', '#08C', event)
    @showEditDialog()

  startDelete: (event) =>
    @drawNewPolygon('delete', '#9d261d', event)
    @showEditDialog()

  startReallocate: (event) =>
    @drawNewPolygon('reallocate', '#08C', event)
    @showReallocateDialog()
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @geomSearchView = new MangroveValidation.Views.Islands.SearchView @islands, $("#reallocate-dialog .field"), MangroveValidation.Views.Islands.SearchView::setReallocateTarget

  # Start drawing a new polygon on the map, for the given action and color
  drawNewPolygon: (action, color, event) ->
    event.preventDefault()
    if $(event.target).hasClass('active')
      @clearCurrentEdits()
    else
      @clearCurrentEdits()
      $(event.target).addClass('active')

      @mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: color, fillColor: color}))
      MangroveValidation.bus.trigger('addToMap', @mapPolygon)

      # Current action
      window.VALIDATION.currentAction = window.VALIDATION.actions[action]

  # Destroy the current polygon, hide submit options
  clearCurrentEdits: ->
    if @mapPolygon?
      # Clear polygon
      @mapPolygon.setMap(null)
      @mapPolygon = null
    
    # Unset current 
    window.VALIDATION.currentAction = null
    
    $('#tools .btn').removeClass('active')
    $('div.actions input').addClass('disabled')

  onClose: ->
    @clearCurrentEdits()

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    return this

  # Convert the given polygon to a points array
  pointsToCoordArray: (polygon)->
    coordinates = []
    path = polygon.getPath()
    path.forEach (coordinate) ->
      coordinates.push("#{coordinate.lng()} #{coordinate.lat()}")
    coordinates.push("#{path.getAt(0).lng()} #{path.getAt(0).lat()}") # Close the polygon
    coordinates

  # Ask user to confirm polygon submission is for bounds
  checkPolygonSubmission: =>
    @model.getBounds((bounds) =>
      confirm_view = new MangroveValidation.Views.Islands.ConfirmEditView(bounds, @submitPolygon)
      $(@el).append(confirm_view.render().el)
    , @submitPolygon)

  # Populates form for current poly, and submits
  submitPolygon: =>
    # Fill form
    $("form#new_user_geo_edit input#user_geo_edit_polygon").val(@pointsToCoordArray(@mapPolygon).join(','))

    $("form#new_user_geo_edit input#user_geo_edit_island_id").val(@model.get('id'))
    $("form#new_user_geo_edit input#user_geo_edit_action").val(window.VALIDATION.currentAction)
    $("form#new_user_geo_edit input#user_geo_edit_knowledge").val($("#edit-knowledge").val())

    $('div.actions input').addClass('disabled')

    # Submit form
    $('form#new_user_geo_edit').submit()

  # Populates form for reallocating the current user poly, and submits
  reallocatePolygon: =>
    # Fill form
    $("#reallocate-geometry-form input#reallocate_polygon").val(@pointsToCoordArray(@mapPolygon).join(','))

    $("#reallocate-geometry-form input#reallocate_from_island_id").val(@model.get('id'))
    $("#reallocate-geometry-form input#reallocate_to_island_name").val($('#to_island_name').val())
    $("#reallocate-geometry-form input#reallocate_knowledge").val($("#reallocate-knowledge").val())

    $('div.actions input').addClass('disabled')

    # Submit form
    $('#reallocate-geometry-form').submit()

  # Occurs after the polygon submission comes back successfully 
  afterPolySubmission: (evt, data, status, xhr) =>
    @clearCurrentEdits()

    # Thank user for submission
    $("#alert-message").removeClass('alert-error').addClass('alert-success').html("Successfully submitted, thank you for your contribution.")
    $("#alert-message").fadeIn()
    setTimeout("$('#alert-message').fadeOut('slow')", 2000)

    # Unset any errors
    $("select.knowledge").parents('.control-group').removeClass('error').find('.help-block').remove()

    # Redraw maps
    MangroveValidation.bus.trigger('layersChanged')

  failedPolySubmission: (evt, data, status, xhr) ->
    if data.status == 401 || data.status == 403 # Unauthorized OR Forbidden, show user login page
      window.VALIDATION.showUserLogin()
    else
      #Notify user of error
      $("#alert-message").removeClass('alert-success').addClass('alert-error').html("There was some error while trying to submit the data.")
      $("#alert-message").show()
      setTimeout("$('#alert-message').fadeOut('slow')", 2000)

      # Errors
      errors = $.parseJSON(data.responseText).errors

      $('select.knowledge').parents('.control-group').removeClass('error').find('.help-block').remove()
      $.each(errors.knowledge || [], (index, value) ->
        $("select:visible[id*='knowledge']").after($("<span class='help-block'>Source #{value}</span>")).parents("div.control-group").addClass("error")
      )

  # Occurs after the polygon submission comes back successfully 
  afterReallocation: (evt, data, status, xhr) =>
    @clearCurrentEdits()

    # Thank user for submission
    $("#alert-message").removeClass('alert-error').addClass('alert-success').html("Successfully reallocated this geometry to <a href='##{data.id}'>#{data.name}</a>, thank you for your contribution.")
    $("#alert-message").fadeIn()

    # Unset any errors
    $("select:visible[id*='knowledge']").parents('.control-group').removeClass('error').find('.help-block').remove()

    # Redraw maps
    MangroveValidation.bus.trigger('layersChanged')

  showEditDialog: =>
    $('#edit-dialog').slideDown()
    $('#reallocate-dialog').slideUp()

  showReallocateDialog: =>
    $('#reallocate-dialog').slideDown()
    $('#edit-dialog').slideUp()
