Template._houston_login.helpers(
  logged_in: -> Meteor.user()
)

Template._houston_login.events(
  'submit #houston-sign-in-form': (e) ->
    e.preventDefault()
    email = $('input[name="houston-email"]').val()
    password = $('input[name="houston-password"]').val()

    afterLogin = (error) ->
      # TODO error case that properly displays
      if error
        alert error
      else
        Houston._go 'home'

    if Houston._admin_user_exists()
      Meteor.loginWithPassword email, password, afterLogin
    else
      Accounts.createUser {
        email: email
        password: password
      }, (error) ->
        return afterLogin(error) if error
        Houston.becomeAdmin()

  'click #houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()
    # going 'home' clears the side nav
    Houston._go 'home'

  'click #become-houston-admin': (e) ->
    e.preventDefault()
    Houston.becomeAdmin()
)

Template._houston_login.rendered = ->
  $(window).unbind('scroll')
