Template.adminLogin.helpers(
  notLoggedIn: -> not Meteor.user()
  adminAccountExists: -> Meteor.users.findOne 'profile.admin': true
)

Template.adminLogin.events(
  'submit #sign-in-form': (e) ->
    e.preventDefault()
    Meteor.loginWithPassword($('input[name="email"]').val(), $('input[name="password"]').val())

  'click .logout': (e) ->
    e.preventDefault()
    Meteor.logout()

  'click #sign-up': (e) ->
    e.preventDefault()
    Accounts.createUser
      email: $('input[name="email"]').val()
      password: $('input[name="password"]').val()
      profile:
        admin: true
)
