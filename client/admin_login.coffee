Template.admin_login.helpers(
  logged_in: -> Meteor.user()
  admin_user_exists: -> Meteor.users.findOne 'profile.admin': true
)

Template.admin_login.events(
  'submit #sign-in-form': (e) ->
    e.preventDefault()
    email = $('input[name="email"]').val()
    password = $('input[name="password"]').val()

    afterLogin = (error) ->
      # TODO error case that properly displays
      if error
        alert error
      else
        Router.go 'home'

    if Meteor.users.findOne('profile.admin': true)
      Meteor.loginWithPassword email, password, afterLogin
    else
      Accounts.createUser {
        email: $('input[name="email"]').val()
        password: $('input[name="password"]').val()
        profile:
          admin: true
      }, afterLogin

  'click .logout': (e) ->
    e.preventDefault()
    Meteor.logout()
  'click .become-admin': (e) ->
    Meteor.call('make_admin', Meteor.userId())
    e.preventDefault()
)

Template.admin_login.rendered = ->
  $(window).unbind('scroll')
