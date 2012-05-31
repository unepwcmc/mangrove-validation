MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.GeometryEditView extends Backbone.View
  template : JST["backbone/templates/islands/geometry_edit"]
  id: 'geometry-edit'

  initialize: ->
    MangroveValidation.bus.bind('mapClickAt', @addPoint)

  events :
    "click #validate-btn": "startValidate"
    "click #add-area-btn": "startAdd"
    "click #delete-area-btn": "startDelete"
    "click #submit-polygon" : "submitPolygon"
    "click #erase-polygon" : "clearCurrentEdits"

  addPoint: (latLng) =>
    # Add a point to the current polygons path
    if @mapPolygon?
      path = @mapPolygon.getPath()
      path.push(latLng)
      if path.length > 0
        $('.erase-polygon').removeClass('disabled')
      if path.length > 2
        $('.submit-polygon').removeClass('disabled')

  startValidate: (event) =>
    @drawNewPolygon('validate', '#46a546', event)

  startAdd: (event) =>
    @drawNewPolygon('add', '#08C', event)

  startDelete: (event) =>
    @drawNewPolygon('add', '#9d261d', event)

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
    $('#main_menu .submit-or-erase').slideUp()
    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    return this

  submitPolygon: =>
    # Fill form
    $("form#new_user_geo_edit input#layer_polygon").val ->
      coordinates = []
      path = @mapPolygon.getPath()
      path.forEach (coordinate) ->
        coordinates.push("#{coordinate.lng()} #{coordinate.lat()}")
      coordinates.push("#{path.getAt(0).lng()} #{path.getAt(0).lat()}") # Close the polygon
      "#{coordinates.join(',')}"

    $("form#new_user_geo_edit input#user_geo_edit_island_id").val(@model.get('id'))
    $("form#new_user_geo_edit input#user_geo_edit_action").val(window.VALIDATION.currentAction)
    $("form#new_user_geo_edit input#user_geo_edit_knowledge").val($(".knowledge").val())

    $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')

    # Submit form
    $('form#new_user_geo_edit').submit()
