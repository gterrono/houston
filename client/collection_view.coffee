get_sort_by = ->
  sort_by = {}
  sort_by[Session.get('_houston_sort_key')] = Session.get('_houston_sort_order')
  return sort_by

get_filter_query = ->
  # Make find query using the filter stored in the session. The regexes are
  # escaped, but $regex is used so it can match anywhere in the string.
  query = {}
  fill_query_with_regex = (session_key) ->
    return unless Session.get(session_key)?
    for key, val of Session.get(session_key)
      # From http://stackoverflow.com/questions/3115150/how-to-escape-regular-expression-special-characters-using-javascript#answer-9310752
      query[key] = $regex: val.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
  fill_query_with_regex('_houston_top_selector')
  fill_query_with_regex('_houston_field_selectors')
  return query

resubscribe = ->
  # Stop the old subscription and resubscribe with the new filter/sort
  subscription_name = "_houston_#{Session.get('_houston_collection_name')}"
  Houston._paginated_subscription.stop()
  Houston._paginated_subscription =
    Meteor.subscribeWithPagination subscription_name,
      get_sort_by(), get_filter_query(),
      Houston._admin_page_length

collection_info = -> Houston._collections.findOne(name: Session.get('_houston_collection_name'))

collection_count = -> collection_info().count

Template._houston_collection_view.helpers
  headers: -> get_collection_view_fields()
  nonid_headers: -> get_collection_view_fields()[1..]
  collection_name: -> "#{Session.get('_houston_collection_name')}"
  document_url: -> "/houston/#{Session.get('_houston_collection_name')}/#{@_id}"
  document_id: -> @_id + ""
  num_of_records: ->
    collection_count() or "no"
  pluralize: -> 's' unless get_current_collection().find().count() == 1
  rows: ->
    get_current_collection()?.find(get_filter_query(), {sort: get_sort_by()}).fetch()
  values_in_order: ->
    fields_in_order = get_collection_view_fields()
    names_in_order = _.clone fields_in_order
    values = (Houston._lookup(@, field_name) for field_name in fields_in_order[1..])  # skip _id
    ({value, name} for [value, name] in _.zip values, names_in_order[1..])
  filter_value: ->
    if Session.get('_houston_top_selector') and Session.get('_houston_top_selector')[@name]
      Session.get('_houston_top_selector')[@name]
    else if Session.get('_houston_field_selectors') and Session.get('_houston_field_selectors')[@name]
      Session.get('_houston_field_selectors')[@name]
    else
      ''

Template._houston_collection_view.rendered = ->
  $win = $(window)
  $win.scroll ->
    if $win.scrollTop() + 300 > $(document).height() - $win.height() and
      Houston._paginated_subscription.limit() < collection_count()
        Houston._paginated_subscription.loadNextPage()

get_current_collection = -> Houston._get_collection(Session.get('_houston_collection_name'))
get_collection_view_fields = -> collection_info().fields or []

Template._houston_collection_view.events
  "click a.home": (e) ->
    Meteor.go("/houston/")

  "click a.sort": (e) ->
      e.preventDefault()
      if (Session.get('_houston_sort_key') == this.toString())
        Session.set('_houston_sort_order', Session.get('_houston_sort_order') * - 1)
      else
        Session.set('_houston_sort_key', this.toString())
        Session.set('_houston_sort_order', 1)
      resubscribe()

  'keyup #filter_selector': (event) ->
    return unless event.keyCode is 13  # enter
    try
      selector_json = JSON.parse($('#filter_selector').val())
      Session.set('_houston_top_selector', selector_json)
    catch error
      Session.set('_houston_top_selector', {})
    resubscribe()

  'dblclick .collection-field': (e) ->
    $this = $(e.currentTarget)
    $this.removeClass('collection-field')
    $this.html "<input type='text' value='#{$this.text()}'>"
    $this.find('input').select()
    $this.find('input').on 'blur', ->
      updated_val = $this.find('input').val()
      $this.html updated_val
      $this.addClass('collection-field')
      id = $('td:first-child a', $this.parents('tr')).html()
      field_name = $this.data('field')
      update_dict = {}
      update_dict[field_name] = updated_val
      Meteor.call("_houston_#{Session.get('_houston_collection_name')}_update",
        id, $set: update_dict)

  'keyup .column_filter': (e) ->
    field_selectors = {}
    $('.column_filter').each (idx, item) ->
      if item.value
        field_selectors[item.name] = item.value
    Session.set '_houston_field_selectors', field_selectors
    resubscribe()

  'click .admin-delete-doc': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    Meteor.call "_houston_#{Session.get('_houston_collection_name')}_delete", id

  'click .admin-create-doc': (e) ->
    e.preventDefault()
    $create_row = $('#admin-create-row')
    new_doc = {}
    for field in $create_row.find('input[type="text"]')
      # Unflatten the field names (e.g. foods.app -> {foods: {app:}})
      keys = field.name.split('.')
      final_key = keys.pop()

      doc_iter = new_doc
      for key in keys
        doc_iter[key] = {} unless doc_iter[key]
        doc_iter = doc_iter[key]

      doc_iter[final_key] = field.value

      field.value = ''
    Meteor.call "_houston_#{Session.get('_houston_collection_name')}_insert", new_doc

  'click #admin-load-more': (e) ->
    Houston._paginated_subscription.loadNextPage()

  'submit form': (e) ->
    e.preventDefault()
