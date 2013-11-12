Meteor.subscribe 'admin'
Meteor.subscribe 'adminUser'

setup_collection = (collection_name) ->
  COLLECTION_STORAGE = window # TODO find a better global object
  COLLECTION_STORAGE.admin_page_length = 20
  subscription_name = "admin_#{collection_name}"
  collection = get_collection(collection_name)
  COLLECTION_STORAGE.inspector_subscription =
    Meteor.subscribeWithPagination subscription_name, {}, {},
      COLLECTION_STORAGE.admin_page_length
  Session.set("collection_name", collection_name)
  return collection

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

window.lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''
