Meteor.subscribe("admin")

Meteor.Router.add
  '/': 'homePage'
  '/admin': 'admin'
  '/admin/:collection': (collection_name) ->
    subscription_name = "admin_#{Session.get('collection_name')}"
    inspector_name = "inspector_#{collection_name}"
    unless window[inspector_name]
      window[inspector_name] =
        new Meteor.Collection(collection_name) unless window[inspector_name]
      Session.set('collection_name', collection_name)

    Meteor.subscribe subscription_name
    'list_view'

  '*': '404'
