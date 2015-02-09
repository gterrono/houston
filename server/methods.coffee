# shared meteor methods
require_admin = (func) ->
  -> func.apply(@, arguments) if Houston._user_is_admin @userId

Houston.methods = (collection, raw_methods) ->
  collection_name = collection.name or collection._name or collection
  method_names = _(raw_methods).keys()
  Houston._collections.collections.update({name: collection_name}, {$set: {method_names}})

  methods = {}
  for func_name, func of raw_methods
    methods[Houston._custom_method_name(collection_name, func_name)] = require_admin(func)

  Meteor.methods methods

Houston._setup_collection_methods = (collection) ->
  name = collection._name
  methods = {}
  methods[Houston._houstonize "#{name}_insert"] = require_admin (doc) ->
    check doc, Object
    collection.insert(doc)

  methods[Houston._houstonize "#{name}_update"] = require_admin (id, update_dict) ->
    check id, Match.Any
    check update_dict, Object
    if collection.findOne(id)
      collection.update(id, update_dict)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.update(id, update_dict)

    "#{collection._name} #{id} saved successfully"

  methods[Houston._houstonize "#{name}_delete"] = require_admin (id) ->
    check id, Match.Any
    if collection.findOne(id)
      collection.remove(id)
    else
      id = collection.findOne(new Meteor.Collection.ObjectID(id))
      collection.remove(id)

  methods[Houston._houstonize "#{name}_deleteAll"] = require_admin () ->
    collection.remove({})






  Meteor.methods(methods)
