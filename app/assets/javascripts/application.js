// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require global
//= require jquery
//= require jquery_ujs
//= require jquery.fancybox
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require bootstrap-generators
//= require backbone/mangrove_validation
//= require view_manager
//= require old_view_manager
//= require user_geo_edits

/* Override Bootstrap Tooltip show function so the tooltip doesn't get out of the page */

$(function() {
  $.fn.tooltip.Constructor.prototype.show = function() {
    var $tip
      , inside
      , pos
      , actualWidth
      , actualHeight
      , placement
      , tp

    if (this.hasContent() && this.enabled) {
      $tip = this.tip()
      this.setContent()

      if (this.options.animation) {
        $tip.addClass('fade')
      }

      placement = typeof this.options.placement == 'function' ?
        this.options.placement.call(this, $tip[0], this.$element[0]) :
        this.options.placement

      inside = /in/.test(placement)

      $tip
        .remove()
        .css({ top: 0, left: 0, display: 'block' })
        .appendTo(inside ? this.$element : document.body)

      pos = this.getPosition(inside)

      actualWidth = $tip[0].offsetWidth
      actualHeight = $tip[0].offsetHeight

      switch (inside ? placement.split(' ')[1] : placement) {
        case 'bottom':
          tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
          break
        case 'top':
          tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
          break
        case 'left':
          tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
          break
        case 'right':
          tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
          break
      }

      if (tp.left && tp.left < 0) {
        $tip.find('.tooltip-arrow').css({ left: (50 + tp.left) + '%' })
        tp.left = 0
      }

      $tip
        .css(tp)
        .addClass(placement)
        .addClass('in')
    }
  }
});
