Dummy = new Meteor.Collection("system.dummy")  # hack.
collections = {}
Meteor.startup ->
  Dummy.findOne()  # hack
  Meteor._RemoteCollectionDriver.mongo.db.collections (meh, collections) ->
    collection_names = (col.collectionName for col in collections \
      when (col.collectionName.indexOf "system.") isnt 0)
    for name in collection_names
      if name not in collections
        collections[name] = new Meteor.Collection(name)
        # TODO admin user only
        # Meteor.publish "admin_#{name}", -> collections[name].find()
    Meteor.publish "admin", -> _.invoke collections, 'find'
