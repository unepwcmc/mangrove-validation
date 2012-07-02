#= require jquery
#= require jquery_ujs
#= require jquery.fancybox
#= require underscore
#= require bootstrap-generators

$ ->
  signInSuccessful = (evt, data, status, xhr) ->
    # Close modalbox
    parent.$.fancybox.close()

    # Check if user signed in
    parent.checkUserSignedIn()

    # Re-submit polygon
    parent.$('#main_menu .submit-polygon').click()

  $("form").bind('ajax:success', signInSuccessful).bind('ajax:error', (evt, data, status, xhr) ->
    if $(evt.target).attr("id") == 'form_sign_in'
      if data.status == 200
        signInSuccessful(evt, data, status, xhr)
      else
        $(".alert").remove()
        $(".modal-body").prepend($("<div class='alert alert-error'><a class='close' data-dismiss='alert' href='#'>×</a>#{data.responseText}</div>").alert())
    else if $(evt.target).attr("id") == 'form_sign_up'
      errors = $.parseJSON(data.responseText)
      $("form#form_sign_up span.help-block").remove()
      $("form#form_sign_up div.control-group").removeClass("error")

      $.each(errors.name || [], (index, value) ->
        $("form#form_sign_up input#user_name").after($("<span class='help-block'>Name #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.institution || [], (index, value) ->
        $("form#form_sign_up input#user_institution").after($("<span class='help-block'>Institution #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.email || [], (index, value) ->
        $("form#form_sign_up input#user_email").after($("<span class='help-block'>Email #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.password || [], (index, value) ->
        $("form#form_sign_up input#user_password").after($("<span class='help-block'>Password #{value}</span>")).parents("div.control-group").addClass("error")
      )

      policy_error_msg = $("<span class='help-block'>You must agree to the Submission Usage and Downloads Policies to continue</span>")

      $.each(errors.usage_agreement || [], (index, value) ->
        $("form#form_sign_up input#user_usage_agreement")
          .parents("div.control-group")
          .addClass("error")
          .append(policy_error_msg)
      )

      $.each(errors.downloads_agreement || [], (index, value) ->
        # Only show one error message for the policy checkboxes (don't
        # show one if the usage_agreement is already displaying an
        # error)
        if !$("form#form_sign_up input#user_usage_agreement").parents("div.control-group").hasClass("error")
          $("form#form_sign_up input#user_usage_agreement")
            .parents("div.control-group")
            .addClass("error")
            .append(policy_error_msg)
      )
    else if $(evt.target).attr("id") == 'form_user_edit'
      errors = ($.parseJSON(data.responseText)).errors
      $("form#form_user_edit span.help-block").remove()
      $("form#form_user_edit div.control-group").removeClass("error")

      $.each(errors.email || [], (index, value) ->
        $("form#form_user_edit input#user_email").after($("<span class='help-block'>email #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.password || [], (index, value) ->
        $("form#form_user_edit input#user_password").after($("<span class='help-block'>password #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.current_password || [], (index, value) ->
        $("form#form_user_edit input#user_current_password").after($("<span class='help-block'>current password #{value}</span>")).parents("div.control-group").addClass("error")
      )
    else if $(evt.target).attr("id") == "form_password_edit"
      errors = ($.parseJSON(data.responseText)).errors
      console.log errors
      $("form#form_password_edit span.help-block").remove()
      $("form#form_password_edit div.control-group").removeClass("error")

      $.each(errors.password || [], (index, value) ->
        $("form#form_password_edit input#user_password").after($("<span class='help-block'>password #{value}</span>")).parents("div.control-group").addClass("error")
      )
    else
      errors = $.parseJSON(data.responseText)
      $("form#form_forgot_password span.help-block").remove()
      $("form#form_forgot_password div.control-group").removeClass("error")

      $.each(errors.email || [], (index, value) ->
        $("form#form_forgot_password input#user_email").after($("<span class='help-block'>Email #{value}</span>")).parents("div.control-group").addClass("error")
      )

      $.each(errors.password || [], (index, value) ->
        $("form#form_forgot_password input#user_password").after($("<span class='help-block'>Password #{value}</span>")).parents("div.control-group").addClass("error")
      )
  ).bind('ajax:complete', (evt, data, status, xhr) ->
    $("#sign_in_or_up").html($('ul.nav li.active > a').html()).button('reset')
    $(".btn.cancel").button('reset')
  )

  $("#sign_in_or_up").click ->
    $(this).button('loading')

  $('.modal-header .close').click ->
    parent.$.fancybox.close()
