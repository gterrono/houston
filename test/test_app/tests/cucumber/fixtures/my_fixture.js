(function () {

  'use strict';

  Meteor.methods({
    'test/reset' : function() {
      console.log("resetting");
      return Meteor.users.remove({})

    },
    'test/createUser': function(username, password) {
      console.log("creating");
      return Accounts.createUser({
        username: username,
        password: password
      })
    }
  });

})();

//
// Houston._user_is_admin = (id) ->
//   return id? and Houston._admins.findOne user_id: id
