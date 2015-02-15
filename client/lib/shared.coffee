Houston._admin_user_exists = -> Houston._admins.find().count() > 0

Houston.becomeAdmin = ->
  Houston._call 'make_admin', Meteor.userId(), ->
    Houston._subscribe_to_collections() # resubscribe so you get them
    Houston._go 'home'

Houston._subscribe_to_collections = ->
  Houston._collections_sub.stop() if Houston._collections_sub?
  Houston._collections_sub = Houston._subscribe 'collections'

Handlebars.registerHelper 'currentUserIsAdmin', ->
  Houston._user_is_admin(Meteor.userId())

Handlebars.registerHelper 'adminUserExists', Houston._admin_user_exists

Houston._collections ?= {}

# regardless of what version of meteor we are using,
# get the right LocalCollection
Houston._get_collection = (collection_name) ->
  Houston._collections[collection_name] =
    Meteor.connection._mongo_livedata_collections[collection_name] or
    new Meteor.Collection(collection_name)
  return Houston._collections[collection_name]

Houston._session = ->
  key = Houston._houstonize(arguments[0])
  if arguments.length == 1
    return Session.get(key)
  else if arguments.length == 2
    Session.set(key, arguments[1])

Houston._call = (name, args...) ->
  Meteor.call(Houston._houstonize(name), args...)

Houston._nested_field_lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object

  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here

  # Return date objects and other non-object types
  if typeof result isnt 'object' or result instanceof Date
    return result
  else
    return ''

Houston._convert_to_correct_type = (field, val, collection) ->
  find_obj = {}
  find_obj[field] = $exists: true
  one = collection.findOne(find_obj)
  fields = _.object(_.map(Houston._collections.collections.findOne({name: collection.name}).fields, (field) -> # TODO it may be too heavy
    [
      field.name
      type: field.type
    ]
  ))
  constructor = window[fields[field].type]
  if not one and constructor
    if constructor is Boolean # special case for new Boolean()
      val == 'true'
    else
      new constructor(val)
  else
    sample_val = Houston._nested_field_lookup(one, field)
    constructor = sample_val.constructor
    if typeof sample_val == 'object'
      new constructor(val)
    else if typeof sample_val == 'boolean'
      val == 'true'
    else
      constructor(val)

Houston._get_type = (field, collection) ->
  find_obj = {}
  find_obj[field] =
    $exists: true
  sample_val = Houston._nested_field_lookup(collection.findOne(find_obj), field)
  typeof sample_val
