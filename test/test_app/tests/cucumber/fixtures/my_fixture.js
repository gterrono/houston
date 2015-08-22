(function () {

  'use strict';

  Meteor.methods({
    'test/reset' : function() {
      return Meteor.users.remove({})

    },
    'test/createUser': function(username, password) {
      return Accounts.createUser({
        username: username,
        password: password
      })
    }
  });

})();
