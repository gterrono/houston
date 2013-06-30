Template.collection_view.helpers
  headers: -> get_fields get_collection()
  nonid_headers: -> (get_fields get_collection())[1..]
  document_url: -> "/admin/#{Session.get('collection_name')}/#{@_id}"
  document_id: -> @_id + ""
  rows: ->
    sort_by = {}
    sort_by[Session.get('key')] = Session.get('sort_order')
    query = _.extend({}, (Session.get('top_selector')),
                     (Session.get('field_selectors')))
    get_collection()?.find(query, {sort: sort_by}).fetch()
  values_in_order: ->
    fields_in_order = _.pluck(get_fields(get_collection()), 'name')
    names_in_order = _.clone fields_in_order
    lookup = (object, path) ->
      result = object
      for part in path.split(".")
        result = result[part]
        return '' unless result?  # quit if you can't find anything here
      if typeof result isnt 'object' then result else ''
    values = (lookup(@, field_name) for field_name in fields_in_order[1..])  # skip _id
    ({value, name} for [value, name] in _.zip values, names_in_order[1..])

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
  'keyup #filter_selector': (event) ->
    return unless event.keyCode is 13  # enter
    try
      selector_json = JSON.parse($('#filter_selector').val())
      Session.set('top_selector', selector_json)
    catch error
      Session.set('top_selector', {})
  'dblclick .collection-field': (e) ->
    $this = $(e.currentTarget)
    $this.removeClass('collection-field')
    $this.html "<input type='text' value='#{$this.text()}'>"
    $this.find('input').select()
    $this.find('input').on 'blur', ->
      updated_val = $this.find('input').val()
      # $this.html updated_val
      # $this.addClass('collection-field')
      id = $('td:first-child a', $this.parents('tr')).html()
      field_name = $this.data('field')
      update_dict = {}
      update_dict[field_name] = updated_val
      console.log update_dict
      Meteor.call("admin_#{Session.get('collection_name')}_update",
        id, $set: update_dict)

  'change .column_filter': (event...) ->
    field_selectors = {}
    $('.column_filter').each (idx, item) ->
      if item.value
        field_selectors[item.name] = item.value
    Session.set 'field_selectors', field_selectors
