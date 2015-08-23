(function () {

  'use strict';

  Meteor.methods({
    'test/reset' : function() {
      Houston._admins.remove({})
      return Meteor.users.remove({})

    },
    'test/createUser': function(email, password) {
      return Accounts.createUser({
        email: email,
        password: password
      })
    },
    'test/findACollection': function() {
      return Meteor.globalCollection.find().count()
    }
  });

})();
