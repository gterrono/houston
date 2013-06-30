Template.collection_view.helpers
  headers: -> get_fields get_collection()
  document_url: -> "/admin/#{Session.get('collection_name')}/#{@._id}"
  document_id: -> @._id
  rows: ->
    sort_by = {}
    sort_by[Session.get('key')] = Session.get('sort_order')
    get_collection()?.find({}, {sort: sort_by}).fetch()
  values_in_order: ->
    fields_in_order = _.pluck(get_fields(get_collection()), 'name')
    lookup = (object, path) ->
      result = object
      for part in path.split(".")
        result = result[part]
        return '' unless result?  # quit if you can't find anything here
      if typeof result isnt 'object' then result else ''
    (lookup(@, field_name) for field_name in fields_in_order[1..])  # skip _id

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

get_fields = (collection) ->
  key_to_type = {_id: 'ObjectId'}
  find_fields = (document, prefix='') ->
    for key, value of _.omit(document, '_id')
      if typeof value is 'object'
        find_fields value, "#{prefix}#{key}."
      else if typeof value isnt 'function'
        full_path_key = "#{prefix}#{key}"
        key_to_type[full_path_key] = typeof value

  collection.find({}, {limit: 50}).forEach (document) ->
    find_fields document

  (name: key, type: value for key, value of key_to_type)

Template.collection_view.events
  "click a.sort": (e) ->
      e.preventDefault()
      if (Session.get('key') == this.name)
        Session.set('sort_order', Session.get('sort_order') * - 1)
      else
        Session.set('key', this.name)
        Session.set('sort_order', 1)
