Furniture = new Meteor.Collection("furniture")
# TODO generic

Meteor.startup( ->
  Furniture.insert
    name: 'table'
    cost: 45
)
# TODO check if admin
Meteor.publish 'admin_furniture', -> Furniture.find({}, {})
