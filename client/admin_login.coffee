Template.admin_login.helpers(
  notLoggedIn: -> not Meteor.user()
  adminAccountNotExist: -> !Meteor.users.findOne 'profile.admin': true
)

Template.admin_login.events(
  'submit #sign-in-form': (e) ->
    e.preventDefault()
    email = $('input[name="email"]').val()
    password = $('input[name="password"]').val()
    if Meteor.users.findOne('profile.admin': true)
      Meteor.loginWithPassword(email, password)
    else
      # TODO: unbreak if this fails
      Accounts.createUser
        email: $('input[name="email"]').val()
        password: $('input[name="password"]').val()
        profile:
          admin: true

  'click .logout': (e) ->
    e.preventDefault()
    Meteor.logout()
)
