if Handlebars?
  Handlebars.registerHelper('onHoustonPage', ->
    window.location.pathname.indexOf('/admin') == 0)

Houston._collections ?= {}

# regardless of what version of meteor we are using,
# get the right LocalCollection
Houston._get_collection = (collection_name) ->
  unless Houston._collections[collection_name]
    try
      # you can only instantiate a collection once
      Houston._collections[collection_name] = new Meteor.Collection(collection_name)
    catch e
      try
        # works for 0.6.6.2+
        Houston._collections[collection_name] = \
          Meteor.connection._mongo_livedata_collections[collection_name]
      catch e
        # old versions of meteor (older than 0.6.6.2)
        Houston._collections[collection_name] =
          Meteor._LocalCollectionDriver.collections[collection_name]

  return Houston._collections[collection_name]

Houston._session = (key, value) ->
  key = Houston._houstonize(key)
  return Session.get(key) unless value?
  Session.set(key, value)
