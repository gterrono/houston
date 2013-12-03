Template._houston_db_view.helpers
  collections: -> Houston._session('collections')
  num_of_records: -> Houston._collections.collections.findOne({name: @name}).count

Template._houston_db_view.events
  # trigger meteor session invalidation, definitely a hack
  "click #refresh": -> window.location.reload()

Template._houston_db_view.rendered = ->
  Houston._session('field_selectors', {})
  $(window).unbind('scroll')
