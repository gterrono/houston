Template.adminLogin.helpers(
  notLoggedIn: -> not Meteor.user()
  adminAccountExists: -> Meteor.users.findOne 'profile.admin': true
)

Template.adminLogin.events(
  'submit #sign-in-form': (e) ->
    e.preventDefault()
    email = $('input[name="email"]').val()
    password = $('input[name="password"]').val()
    if Meteor.users.findOne('profile.admin': true)
      Meteor.loginWithPassword(email, password)
    else
      Accounts.createUser
        email: $('input[name="email"]').val()
        password: $('input[name="password"]').val()
        profile:
          admin: true

  'click .logout': (e) ->
    e.preventDefault()
    Meteor.logout()
)
