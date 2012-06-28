MangroveValidation.Views.Islands ||= {}

# This view is used to confirm the users intent to edit an entire island,
# rather than a specific area. It does this by zooming to the island extent,
# then rendering a dialog box with confirm or reject.
# Upon either selection, the relevant callbacks are fired, and the bounds 
# are reset to their previous position
class MangroveValidation.Views.Islands.ConfirmEditView extends Backbone.View
  template: JST["backbone/templates/islands/confirm_edit"]
  id: 'confirm-edit-dialog'
  className: 'alert'

  events: 
    "click .btn-success"  : "confirm"
    "click .btn-danger"   : "reject"

  # bounds - the bounds to zoom to
  # confirmed - callback on user confirmation
  # reject - callback on user cancel
  initialize: (bounds, confirmed, reject)=>
    MangroveValidation.bus.trigger('map:getCurrentBounds', @setOriginBounds)

    MangroveValidation.bus.trigger('zoomToBounds', bounds)

    @confirm_callback = confirmed
    @confirm_callback ||= () ->
    @reject_callback = reject
    @reject_callback ||= () ->

  # Sets bounds to return to once user confirms edit
  setOriginBounds: (bounds) =>
    @originBounds = bounds

  returnToOriginBounds: () =>
    MangroveValidation.bus.trigger('zoomToBounds', @originBounds)

  confirm: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @returnToOriginBounds()
    @confirm_callback()
    @close()

  reject: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @returnToOriginBounds()
    @reject_callback()
    @close()

  render: () =>
    $(@el).html(@template())
    return this
