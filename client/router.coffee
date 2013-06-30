Meteor.subscribe 'admin'

setup_collection = (collection_name) ->
  subscription_name = "admin_#{Session.get('collection_name')}"
  inspector_name = "inspector_#{collection_name}"
  unless window[inspector_name]
    window[inspector_name] =
      new Meteor.Collection(collection_name)
    Session.set('collection_name', collection_name)
  Meteor.subscribe subscription_name

Meteor.Router.add
  '/': 'homePage'
  '/admin': ->
    collections = Collections.find().fetch()
    Session.set 'collections', collections
    return 'admin'

  '/admin/:collection': (collection_name) ->
    setup_collection collection_name
    return 'list_view'

  '/admin/:collection/:document': (collection_name, document_id) ->
    setup_collection collection_name
    Session.set('document_id', document_id)
    return 'document_view'

  '*': '404'
