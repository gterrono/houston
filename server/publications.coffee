Dummy = new Meteor.Collection("system.dummy")  # hack.
collections = {'users': Meteor.users}

Meteor.startup ->
  Dummy.findOne()  # hack
  save_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "admin_") isnt 0)
    for name in collection_names
      unless name of collections
        console.log "gonna instantiate #{name}"
        collections[name] = new Meteor.Collection(name)
        publish_to_admin "admin_#{name}", -> collections[name].find()
        Collections.insert {name} unless Collections.findOne {name}
  fn = Meteor.bindEnvironment save_collections, (e) ->
    console.log e.stack
  Meteor._RemoteCollectionDriver.mongo.db.collections fn

publish_to_admin = (name, publish_func) ->
  Meteor.publish name, ->
    console.log "wanna publish", @userId
    if Meteor.users.findOne({_id: @userId, 'profile.admin': true})
      console.log "publishd"
      publish_func()


# publish our own internal state

publish_to_admin -> Collections.find()
Meteor.publish 'adminUser', ->  # used by login page to see if admin has been created yet
  Meteor.users.find({'profile.admin': true}, fields: 'profile.admin': true)
