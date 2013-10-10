Template.db_view.helpers
  collections: -> Session.get('collections')

Template.db_view.rendered = ->
  Session.set('top_selector', {})
  Session.set('field_selectors', {})
