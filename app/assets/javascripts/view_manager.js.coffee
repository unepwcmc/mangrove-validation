# Manages display and removal of multiple views which are switched between.
# It does this by storing a reference to the current view, then calling it's .close()
# function when another view is switched to
#
# Inspired by: http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/

class MangroveValidation.ViewManager
  constructor: (@element) ->
  
  # Close the current view, render the given view into @element
  showView: (view) ->
    if (@currentView)
      @currentView.close()

    this.currentView = view
    this.currentView.render()

    $(@element).html(this.currentView.el)


# Add the close method (used in ViewManager) to BackboneView
Backbone.View.prototype.close = () ->
  this.remove()
  this.unbind()
