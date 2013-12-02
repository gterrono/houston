window.Houston ?= {}

Houston._houstonize = (name) -> "_houston_#{name}"

Houston._subscribe = (name) -> Meteor.subscribe Houston._houstonize name

Houston._subscribe 'collections'
Houston._subscribe 'admin_user'


setup_collection = (collection_name, document_id) ->
  Houston._page_length = 20
  subscription_name = Houston._houstonize collection_name
  collection = Houston._get_collection(collection_name)
  filter = if document_id
    # Sometimes you can lookup with _id being a string, sometimes not
    # When id can be wrapped in an ObjectID, it should
    # It can't if it isn't 12 bytes (24 characters)
    if typeof(document_id) == 'string' and document_id.length == 24
      document_id = new Meteor.Collection.ObjectID(document_id)
    {_id: document_id}
  else
    {}
  Houston._paginated_subscription =
    Meteor.subscribeWithPagination subscription_name, {}, filter,
      Houston._page_length
  Houston._session('collection_name', collection_name)
  return [collection, Houston._paginated_subscription]

Houston._houstonize_route = (name) -> Houston._houstonize(name)[1..]

Houston._go = (route_name, options) ->
  Router.go Houston._houstonize_route(route_name), options


Router.map ->
  houston_route = (route_name, options) =>
    # Append _houston_ to template and route names to avoid clobbering parent route namespace
    options.template = Houston._houstonize(options.template)
    @route Houston._houstonize_route(route_name), options

  houston_route 'home',
    path: '/admin',
    before: ->
      # TODO use wait
      Houston._session 'collections', Houston._collections.collections.find().fetch()
    template: 'db_view'

  houston_route 'login',
    path: '/admin/login',
    template: 'login'

  houston_route 'collection',
    path: '/admin/:name'
    data: ->
      [collection, @subscription] = setup_collection(@params.name)
      {collection}
    waitOn: -> @subscription
    template: 'collection_view'

  houston_route 'document',
    path: '/admin/:collection/:_id'
    data: ->
      Houston._session('document_id', @params._id)
      [collection, @subscription] = setup_collection(
        @params.collection, @params._id)
      {collection, name: @params.collection}
    template: 'document_view'

mustBeAdmin = ->
  unless Meteor.loggingIn() # don't check for admin user until ready
    unless Houston._user_is_admin Meteor.userId()
      debugger
      @stop()
      Houston._go 'login'

# If the host app doesn't have a router, their html may show up
hide_non_admin_stuff = ->
  $('body').hide()
  func = ->
    $('body').show()
    $('body').children().hide()
    $('body>.z-mongo-admin').show()
    $('body').css('visibility','hidden')
    $('body>.z-mongo-admin').css('visibility', 'visible')
  setTimeout func, 0

Router.after hide_non_admin_stuff,
  only: (Houston._houstonize_route(name) for name in ['home', 'collection', 'document', 'login'])
Router.before mustBeAdmin,
  only: (Houston._houstonize_route(name) for name in ['home', 'collection', 'document'])
