window.Houston ?= {}

Houston._ROOT_ROUTE = Meteor.settings?.public?.houston_root_route or "/admin"
Houston._page_length = Meteor.settings?.public?.houston_documents_per_page or 20
Houston._subscribe = (name) -> Meteor.subscribe Houston._houstonize name

Houston._subscribe_to_collections()

setup_collection = (collection_name, document_id) ->
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
  FlowRouter.go Houston._houstonize_route(route_name), options


houston_route = (route_name, options) =>
  # Append _houston_ to template and route names to avoid clobbering parent route namespace
  options.layoutTemplate = '_houston_master_layout'
  options.name = Houston._houstonize_route(route_name)
  options.template = Houston._houstonize(options.template)
  options.waitOn = ->
    subscriptions = if options.subs then options.subs(this.params) else []
    subscriptions.push Houston._subscribe('admin_user')
    subscriptions
  options.action = (params) ->
    # keep iron-router style this.params working via .call
    data = options.data?.call({params})
    BlazeLayout.render options.layoutTemplate,
      {template: options.template, data}
  FlowRouter.route "#{Houston._ROOT_ROUTE}#{options.houston_path}", options

houston_route 'home',
  houston_path: '/'
  template: 'db_view'
  waitOn: -> Houston._collections

houston_route 'login',
  houston_path: "/login"
  template: 'login'

houston_route 'change_password',
  houston_path: "/password"
  template: 'change_password'

houston_route 'custom_template',
  houston_path: "/actions/:template"
  template: 'custom_template_view'
  data: -> this.params

houston_route 'collection',
  houston_path: "/:collection_name"
  data: -> {name: @params.collection_name}
  subs: (params) -> [setup_collection(params.collection_name)]
  template: 'collection_view'

houston_route 'document',
  houston_path: "/:collection/:_id"
  data: ->
    @subscription = setup_collection(@params.collection, @params._id)
    collection = Houston._get_collection(@params.collection)
    document = collection.findOne _id: @params._id
    {document, collection, name: @params.collection}
  template: 'document_view'

# ########
# filters
# ########
mustBeAdmin = ->
  if !Meteor.user()
    if Meteor.loggingIn()
      console.log "logging in, TODO(AMK) do a nice job"
    else
      Houston._go 'login'
  else
    console.log "should check if ready I guess... TODO(AMK) "
    if not Houston._user_is_admin Meteor.userId()
      Houston._go 'login'

# If the host app doesn't have a router, their html may show up
hide_non_admin_stuff = ->
  $('body').css('visibility', 'hidden').children().hide()
  $('body>.houston').show()
remove_host_css = ->
  $('link[rel="stylesheet"]').remove()

BASE_HOUSTON_ROUTES = (Houston._houstonize_route(name) for name in ['home', 'collection', 'document', 'change_password', 'custom_template'])
ALL_HOUSTON_ROUTES = BASE_HOUSTON_ROUTES.concat([Houston._houstonize_route('login')])
FlowRouter.triggers.enter([mustBeAdmin], only: BASE_HOUSTON_ROUTES)
FlowRouter.triggers.enter(
  [hide_non_admin_stuff, remove_host_css],
  only: ALL_HOUSTON_ROUTES)

Template.registerHelper 'pathFor', (route, args) ->
  FlowRouter.path(route, args.hash)

originalNotFound = FlowRouter.notFound
FlowRouter.notFound =
  action: (args...) ->
    non_houston_routes = _.filter(
      FlowRouter._routes,
      (route) -> route.name? and route.name.indexOf('houston_') != 0)
    if non_houston_routes.length > 0
      originalNotFound.action(args...)
    else
      console.log "Note: Houston is suppressing Iron-Router errors because we don't think you are using it."
