Meteor.subscribe 'admin'

setup_collection = (collection_name) ->
  subscription_name = "admin_#{collection_name}"
  inspector_name = "inspector_#{collection_name}"

  unless window[inspector_name]
    window[inspector_name] = new Meteor.Collection(collection_name)
  Meteor.subscribe subscription_name
  Session.set("collection_name", collection_name)
  return window[inspector_name]

Template.db_view.helpers
  collections: -> Session.get("collections")

Meteor.Router.add
  '/': 'homePage'
  '/admin': ->
    Session.set "collections", Collections.find().fetch()
    return 'db_view'

  '/admin/login': 'adminLogin'

  '/admin/:collection': (collection_name) ->
    collection = setup_collection collection_name
    return 'collection_view'

  '/admin/:collection/:document': (collection_name, document_id) ->
    collection = setup_collection collection_name
    Session.set('document_id', document_id)
    return 'document_view'

  '*': '404'

Meteor.Router.filters
  'isAdmin': (page) -> if Meteor.user()?.profile.admin then page else 'adminLogin'

Meteor.Router.filter 'isAdmin', only: ['admin', 'collection_view', 'document_view']
