Template.list_view.helpers
  headers: -> get_fields get_collection()
  rows: ->
    get_collection().find().fetch()
  values: ->
    console.log "@ is " + @
    _.values(@)

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

get_fields = (collection) ->
  key_to_type = {}
  console.log "noloop'd'"
  collection.find({}, {limit: 20}).forEach (document) ->
    # TODO here recursive types (IE User.profiles.name)
    for key, value of document
      key_to_type[key] = typeof value
  console.log "loop'd", key_to_type
  (name: key, type: value for key, value of key_to_type)
