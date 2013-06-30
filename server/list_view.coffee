Dummy = new Meteor.Collection("system.dummy")  # hack
collections = {}
Meteor.startup ->
  Dummy.findOne()  # hack
  save_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "admin_") isnt 0)
    for name in collection_names
      if name not in collections
        collections[name] = new Meteor.Collection(name)
        # TODO admin user only
        Meteor.publish "admin_#{name}", -> collections[name].find()
        Collections.insert {name} unless Collections.findOne {name}
    Meteor.publish "admin", -> Collections.find()
  fn = Meteor.bindEnvironment save_collections, (e) ->
    console.log e.stack
  Meteor._RemoteCollectionDriver.mongo.db.collections fn
