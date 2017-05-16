# TODO make it server side so filtering can scale
filterCollections = (query, collections) ->
  if query
    _.filter(collections, (c) ->
      (c.name).indexOf(query) > -1
    )
  else
    collections


Template._houston_db_view.helpers
  collections: -> Houston._collections.collections
  filtered_collections: ->
    filterCollections(
      Houston._session('search'),
      Houston._collections.collections.find().fetch()
    )

Template._houston_db_view.events
  # trigger meteor session invalidation, definitely a hack
  "click #refresh": -> window.location.reload()
  'keyup .houston-column-filter': (e) ->
    Houston._session 'search', $("#search").val()

Template._houston_db_view.rendered = ->
  $("#search").val("")
  $(window).unbind('scroll')
