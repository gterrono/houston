root = exports ? this

root.Houston ?= {}

Houston._collections ?= {}

Houston._collections.collections = new Meteor.Collection('houston_collections')

Houston._admins = new Meteor.Collection('houston_admins')

Houston._user_is_admin = (id) ->
  return id? and Houston._admins.findOne user_id: id
