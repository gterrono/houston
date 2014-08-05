Template._houston_change_password.helpers(
  admin_user_exists: -> admin_user_exists()
)

Template._houston_change_password.events(
  'submit #houston-change-password-form': (e) ->
    e.preventDefault()
    current_password = $('input[name="houston-current-password"]').val()
    new_password = $('input[name="houston-new-password"]').val()

    Accounts.changePassword(current_password, new_password, (error) ->
      if error?
        alert(error)
      else
        Houston._go('home')
    )
)

Template._houston_change_password.rendered = ->
  $(window).unbind('scroll')
