Template.db_view.helpers
  collections: -> Session.get('collections')
  num_of_records: -> Collections.findOne(name: @name).count

Template.db_view.rendered = ->
  Session.set('top_selector', {})
  Session.set('field_selectors', {})
  $(window).unbind('scroll')
