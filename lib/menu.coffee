root = exports ? this

root.Houston ?= {}

Houston.menu = () ->
  @.menu._add_menu_item item for item in arguments
  return

Houston.menu.dependency = new Deps.Dependency

Houston.menu._menu_items = []

Houston.menu._process_item = (item) ->
  if item.type isnt 'link' and item.type isnt 'template'
    throw new Meteor.Error 400, 'Can\'t recognize type: ' + item

  if item.type is 'link'
    item.path = item.use
  else if item.type is 'template'
    item.path = "/admin/#{item.use}"

  return item

Houston.menu._get_menu_items = ->
  @dependency.depend()
  @_process_item item for item in @_menu_items

Houston.menu._add_menu_item = (item) ->
  @_menu_items.push item
  @dependency.changed()
