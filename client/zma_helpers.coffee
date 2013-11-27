if Handlebars?
  Handlebars.registerHelper('onHoustonPage', ->
    window.location.pathname.indexOf('/houston') == 0)

# regardless of what version of meteor we are using,
# get the right LocalCollection
Houston._get_collection = (collection_name) ->
  unless Houston[collection_name]
    try
      # you can only instantiate a collection once
      Houston[collection_name] = new Meteor.Collection(collection_name)
    catch e
      try
        # works for 0.6.6.2+
        Houston[collection_name] = \
          Meteor.connection._mongo_livedata_collections[collection_name]
      catch e
        # old versions of meteor (older than 0.6.6.2)
        Houston[collection_name] =
          Meteor._LocalCollectionDriver.collections[collection_name]

  return Houston[collection_name]
