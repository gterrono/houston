admin_user_exists = () -> Houston._admins.find().count() > 0

Handlebars.registerHelper 'currentUserIsAdmin', ->
  Houston._user_is_admin(Meteor.userId())

Handlebars.registerHelper 'adminUserExists', admin_user_exists

Houston._collections ?= {}

# regardless of what version of meteor we are using,
# get the right LocalCollection
Houston._get_collection = (collection_name) ->
  unless Houston._collections[collection_name]
    try
      # you can only instantiate a collection once
      Houston._collections[collection_name] = new Meteor.Collection(collection_name)
    catch e
      try
        # works for 0.6.6.2+
        Houston._collections[collection_name] = \
          Meteor.connection._mongo_livedata_collections[collection_name]
      catch e
        # old versions of meteor (older than 0.6.6.2)
        Houston._collections[collection_name] =
          Meteor._LocalCollectionDriver.collections[collection_name]

  return Houston._collections[collection_name]

Houston._session = () ->
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
  sample_val = Houston._nested_field_lookup(collection.findOne(find_obj), field)
  constructor = sample_val.constructor
  if typeof sample_val == 'object'
    new constructor(val)
  else
    constructor(val)

Houston._get_type = (field, collection) ->
  find_obj = {}
  find_obj[field] =
    $exists: true
  sample_val = Houston._nested_field_lookup(collection.findOne(find_obj), field)
  typeof sample_val
