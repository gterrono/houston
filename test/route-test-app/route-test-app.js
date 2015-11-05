Posts = new Meteor.Collection("posts");
globalCollection = new Meteor.Collection("GlobalCollection");

if (Meteor.isClient) {
  // counter starts at 0
  Session.setDefault('counter', 0);

//  Router.route('/routeme', function () {
//      this.render('hello');
//  });

  FlowRouter.route('/routeme/:stuff', {
    action: function(params, queryParams) {
      console.log("Yeah! We are on the post:", params.stuff);
      BlazeLayout.render('mainLayout', {content: 'hello'});
    }
  });

  Template.hello.helpers({
    counter: function () {
      return Session.get('counter');
    }
  });

  Template.hello.events({
    'click button': function () {
      // increment the counter when button is clicked
      Session.set('counter', Session.get('counter') + 1);
    }
  });
}

if (Meteor.isServer) {
  Meteor.methods({
    "test/clear_users": function() {
      Meteor.users.remove({});
      Houston._admins.remove({});
    }
  });

  Meteor.startup(function () {
    // Local variable so it needs to be added to Houston manually
    // var hiddenCollection = new Meteor.Collection("HiddenCollection");

    globalCollection.remove({});
    Meteor.users.remove({});
    Houston._admins.remove({});
    //Houston._collections.collections.remove({});
    // hiddenCollection.remove({});
    Posts.remove({});
    Houston.methods(Posts, {
      "Publish": function (post) {
        Posts.update(post._id, {$set: {published: true}});
        return post.title + " has been published.";
      }
    });


    //Houston.add_collection(hiddenCollection);

    Posts.insert({title:"First Post", author: "Rocketman", body: "So excited"});
    Posts.insert({title:"Welcome to Houston", author: "Rocketman", body: "Great to be here"});
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
