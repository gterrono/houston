// 'use strict';
// // You can include npm dependencies for support files in tests/cucumber/package.json
// var _ = require('underscore');
// // You can use normal require here, cucumber is NOT run in a Meteor context (by design)
// var url = require('url');

module.exports = function () {
  this.Given(/^I am an admin$/, function (callback) {
    this.server.call('test/reset').then(function(){
      console.log("this was a promise?");
    })
    // // First: reset accounts
    // this.server.call("test/reset").then(function(res) {
    //   console.log(res);
    //   // Second: create an account
    //   this.server.call("test/createUser").then(function(res){
    //     console.log(res);
    //     // Third: login
    //     this.server.call("test/loginWithPassword").then(function(res){
    //       console.log("logged in with password");
    //     })
    //   })
    // })


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
