Template._houston_login.helpers(
  logged_in: -> Meteor.user()
  admin_user_exists: -> Meteor.users.findOne 'profile.admin': true
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
        houston_go 'home'

    if Meteor.users.findOne('profile.admin': true)
      Meteor.loginWithPassword email, password, afterLogin
    else
      Accounts.createUser {
        email: $('input[name="email"]').val()
        password: $('input[name="password"]').val()
        profile:
          admin: true
      }, afterLogin

  'click .houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()

  'click .become-houston-admin': (e) ->
    Meteor.call('_houston_make_admin', Meteor.userId())
    e.preventDefault()
)

Template._houston_login.rendered = ->
  $(window).unbind('scroll')
