root = exports ? this

Dummy = new Meteor.Collection("system.dummy")  # hack.
collections = {'users': Meteor.users}

Houston._publish = (name, func) ->
  Meteor.publish Houston._houstonize(name), func

setup_collection = (name, collection) ->
  methods = {}
  methods[Houston._houstonize "#{name}_insert"] = (doc) ->
    return unless Houston._user_is_admin @userId
    collection.insert(doc)

  methods[Houston._houstonize "#{name}_update"] = (id, update_dict) ->
    return unless Houston._user_is_admin @userId
    if collection.findOne(id)
      collection.update(id, update_dict)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.update(id, update_dict)

  methods[Houston._houstonize "#{name}_delete"] = (id, update_dict) ->
    return unless Houston._user_is_admin @userId
    if collection.findOne(id)
      collection.remove(id)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.remove(id)

  Meteor.methods methods

  Houston._publish name, (sort, filter, limit) ->
    return unless Houston._user_is_admin @userId
    try
      collection.find(filter, sort: sort, limit: limit)
    catch e
      console.log e

  collection.find().observe
    added: (document) ->
      Houston._collections.collections.update {name},
        $inc: {count: 1},
        $addToSet: fields: $each: Houston._get_field_names([document])
    removed: (document) -> Houston._collections.collections.update {name}, {$inc: {count: -1}}

  fields = Houston._get_field_names(collection.find().fetch())
  c = Houston._collections.collections.findOne {name}
  if c
    Houston._collections.collections.update c._id, {$set: count: collection.find().count(), fields: fields}
  else
    Houston._collections.collections.insert {name, count: collection.find().count(), fields: fields}
  console.log "synced #{name}"

sync_collections = (meh, collections_db) ->
  collection_names = (col.collectionName for col in collections_db \
    when (col.collectionName.indexOf "system.") isnt 0 and
         (col.collectionName.indexOf "houston_") isnt 0)

  collection_names.forEach (name) ->
    unless name of collections
      try
        collections[name] = new Meteor.Collection(name)
      catch e
        for key, value of root
          if name == value._name
            collections[name] = value
        console.log e unless collections[name]?

      setup_collection(name, collections[name])
  console.log "sync collections done"

Meteor.startup ->
  Dummy.findOne()  # hack. TODO: verify this is still necessary

  # TODO put bindEnvironment as part of syncCollections
  sync_fn = Meteor.bindEnvironment sync_collections, (e) ->
    console.log "sync error"
    console.log e

  # MongoInternals is the 'right' solution as of 0.6.5
  mongo_driver = MongoInternals?.defaultRemoteCollectionDriver() or Meteor._RemoteCollectionDriver
  mongo_driver.mongo.db.collections sync_fn

Meteor.methods
  _houston_make_admin: (userId) ->
    # limit one admin
    console.log "making admin: #{userId}"
    return if Houston._admins.findOne {'user_id': $exists: true}
    Houston._admins.insert user_id: userId
    return true

# publish our analysis of the app's collections
Houston._publish 'collections', ->
  return unless Houston._user_is_admin @userId
  Houston._collections.collections.find()

# used by login page to see if admin has been created yet
Houston._publish 'admin_user', ->
  if Houston._user_is_admin @userId
    return Houston._admins.find user_id: @userId
  Houston._admins.find {user_id: $exists: true}, fields: _id: true
