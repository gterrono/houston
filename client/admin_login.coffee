admin_user_exists = () -> Houston._admins.find().count() > 0

Template._houston_login.helpers(
  logged_in: -> Meteor.user()
  admin_user_exists: -> admin_user_exists()
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

    if admin_user_exists()
      Meteor.loginWithPassword email, password, afterLogin
    else
      Accounts.createUser {
        email: email
        password: password
      }, (error) ->
        return afterLogin(error) if error
        # else - user got created
        Houston._call('make_admin', Meteor.userId(), afterLogin)

  'click #houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()
    # going 'home' clears the side nav
    Houston._go 'home'

  'click #become-houston-admin': (e) ->
    e.preventDefault()
    Houston._call('make_admin', Meteor.userId())
    Houston._go 'home'
)

Template._houston_login.rendered = ->
  $(window).unbind('scroll')
