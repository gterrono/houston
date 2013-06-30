Meteor.Router.add(
  '/': 'homePage'
  '/admin/:collection': (collection_name) ->
    subscription_name = "admin_#{Session.get('collection_name')}"
    Meteor.subscribe subscription_name
    window["inspector_#{collection_name}"] =
      new Meteor.Collection(collection_name)
    Session.set('collection_name', collection_name)
    'list_view'

  '*': '404'
)
