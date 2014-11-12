window.Houston ?= {}

Houston._ROOT_ROUTE = Meteor.settings?.public?.houston_root_route or "/admin"
Houston._subscribe = (name) -> Meteor.subscribe Houston._houstonize name

Houston._subscribe_to_collections()

setup_collection = (collection_name, document_id) ->
  Houston._page_length = 20
  subscription_name = Houston._houstonize collection_name
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

Houston._houstonize_route = (name) ->
  Houston._houstonize(name)[1..]

Houston._go = (route_name, options) ->
  Router.go Houston._houstonize_route(route_name), options


houston_route = (route_name, options) =>
  # Append _houston_ to template and route names to avoid clobbering parent route namespace
  options.layoutTemplate = '_houston_master_layout'
  options.name = Houston._houstonize_route(route_name)
  options.template = Houston._houstonize(options.template)
  options.waitOn = ->
    subscriptions = if options.subs then options.subs(this.params) else []
    subscriptions.push Houston._subscribe('admin_user')
    subscriptions
  Router.route "#{Houston._ROOT_ROUTE}#{options.houston_path}", options

houston_route 'home',
  houston_path: '/'
  template: 'db_view'
  data: -> collections: Houston._collections.collections
  waitOn: -> Houston._collections

houston_route 'login',
  houston_path: "/login"
  template: 'login'

houston_route 'change_password',
  houston_path: "/password"
  template: 'change_password'

houston_route 'collection',
  houston_path: "/:collection_name"
  data: -> Houston._get_collection(@params.collection_name)
  subs: (params) ->
    [setup_collection(params.collection_name)]
  template: 'collection_view'

houston_route 'document',
  houston_path: "/:collection/:_id"
  data: ->
    @subscription = setup_collection(@params.collection, @params._id)
    collection = Houston._get_collection(@params.collection)
    document = collection.findOne _id: @params._id
    {document, collection, name: @params.collection}
  template: 'document_view'

houston_route 'custom_template',
  houston_path: "/:template"
  template: 'custom_template_view'
  data: -> this.params

# ########
# filters
# ########
mustBeAdmin = ->
  if !Meteor.user()
    if Meteor.loggingIn()
      @render 'houstonLoading'
    else
      Houston._go 'login'
  else
    if @ready() and not Houston._user_is_admin Meteor.userId()
      Houston._go 'login'
    else
      @next()

# If the host app doesn't have a router, their html may show up
hide_non_admin_stuff = ->
  $('body').css('visibility', 'hidden').children().hide()
  $('body>.houston').show()
  @next()
remove_host_css = ->
  $('link[rel="stylesheet"]').remove()
  @next()

BASE_HOUSTON_ROUTES = ['home', 'collection', 'document', 'change_password', 'custom_template']
ALL_HOUSTON_ROUTES = BASE_HOUSTON_ROUTES.concat(['login'])
Router.onBeforeAction mustBeAdmin,
  only: (Houston._houstonize_route(name) for name in BASE_HOUSTON_ROUTES)
Router.onBeforeAction hide_non_admin_stuff,
  only: (Houston._houstonize_route(name) for name in ALL_HOUSTON_ROUTES)
Router.onBeforeAction remove_host_css,
  only: (Houston._houstonize_route(name) for name in ALL_HOUSTON_ROUTES)

onRouteNotFound = Router.onRouteNotFound
Router.onRouteNotFound = (args...) ->
  non_houston_routes = _.filter(Router.routes, (route) -> route.name.indexOf('houston_') != 0)
  if non_houston_routes.length > 0
    onRouteNotFound.apply Router, args
  else
    console.log "Note: Houston is suppressing Iron-Router errors because we don't think you are using it."
