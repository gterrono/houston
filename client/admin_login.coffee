admin_user_exists = () -> Houston._admins.find().count() > 0

Template._houston_login.helpers(
  logged_in: -> Meteor.user()
  admin_user_exists: -> admin_user_exists()
)

Template._houston_login.events(
  'submit #houston-sign-in-form': (e) ->
    e.preventDefault()
    email = $('input[name="email"]').val()
    password = $('input[name="password"]').val()

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
        email: $('input[name="email"]').val()
        password: $('input[name="password"]').val()
      }, (error) ->
        return afterLogin(error) if error
        # else - make me an admin, then send me on my way.
        Houston._call 'make_admin', Meteor.userId(), afterLogin

  'click .houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()

  'click .become-houston-admin': (e) ->
    Houston._call('make_admin', Meteor.userId())
    e.preventDefault()
)

Template._houston_login.rendered = ->
  $(window).unbind('scroll')
