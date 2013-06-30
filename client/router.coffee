Meteor.subscribe 'admin'
Meteor.subscribe 'adminUser'

setup_collection = (collection_name) ->
  subscription_name = "admin_#{collection_name}"
  inspector_name = "inspector_#{collection_name}"

  unless window[inspector_name]
    # you can only instantiate a collection once
    try
      window[inspector_name] = new Meteor.Collection(collection_name)
    catch e
      window[inspector_name] = Meteor._LocalCollectionDriver.collections[collection_name]
  Meteor.subscribe subscription_name
  Session.set("collection_name", collection_name)
  return window[inspector_name]

Template.db_view.helpers
  collections: -> Session.get("collections")

Meteor.Router.add
  '/admin': ->
    Session.set "collections", Collections.find().fetch()
    return 'db_view'

  '/admin/login': 'admin_login'

  '/admin/:collection': (collection_name) ->
    collection = setup_collection collection_name
    return 'collection_view'

  '/admin/:collection/:document': (collection_name, document_id) ->
    collection = setup_collection collection_name
    Session.set('document_id', document_id)
    return 'document_view'

Meteor.Router.filters
  'isAdmin': (page) -> if Meteor.user()?.profile.admin then page else 'admin_login'

Meteor.Router.filter 'isAdmin', only: ['db_view', 'collection_view', 'document_view']
