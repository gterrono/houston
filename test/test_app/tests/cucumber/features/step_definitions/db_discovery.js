module.exports = function () {
  this.Given(/^I am an admin$/, function (callback) {

    // First: reset accounts
    this.server.call('test/reset');

    // Second: create an account
    var id = this.server.call('test/createUser', "bob", "password");

    // Third: give user admin status
    this.server.call('_houston_make_admin', id)

    // Fourth: login
    client.execute(function() {
      Meteor.loginWithPassword('bob', 'password')
    })

    // Fifth: check to make sure the account is an admin?
    callback.pending()
  });

  this.Given(/^I have more than one collection$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^I should have access to my collections$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Given(/^I am a developer$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Given(/^some of my collections were not discovered$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.When(/^I add an empty collection$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^the admin should have access to my the collection I just added$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^I should not see users or houston_admin$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.When(/^I add users and houston_admin$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });

  this.Then(/^the admin should have access to those collections$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    callback.pending();
  });
}
