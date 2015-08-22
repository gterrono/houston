(function () {

  'use strict';

  Meteor.methods({
    'test/reset' : function() {
        return Meteor.users.remove({})


    },
    'test/createUser': function() {
      return Accounts.createUser({
        username: "bob",
        password: "password"
      })
    },
    'test/loginWithPassword': function() {
      return Meteor.loginWithPassword('bob', 'password')
    }
  });

})();
