Meteor.Router.add(
  '/admin': 'adminIndex'
  '/admin/login': 'adminLogin'
  '/admin/:collection': (collection_name) ->
    subscription_name = "admin_#{Session.get('collection_name')}"
    Meteor.subscribe subscription_name
    window["inspector_#{collection_name}"] =
      new Meteor.Collection(collection_name)
    Session.set('collection_name', collection_name)
    'list_view'
  '*': '404'
)

Meteor.Router.filters
  'isAdmin': (page) ->
    if Meteor.user()?.profile.admin then page else 'adminLogin'

Meteor.Router.filter 'isAdmin', only: ['adminIndex', 'list_view']
