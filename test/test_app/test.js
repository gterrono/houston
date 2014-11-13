globalCollection = new Meteor.Collection("GlobalCollection");

/*// collection2 schema
var Schemas = {};
Schemas.Book = new SimpleSchema({
    title: {
        type: String,
        max: 200
    },
    author: {
        type: String,
    },
    copies: {
        type: Number,
        min: 0
    },
    lastCheckedOut: {
        type: Date
    }
});
*/

Books = new Meteor.Collection("books");

//Books.attachSchema(Schemas.Book);


if (Meteor.isClient) {
  Template.hello.greeting = function () {
    return "Welcome to clean-install.";
  };

  Template.hello.events({
    'click input' : function () {
      // template data, if any, is available in 'this'
      if (typeof console !== 'undefined')
        console.log("You pressed the button");
    }
  });
}

if (Meteor.isServer) {
  Meteor.methods({
    "test/clear_users": function() {
      Meteor.users.remove({});
    }
  });
  Meteor.startup(function () {
    // Local variable so it needs to be added to Houston manually
    // var hiddenCollection = new Meteor.Collection("HiddenCollection");

    globalCollection.remove({});
    Meteor.users.remove({});
    Houston._admins.remove({});
    Houston._collections.collections.remove({});
    // hiddenCollection.remove({});
    Books.remove({});

    //Houston.add_collection(hiddenCollection);

    Books.insert({title:"Title", author: "Author", copies: 5, lastCheckedOut: new Date()});
    // code to run on server at startup
    if (!globalCollection.findOne()) {
      //hiddenCollection.insert({str: "hidden test", bool: true});
      _.range(1000).forEach(function(number) {
        globalCollection.insert({
          str: "test" + number,
          number: number
        });
      });
      console.log("loading done");
    }
  });
}
