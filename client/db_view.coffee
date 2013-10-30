Template.db_view.helpers
  collections: -> Session.get('collections')
  num_of_records: -> look_up_collection(@name).find().count()

Template.db_view.rendered = ->
  Session.set('top_selector', {})
  Session.set('field_selectors', {})
