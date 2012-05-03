#= require jquery
#= require jquery_ujs
#= require underscore
#= require bootstrap-generators

$ ->
  $('#users-search').keyup ->
    $('table#users tbody tr').hide()
    $('table#users tbody').children('tr').filter((index) =>
      self = $('table#users tbody').children('tr')[index]
      $.text($(self).children('td').first()).indexOf($(this).val()) != -1
    ).show()
