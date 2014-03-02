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
    options.layoutTemplate = null
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

# ########
# filters
# ########
mustBeAdmin = ->
  unless Meteor.loggingIn() # don't check for admin user until ready
    unless Houston._user_is_admin Meteor.userId()
      @stop()
      Houston._go 'login'

# If the host app doesn't have a router, their html may show up
hide_non_admin_stuff = ->
  $('body').hide()
  func = ->
    $('body').show()
    $('body').children().hide()
    $('body>.houston').show()
    $('body').css('visibility','hidden')
    $('body>.houston').css('visibility', 'visible')
  setTimeout func, 0

remove_host_css = ->
  # Houston._css_files is set in client/zma_helpers.coffee
  is_houston_link = ($link) ->
    $link.attr('href') in Houston._css_files
  links = $('link[rel="stylesheet"]')
  for link in links
    $link = $(link)
    unless is_houston_link($link)
      $link.remove()

  links = $('link[rel="stylesheet"]')
  # when hitting a new path using one of our links (as opposed to hitting a url directly)
  # the head tag is not reloaded, so it's possible that our css files are already
  # in the head tag.
  # Therefore, if after removing all of the non-houston css files, there are the
  # same number of files as in Houston._css_files, all of our files are in there,
  # so there is no need to add them again.
  if links.length < Houston._css_files.length
    $head = $('head')
    for file in Houston._css_files
      $head.append("<link rel=\"stylesheet\" href=\"#{file}\">")


Router.before mustBeAdmin,
  only: (Houston._houstonize_route(name) for name in ['home', 'collection', 'document'])
Router.after hide_non_admin_stuff,
  only: (Houston._houstonize_route(name) for name in ['home', 'collection', 'document', 'login'])
Router.before remove_host_css,
  only: (Houston._houstonize_route(name) for name in ['home', 'collection', 'document', 'login'])

onRouteNotFound = Router.onRouteNotFound
Router.onRouteNotFound = (args...) ->
  non_houston_routes = _.filter(Router.routes, (route) -> route.name.indexOf('houston_') != 0)
  if non_houston_routes.length > 0
    onRouteNotFound.apply Router, args
  else
    console.log "Note: Houston is suppressing Iron-Router errors because we don't think you are using it."
