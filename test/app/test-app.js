globalCollection = new Meteor.Collection("GlobalCollection");

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
  Meteor.startup(function () {
    // Local variable so it needs to be added to Houston manually
    var hiddenCollection = new Meteor.Collection("HiddenCollection");

    globalCollection.remove({});
    Meteor.users.remove({});
    Houston._admins.remove({});
    hiddenCollection.remove({});

    Houston.add_collection(hiddenCollection);

    // code to run on server at startup
    if (!globalCollection.findOne()) {
      hiddenCollection.insert({str: "hidden test"});
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
