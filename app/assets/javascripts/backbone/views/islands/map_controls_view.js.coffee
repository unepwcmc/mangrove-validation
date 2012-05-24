MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.MapControlsView extends Backbone.View
  el: '#map_menu'

  events: 
    'click .help': 'showHelp'
    'click .zoom-in': 'zoomIn'
    'click .zoom-out': 'zoomOut'

  initialize: ->
    $('#landingModal').modal({backdrop: true, show: true})

  showHelp: ->
    $('#landingModal .modal-footer span.get-started').html('Continue with:')
    $('#landingModal').modal('show')

  zoomIn: ->
    MangroveValidation.bus.trigger("zoomIn:MapControlsView")

  zoomOut: ->
    MangroveValidation.bus.trigger("zoomOut:MapControlsView")

