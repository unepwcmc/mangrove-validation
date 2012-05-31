MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.GeometryEditView extends Backbone.View
  template : JST["backbone/templates/islands/geometry_edit"]
  id: 'geometry-edit'

  initialize: ->
    MangroveValidation.bus.bind('mapClickAt', @addPoint)

  events :
    "click #validate-btn": "startValidate"
    "submit #submit-polygon" : "submitPolygon"
    "submit #erase-polygon" : "erasePolygon"

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
    event.preventDefault();
    if $(event.target).hasClass('active')
      #Disable editing
      @mapPolygon.setMap(null)
      @mapPolygon = null
      
      # Current action
      window.VALIDATION.currentAction = null
      
      $('#tools .btn').removeClass('active')
      $('#main_menu .submit-or-erase').slideUp()
      $('#main_menu .submit-polygon, #main_menu .erase-polygon').addClass('disabled')
    else
      # Set only this button active
      $('#tools .btn').removeClass('active')
      $(this).addClass('active')

      @mapPolygon = new google.maps.Polygon(_.extend(window.VALIDATION.mapPolygonOptions, {strokeColor: '#08c', fillColor: '#08c'}))
      MangroveValidation.bus.trigger('addToMap', @mapPolygon)

      # Current action
      window.VALIDATION.currentAction = window.VALIDATION.actions.validate

      $('#main_menu .submit-or-erase').slideDown()
      $("select.knowledge").val('').parents('.control-group').removeClass('error').find('.help-block').remove()
      $('#main_menu .edit-area').html('<i class="icon-pencil icon-white"></i> Edit area <span class="caret"></span>').removeClass('btn-success btn-danger active').addClass('btn-warning')
      $('#main_menu ul.dropdown-menu li.divider').addClass('hide').next('li').addClass('hide')

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    #this.$("form").backboneLink(@model)

    return this

  erasePolygon: ->

  submitPolygon: ->

