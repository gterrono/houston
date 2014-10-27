# shared meteor methods
Houston._setup_collection_methods = (collection) ->
  return  unless Meteor.isServer
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

  Meteor.methods(methods)
