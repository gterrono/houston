# TODO this should be refactored

schemaToInputType = (type) ->
  d = {
    number: 'number'
    string: 'text'
    boolean: 'checkbox'
  }
  if type of d
    d[type]
  else
    'text'

get_sort_by = ->
  sort_by = {}
  sort_by[Houston._session('sort_key')] = Houston._session('sort_order')
  return sort_by

get_filter_query = ->
  # Make find query using the filter stored in the session. The regexes are
  # escaped, but $regex is used so it can match anywhere in the string.
  query = {}
  fill_query_with_regex = (session_key) ->
    return unless Houston._session(session_key)?
    for key, val of Houston._session(session_key)
      # From http://stackoverflow.com/questions/3115150/how-to-escape-regular-expression-special-characters-using-javascript#answer-9310752
      query[key] =
        $regex: val.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
  fill_query_with_regex('field_selectors')
  return query

resubscribe = ->
  # Stop the old subscription and resubscribe with the new filter/sort
  subscription_name = "_houston_#{Houston._session('collection_name')}"
  Houston._paginated_subscription.stop()
  Houston._paginated_subscription =
    Meteor.subscribeWithPagination subscription_name,
      get_sort_by(), get_filter_query(),
      Houston._page_length

collection_info = -> Houston._collections.collections.findOne(name: Houston._session('collection_name'))

collection_count = -> collection_info()?.count

Template._houston_collection_view.helpers
  headers: -> get_collection_view_fields()
  nonid_headers: -> get_collection_view_fields()[1..]
  col_name: -> Houston._session('collection_name')
  document_id: -> @_id + ""
  num_of_records: ->
    collection_count() or "no"
  pluralize: -> 's' unless collection_count() == 1
  rows: ->
    collection = Houston._session('collection_name')
    documents = get_current_collection()?.find(get_filter_query(), {sort: get_sort_by()}).fetch()
    _.map documents, (d) ->
      d.collection = collection
      d._id = d._id._str or d._id
      return d
  values_in_order: ->
    fields_in_order = get_collection_view_fields()
    names_in_order = _.clone fields_in_order
    values = (Houston._nested_field_lookup(@, field.name) for field in fields_in_order[1..]) # skip _id
    ({field_value, field_name} for [field_value, {name: field_name}] in _.zip values, names_in_order[1..])
  filter_value: ->
    if Houston._session('field_selectors') and Houston._session('field_selectors')[@]
      Houston._session('field_selectors')[@]
    else
      ''

Template._houston_collection_view.rendered = ->
  $win = $(window)
  $win.scroll ->
    if $win.scrollTop() + 300 > $(document).height() - $win.height() and
      Houston._paginated_subscription.limit() < collection_count()
      Houston._paginated_subscription.loadNextPage()

get_current_collection = -> Houston._get_collection(Houston._session('collection_name'))
get_collection_view_fields = -> collection_info()?.fields or []

Template._houston_collection_view.events
  "click a.houston-sort": (e) ->
    e.preventDefault()
    sort_key = this.name
    if (Houston._session('sort_key') == sort_key)
      Houston._session('sort_order', Houston._session('sort_order') * -1)
    else
      Houston._session('sort_key', sort_key)
      Houston._session('sort_order', 1)
    resubscribe()

  'dblclick .houston-collection-field': (e) ->
    $this = $(e.currentTarget)
    field_name = $this.data('field')
    type = Houston._get_type(field_name, get_current_collection())
    input = 'text' #TODO schemaToInputType type fix on blur bug
    $this.removeClass('houston-collection-field')
    $this.html "<input type='#{input}' class='input-sm form-control' placeholder='#{type}' value='#{$this.text().trim()}'>"
    $this.find('input').select()
    $this.find('input').on 'blur', ->
      updated_val = $this.find('input').val()
      $this.html updated_val
      $this.addClass('houston-collection-field')
      id = $('td:first-child a', $this.parents('tr')).html()
      field_name = $this.data('field')
      updated_val = Houston._convert_to_correct_type(field_name, updated_val,
        get_current_collection())
      update_dict = {}
      update_dict[field_name] = updated_val
      Houston._call("#{Houston._session('collection_name')}_update",
        id, $set: update_dict)

  'keyup .houston-column-filter': (e) ->
    field_selectors = {}
    $('.houston-column-filter').each (idx, item) ->
      if item.value
        field_selectors[item.name] = item.value
    Houston._session 'field_selectors', field_selectors
    resubscribe()

  'click #houston-create-btn': ->
    $('#houston-create-document').removeClass('hidden')
    $('#houston-create-btn').hide()

  'click .houston-delete-doc': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    if confirm("Are you sure you want to delete the document with _id #{id}?")
      Houston._call("#{Houston._session('collection_name')}_delete", id)
  'click #houston-cancel': ->
    $('#houston-create-document').addClass('hidden')
    $('#houston-create-btn').show()
    $create_row = $('#houston-create-row')

    for field in $create_row.find('input')
      field.value = ''

  'click #houston-add': (e) ->
    # TODO fix and make sure it works
    e.preventDefault()
    $create_row = $('#houston-create-row')
    new_doc = {}

    for field in $create_row.find('input')
      # Unflatten the field names (e.g. foods.app -> {foods: {app:}})
      keys = field.name.split('.')
      final_key = keys.pop()

      value = Houston._convert_to_correct_type(field.name, field.value,
        get_current_collection())
      doc_iter = new_doc
      for key in keys
        doc_iter[key] = {} unless doc_iter[key]
        doc_iter = doc_iter[key]

      doc_iter[final_key] = value

      field.value = ''
    Houston._call("#{Houston._session('collection_name')}_insert", new_doc)

  'submit .houston-filter-form': (e) ->
    e.preventDefault()

Template._houston_new_document_field.helpers
  has_type: ->
    @type is 'string' ||
      @type is 'number' ||
      @type is 'checkbox'
  input_type: ->
    schemaToInputType @type