root = exports ? this
Houston._HIDDEN_COLLECTIONS = {'users': Meteor.users, 'meteor_accounts_loginServiceConfiguration': undefined}
ADDED_COLLECTIONS = {}
# TODO: describe what this is, exactly, and how it differs from Houston._collections.

Houston._publish = (name, func) ->
  Meteor.publish Houston._houstonize(name), func

Houston._setup_collection = (collection) ->
  name = collection._name
  return if name of ADDED_COLLECTIONS

  Houston._setup_collection_methods(collection)

  Houston._publish name, (sort, filter, limit, unknown_arg) ->
    check sort, Match.Optional(Object)
    check filter, Match.Optional(Object)
    check limit, Match.Optional(Number)
    check unknown_arg, Match.Any
    unless Houston._user_is_admin @userId
      @ready()
      return
    try
      collection.find(filter, sort: sort, limit: limit)
    catch e
      console.log e

  collection.find().observe
    _suppress_initial: true  # fixes houston for large initial datasets
    added: (document) ->
      Houston._collections.collections.update {name},
        $inc: {count: 1},
        $addToSet: fields: $each: Houston._get_fields([document])
    changed: (document) ->
      Houston._collections.collections.update {name},
        $addToSet: fields: $each: Houston._get_fields([document])
    removed: (document) ->
      Houston._collections.collections.update {name}, {$inc: {count: -1}}

  fields = Houston._get_fields_from_collection(collection)
  c = Houston._collections.collections.findOne {name}
  count = collection.find().count()
  if c
    Houston._collections.collections.update c._id, {$set: {count, fields}}
  else
    Houston._collections.collections.insert {name, count, fields}
  ADDED_COLLECTIONS[name] = collection

sync_collections = ->
  Houston._admins.findOne() # TODO Why is this here?

  collections = {}
  for collection in (Mongo.Collection.getAll() ? [])
    collections[collection.name] = collection.instance

  _sync_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "houston_") isnt 0 and
           (col.collectionName.indexOf "cfs") isnt 0)

    collection_names.forEach (name) ->
      unless name of ADDED_COLLECTIONS or name of Houston._HIDDEN_COLLECTIONS
        Houston._setup_collection(collections[name]) if collections[name]?

  bound_sync_collections = Meteor.bindEnvironment _sync_collections, (e) ->
    console.log "Failed while syncing collections for reason: #{e}"

  # MongoInternals is the 'right' solution as of 0.6.5
  mongo_driver = MongoInternals?.defaultRemoteCollectionDriver() or Meteor._RemoteCollectionDriver
  mongo_driver.mongo.db.collections bound_sync_collections

Meteor.methods
  _houston_make_admin: (user_id) ->
    check user_id, String
    # limit one admin
    return if Houston._admins.findOne {'user_id': $exists: true}
    Houston._admins.insert {user_id}
    Houston._admins.insert {exists: true}
    sync_collections() # reloads collections in case of new app
    return true

# publish our analysis of the app's collections
Houston._publish 'collections', ->
  unless Houston._user_is_admin @userId
    @ready()
    return
  Houston._collections.collections.find()

# TODO address inherent security issue
Houston._publish 'admin_user', ->
  unless Houston._user_is_admin @userId
    return Houston._admins.find {exists: true}
  return Houston._admins.find {}

Meteor.startup ->
  sync_collections()
  if Houston._admins.find().count() > 0 and !Houston._admins.findOne({exists: true})
    Houston._admins.insert {exists: true}
