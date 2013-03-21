MangroveValidation.Views.Islands ||= {}

class MangroveValidation.Views.Islands.AttributeEditView extends Backbone.View
  template : JST["backbone/templates/islands/edit"]
  id: 'island-attributes'

  events :
    "submit #edit-island" : "update"

  update : (e) =>
    e.preventDefault()
    e.stopPropagation()
    if @model.isNew()
      @doSave()
    else
      # if model isn't new, check user intends to edit entire extent
      @model.getBounds (bounds) =>
        confirm_view = new MangroveValidation.Views.Islands.ConfirmEditView(bounds, @doSave)
        $(@el).append(confirm_view.render().el)

  doSave: =>
    @model.save(null,
      success : (island) =>
        @model = island
        window.router.navigate("#{@model.get('id')}", true)
        MangroveValidation.bus.trigger('changeIslandView','show')
      error : @failedSubmission
    )

  failedSubmission: (model, xhr, options) =>
    if xhr.status == 401 || xhr.status == 403
      window.VALIDATION.showUserLogin()
    else
      $("#alert-message").
        removeClass('alert-success').
        addClass('alert-error').
        html("There was some error while trying to submit the data.").
        show
      setTimeout("$('#alert-message').fadeOut('slow')", 2000)

      errors = $.parseJSON(xhr.responseText).errors

      $('form[id*="island"] :input').
        parents('.control-group').
        removeClass('error').
        find('.alert').remove()

      $.each(errors || [], (index, value) ->
        $input = $(":input:visible[id='#{index}']")
        field_name = $input.siblings('label').html() || 'Source'
        $input.
          after($("<span class='alert alert-error'>#{field_name} #{value}</span>")).
          parents("div.control-group").addClass("error")
      )

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    @$("form").backboneLink(@model)
    return this
