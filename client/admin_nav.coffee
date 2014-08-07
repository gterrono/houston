# Top Nav
Template._houston_navbar.events
  'click #houston-logout': (e) ->
    e.preventDefault()
    Meteor.logout()

Template._houston_navbar.helpers
  'bugreport_url': ->
    message = encodeURIComponent """
To make sure we can help you quickly, please include the version of Houston
you are using, steps to replicate the issue, a description of what you were
expecting and a screenshot if relevant.

Thanks!
"""
    "https://github.com/gterrono/houston/issues/new?body=#{message}"
  'menu_items': ->
    return Houston.menu._get_menu_items()
  'isActive' : -> 'active' if Router.current()?.path == @path

# Side Nav
Template._houston_sidenav.helpers
  collections: ->
    unless Houston._session 'collections'
      Houston._session 'collections', Houston._collections.collections.find().fetch()
    Houston._session 'collections'
  is_active: (name) ->
    name is Houston._session('collection_name')
