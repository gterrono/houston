Template._houston_navbar.events
  'click .houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()
