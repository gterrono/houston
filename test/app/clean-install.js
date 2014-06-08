stuff = new Meteor.Collection("stuff");

Meteor.users.remove(Meteor.users.findOne())
Houston._admins.remove(Houston._admins.findOne())

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
    var secret = new Meteor.Collection("shhh");
    Houston.add_collection(secret);

    // code to run on server at startup
    if (!stuff.findOne()) {
      secret.insert({"dont": "tell"});
      _.range(1000).forEach(function(item) {
        stuff.insert({
          name: "Jonah",
          age: item
        });
      });
      console.log("loading done");
    }
  });
}
