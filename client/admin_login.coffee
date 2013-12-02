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
        Houston._call('make_admin', Meteor.userId()) unless error?
        afterLogin(error)

  'click .houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()

  'click .become-houston-admin': (e) ->
    e.preventDefault()
    Houston._call('make_admin', Meteor.userId())
    Houston._go 'home'
)

Template._houston_login.rendered = ->
  $(window).unbind('scroll')
