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

Houston._session = () ->
  key = Houston._houstonize(arguments[0])
  if arguments.length == 1
    return Session.get(key)
  else if arguments.length == 2
    Session.set(key, arguments[1])

Houston._call = (name, args...) ->
  Meteor.call(Houston._houstonize(name), args...)

Houston._nested_field_lookup = (object, path) ->
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''

Houston._css_files = ["//terrono.com/houston/style.css", "//terrono.com/houston/bootstrap.css"]
# For development:
# Houston._css_files = ["/packages/houston/public/style.css", "/packages/houston/public/bootstrap.css"]]
