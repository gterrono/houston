Dummy = new Meteor.Collection("system.dummy")  # hack.
collections = {'users': Meteor.users}

Meteor.startup ->
  Dummy.findOne()  # hack
  save_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "admin_") isnt 0)
    # fucking closures bro
    collection_names.forEach (name) ->
      unless name of collections
        collections[name] = new Meteor.Collection(name)
        collections[name].allow(
          update: (userId, doc, fields, modifier) ->
            user = Meteor.users.findOne(userId)
            user.profile.admin
          insert: (userId, doc) ->
            user = Meteor.users.findOne(userId)
            user.profile.admin
        )
        publish_to_admin "admin_#{name}", -> collections[name].find()
        Collections.insert {name} unless Collections.findOne {name}

  fn = Meteor.bindEnvironment save_collections, (e) ->
    console.log e.stack
  Meteor._RemoteCollectionDriver.mongo.db.collections fn

publish_to_admin = (name, publish_func) ->
  Meteor.publish name, ->
    if Meteor.users.findOne(_id: @userId, 'profile.admin': true)
      publish_func()


# publish our own internal state

publish_to_admin "admin", -> Collections.find()

Meteor.publish 'adminUser', ->  # used by login page to see if admin has been created yet
  Meteor.users.find({'profile.admin': true}, fields: 'profile.admin': true)
