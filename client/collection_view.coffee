Template.collection_view.helpers
  headers: -> get_fields get_collection()
  document_url: -> "/admin/#{Session.get('collection_name')}/#{@._id}"
  document_id: -> @._id
  rows: ->
    sort_by = {}
    sort_by[Session.get('key')] = Session.get('sort_order')
    get_collection()?.find({}, {sort: sort_by}).fetch()
  values: ->
    _.values(_.omit(@, '_id'))  # _id is special-cased in template

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

get_fields = (collection) ->
  key_to_type = {}
  collection.find({}, {limit: 20}).forEach (document) ->
    # TODO here recursive types (IE User.profiles.name)
    for key, value of document
      key_to_type[key] = typeof value

  (name: key, type: value for key, value of key_to_type)

Template.collection_view.events
  "click a.sort": (e) ->
      e.preventDefault()
      if (Session.get('key') == this.name)
        Session.set('sort_order', Session.get('sort_order') * - 1) 
      else
        Session.set('key', this.name)
        Session.set('sort_order', 1)
