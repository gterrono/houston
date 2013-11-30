root = exports ? this

Dummy = new Meteor.Collection("system.dummy")  # hack.
collections = {'users': Meteor.users}

Meteor.startup ->
  set_up_collection = (name, collection) ->
    methods = {}
    methods["_houston_#{name}_insert"] = (doc) ->
      return unless @userId
      user = Meteor.users.findOne(@userId)
      return unless user?.profile.admin
      collection.insert(doc)

    methods["_houston_#{name}_update"] = (id, update_dict) ->
      return unless @userId
      user = Meteor.users.findOne(@userId)
      return unless user?.profile.admin
      if collection.findOne(id)
        collection.update(id, update_dict)
      else
        id = collection.findOne(new Meteor.Collection.ObjectID(id))
        collection.update(id, update_dict)

    methods["_houston_#{name}_delete"] = (id, update_dict) ->
      return unless @userId
      user = Meteor.users.findOne(@userId)
      return unless user?.profile.admin
      if collection.findOne(id)
        collection.remove(id)
      else
        id = collection.findOne(new Meteor.Collection.ObjectID(id))
        collection.remove(id)

    Meteor.methods methods

    Meteor.publish "_houston_#{name}", (sort, filter, limit) ->
      if Meteor.users.findOne(_id: @userId, 'profile.admin': true)
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

  Dummy.findOne()  # hack

  save_collections = (meh, collections_db) ->
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

        set_up_collection(name, collections[name])

  Meteor.methods
    _houston_make_admin: (userId) ->
      # limit one admin
      return if Meteor.users.findOne {'profile.admin': true}
      Meteor.users.update userId, $set: {'profile.admin': true}
      return true

  fn = Meteor.bindEnvironment save_collections, (e) ->
    console.log e

  # MongoInternals is the 'right' solution as of 0.6.5
  mongo_driver = MongoInternals?.defaultRemoteCollectionDriver() or Meteor._RemoteCollectionDriver
  mongo_driver.mongo.db.collections fn


# publish our own internal state
Meteor.publish '_houston', ->
  if Meteor.users.findOne(_id: @userId, 'profile.admin': true)
    Houston._collections.collections.find()


Meteor.publish '_houston_adminUser', ->  # used by login page to see if admin has been created yet
  Meteor.users.find({'profile.admin': true}, fields: 'profile.admin': true)
