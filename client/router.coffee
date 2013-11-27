Meteor.subscribe '_houston'
Meteor.subscribe '_houston_adminUser'

window.Houston ?= {}

setup_collection = (collection_name) ->
  Houston._page_length = 20
  subscription_name = "_houston_#{collection_name}"
  collection = Houston._get_collection(collection_name)
  Houston._paginated_subscription =
    Meteor.subscribeWithPagination subscription_name, {}, {},
      Houston._page_length
  Session.set('_houston_collection_name', collection_name)
  return collection

Meteor.Router.add
  '/houston': ->
    Session.set '_houston_collections', Houston._collections.find().fetch()
    return '_houston_db_view'

  '/houston/login': '_houston_login'

  '/houston/:collection': (collection_name) ->
    collection = setup_collection collection_name
    return '_houston_collection_view'

  '/houston/:collection/:document': (collection_name, document_id) ->
    collection = setup_collection collection_name
    Session.set('_houston_document_id', document_id)
    return '_houston_document_view'

Meteor.Router.filters
  '_isHoustonAdmin': (page) -> if Meteor.user()?.profile.admin then page else '_houston_login'

Meteor.Router.filter '_isHoustonAdmin',
  only: ['_houston_db_view', '_houston_collection_view', '_houston_document_view']

Houston._lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''
