// 'use strict';
// // You can include npm dependencies for support files in tests/cucumber/package.json
// var _ = require('underscore');
// // You can use normal require here, cucumber is NOT run in a Meteor context (by design)
// var url = require('url');

/*
NOTE: this.server.call runs synchronously.
If you want it to run async, you must use
this.server.callAsync
*/

module.exports = function () {
  this.Given(/^I am an admin$/, function (callback) {
    // First: reset accounts
    this.server.call('test/reset');

    // Second: create an account
    var id = this.server.call('test/createUser', "bob", "password");

    // Third: add user to admin
    this.server.call('_houston_make_admin', id)

    // Third: login
    // this.client.call(Meteor.loginWithPassword('bob', 'password'))
    // this.client.execute(Meteor.loginWithPassword('bob', 'password'))
    client.execute(function() {
      // Meteor.loginWithPassword('bob', 'password')
      console.log(this);
    })

    // Fourth:
    // Check to make sure the account is an admin

  });

  this.Given(/^I am on the route "([^"]*)"$/, function (arg1, callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });


  this.Given(/^I have collections$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.When(/^I sign in$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^I should have access to my collections$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.When(/^I add an empty collection$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^I should have access to my the collection I just added$/, function (callback) {
  // Write code here that turns the phrase above into concrete actions
  callback.pending();
});
};
