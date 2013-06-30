Meteor.publish 'adminUser', ->
  Meteor.users.find({'profile.admin': true}, fields: 'profile.admin': true)
