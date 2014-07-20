# TODO make it server side so filtering can scale
filterCollections = (query) ->
  collections = Houston._session('collections')
  if query
    _.filter(collections, (c) ->
      (c.name).indexOf(query) > -1
    )
  else
    collections


Template._houston_db_view.helpers
  collections: ->
    Houston._session('collections')
  filtered_collections: ->
    filterCollections Houston._session('search')
  num_of_records: ->
    Houston._collections.collections.findOne({name: @name}).count

Template._houston_db_view.events
# trigger meteor session invalidation, definitely a hack
  "click #refresh": ->
    window.location.reload()
  'keyup .houston-column-filter': (e) ->
    Houston._session 'search', $("#search").val()

Template._houston_db_view.rendered = ->
  $("#search").val("")
  Houston._session('collection_name', '')
  Houston._session('field_selectors', {})
  $(window).unbind('scroll')
