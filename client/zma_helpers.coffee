if Handlebars?
  Handlebars.registerHelper('isAdminPage', ->
    window.location.pathname.indexOf('/admin') == 0)

# regardless of what version of meteor we are using,
# get the right LocalCollection
window.get_collection = (collection_name) ->
  COLLECTION_STORAGE = window # TODO find a better global object
  inspector_name = "inspector_#{collection_name}"

  unless COLLECTION_STORAGE[inspector_name]
    try
      # you can only instantiate a collection once
      COLLECTION_STORAGE[inspector_name] = new Meteor.Collection(collection_name)
    catch e
      try
        # works for 0.6.6.2+
        COLLECTION_STORAGE[inspector_name] = \
          Meteor.connection._mongo_livedata_collections[collection_name]
      catch e
        # old versions of meteor (older than 0.6.6.2)
        COLLECTION_STORAGE[inspector_name] =
          Meteor._LocalCollectionDriver.collections[collection_name]

  return COLLECTION_STORAGE[inspector_name]
