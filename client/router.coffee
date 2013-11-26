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

Router.map ->
  @route 'home',
    path: '/admin',
    before: ->
      # TODO use wait
      Session.set "collections", Collections.find().fetch()
    template: 'db_view',
  @route 'login',
    path: '/admin/login',
    template: 'admin_login'

  @route 'collection',
    path: '/admin/:collection'
    data: ->
      [collection, @subscription] = setup_collection(@params.collection)
      {collection}
    waitOn: -> @subscription

    template: 'collection_view'

  @route 'document',
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
      Router.go 'login'

Router.before(mustBeAdmin, except: ['login'])

window.lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''
