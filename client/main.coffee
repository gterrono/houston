Template.admin_main.events
  'click .logout': (e) ->
    e.preventDefault()
    Meteor.logout()
    Meteor.Router.to "/admin/login"
