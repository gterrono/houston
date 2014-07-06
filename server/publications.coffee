root = exports ? this
Houston._HIDDEN_COLLECTIONS = {'users': Meteor.users, 'meteor_accounts_loginServiceConfiguration': undefined}
ADDED_COLLECTIONS = {}
# TODO: describe what this is, exactly, and how it differs from Houston._collections.

Dummy = new Meteor.Collection("system.dummy")  # hack.

Houston._publish = (name, func) ->
  Meteor.publish Houston._houstonize(name), func

Houston._setup_collection = (collection) ->
  return if collection._name of ADDED_COLLECTIONS

  name = collection._name
  methods = {}
  methods[Houston._houstonize "#{name}_insert"] = (doc) ->
    check doc, Object
    return unless Houston._user_is_admin @userId
    collection.insert(doc)

  methods[Houston._houstonize "#{name}_update"] = (id, update_dict) ->
    check id, Match.Any
    check update_dict, Object
    return unless Houston._user_is_admin @userId
    if collection.findOne(id)
      collection.update(id, update_dict)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.update(id, update_dict)

  methods[Houston._houstonize "#{name}_delete"] = (id) ->
    check id, Match.Any
    return unless Houston._user_is_admin @userId
    if collection.findOne(id)
      collection.remove(id)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.remove(id)

  Meteor.methods methods

  Houston._publish name, (sort, filter, limit, unknown_arg) ->
    check sort, Match.Optional(Object)
    check filter, Match.Optional(Object)
    check limit, Match.Optional(Number)
    check unknown_arg, Match.Any
    return unless Houston._user_is_admin @userId
    try
      collection.find(filter, sort: sort, limit: limit)
    catch e
      console.log e

  collection.find().observe
    added: (document) ->
      Houston._collections.collections.update {name},
        $inc: {count: 1},
        $addToSet: fields: $each: Houston._get_fields([document])
    removed: (document) -> Houston._collections.collections.update {name}, {$inc: {count: -1}}

  fields = Houston._get_fields(collection.find().fetch())
  c = Houston._collections.collections.findOne {name}
  if c
    Houston._collections.collections.update c._id, {$set: count: collection.find().count(), fields: fields}
  else
    Houston._collections.collections.insert {name, count: collection.find().count(), fields: fields}
  ADDED_COLLECTIONS[name] = collection

sync_collections = ->
  Dummy.findOne()  # hack. TODO: verify this is still necessary

  _sync_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "houston_") isnt 0)

    collection_names.forEach (name) ->
      unless name of ADDED_COLLECTIONS or name of Houston._HIDDEN_COLLECTIONS
        new_collection = null
        try
          new_collection = new Meteor.Collection(name)
        catch e
          for key, value of root
            if name == value?._name # TODO here - typecheck also?
              new_collection = value

        if new_collection?  # found it!
          Houston._setup_collection(new_collection)
        else
          console.log """
Houston: couldn't find access to the #{name} collection.
If you'd like to access the collection from Houston, either
(1) make sure it is available as a global (top-level namespace) within the server or
(2) add the collection manually via Houston.add_collection
"""

  bound_sync_collections = Meteor.bindEnvironment _sync_collections, (e) ->
    console.log "Failed while syncing collections for reason: #{e}"

  if Meteor.settings.app_mongourl?
    # for Houston-Hook, we may want to use an alternate mongo-url
    mongo_driver = new MongoInternals.RemoteCollectionDriver(Meteor.settings.app_mongourl, {})
    console.log("Using hook-based mongo driver")
  else
  # MongoInternals is the 'right' solution as of 0.6.5
    console.log("Using normal mongo driver")
    mongo_driver = MongoInternals?.defaultRemoteCollectionDriver() or Meteor._RemoteCollectionDriver
  console.log(mongo_driver, MongoInternals.defaultRemoteCollectionDriver())
  mongo_driver.mongo.db.collections bound_sync_collections

Meteor.methods
  _houston_make_admin: (user_id) ->
    check user_id, String
    # limit one admin
    return if Houston._admins.findOne {'user_id': $exists: true}
    Houston._admins.insert {user_id}
    sync_collections() # reloads collections in case of new app
    return true

# publish our analysis of the app's collections
Houston._publish 'collections', ->
  return unless Houston._user_is_admin @userId
  Houston._collections.collections.find()

# TODO address inherent security issue
Houston._publish 'admin_user', ->
  Houston._admins.find {}

Meteor.startup ->
  sync_collections()
