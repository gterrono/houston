root = exports ? this

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
        try
          collections[name] = new Meteor.Collection(name)
        catch e
          # fuck bitches, get collections
          for key, value of root
            if name == value._name
              collections[name] = value
          console.log e

        methods = {}
        methods["admin_#{name}_insert"] = (doc) ->
          return unless @userId
          user = Meteor.users.findOne(@userId)
          return unless user?.profile.admin
          collections[name].insert(doc)

        methods["admin_#{name}_update"] = (id, update_dict) ->
          return unless @userId
          user = Meteor.users.findOne(@userId)
          return unless user?.profile.admin
          if collections[name].findOne(id)
            collections[name].update(id, update_dict)
          else
            id = collections[name].findOne(new Meteor.Collection.ObjectID(id))
            collections[name].update(id, update_dict)

        Meteor.methods methods

        publish_to_admin "admin_#{name}", ->
          try
            collections[name].find()
          catch e
            console.log e
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
