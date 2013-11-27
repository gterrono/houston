Template._houston_db_view.helpers
  collections: -> Session.get('_houston_collections')
  num_of_records: -> Houston._collections.findOne({name: @name}).count


Template._houston_db_view.rendered = ->
  Session.set('_houston_top_selector', {})
  Session.set('_houston_field_selectors', {})
  $(window).unbind('scroll')
