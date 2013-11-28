Meteor.subscribe 'admin'
Meteor.subscribe 'adminUser'

setup_collection = (collection_name, document_id) ->
  COLLECTION_STORAGE = window # TODO find a better global object
  COLLECTION_STORAGE.admin_page_length = 20
  subscription_name = "admin_#{collection_name}"
  collection = get_collection(collection_name)
  filter = if document_id then {_id: document_id} else {}
  COLLECTION_STORAGE.inspector_subscription =
    Meteor.subscribeWithPagination subscription_name, {}, filter,
      COLLECTION_STORAGE.admin_page_length
  Session.set("collection_name", collection_name)
  return [collection, COLLECTION_STORAGE.inspector_subscription]

# wrappers around IronRouter to avoid clobbering route namespaces of host app
# TODO proper top-level object
window.houstonize_route = (route_name) -> "houston_#{route_name}"
window.houston_go = (route_name, options) ->
  Router.go houstonize_route(route_name), options

Router.map ->
  houston_route = (route_name, options) =>
    # to avoid clobbering parent route namespace
    @route houstonize_route(route_name), options

  houston_route 'home',
    path: '/admin',
    before: ->
      # TODO use wait
      Session.set "collections", Collections.find().fetch()
    template: 'db_view',
  houston_route 'login',
    path: '/admin/login',
    template: 'admin_login'

  houston_route 'collection',
    path: '/admin/:collection'
    data: ->
      [collection, @subscription] = setup_collection(@params.collection)
      {collection}
    waitOn: -> @subscription

    template: 'collection_view'

  houston_route 'document',
    path: '/admin/:collection/:document_id'
    data: ->
      Session.set('document_id', @params.document_id)
      [collection, @subscription] = setup_collection(
        @params.collection, @params.document_id)
      {collection}
    template: 'document_view'

mustBeAdmin = ->
  unless Meteor.loggingIn() # don't check for admin user until ready
    unless Meteor.user()?.profile.admin
      @stop()
      houston_go 'login'

# cleaned up routes (hopefully)
Router.before(mustBeAdmin,
  only: (houstonize_route(name) for name in ['home', 'collection', 'document'])
)

# TODO move this to some shared utils location
window.lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''
