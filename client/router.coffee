Meteor.Router.add(
  '/admin': 'adminIndex'
  '/admin/login': 'adminLogin'
  '*': '404'
)

Meteor.Router.filters
  'isAdmin': (page) ->
    if Meteor.user()?.profile.admin then page else 'adminLogin'

Meteor.Router.filter 'isAdmin', only: 'adminIndex'
