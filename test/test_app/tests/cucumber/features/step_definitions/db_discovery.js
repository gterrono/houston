// var url = require('url')

module.exports = function () {
  this.Given(/^I am an admin$/, function (callback) {
    // First: reset accounts
    this.server.call('test/reset');

    // Second: create an account
    var id = this.server.call('test/createUser', "bob@email.com", "password");

    // Third: give user admin status
    this.server.call('_houston_make_admin', id)

    // Fourth: login



    // client.url(process.env.ROOT_URL + 'admin');
    // client.waitForExist(selectors.emailField);
    // client.setValue(selectors.emailField, "bob@email.com");
    // client.setValue(selectors.passwordField, "password");
    // client.submitForm(selectors.signInForm);




    // client.url(process.env.ROOT_URL + 'admin');
    // this.client.executeAsync(function(done) {
    //   Meteor.loginWithPassword('bob', 'password', done)
    // })

    // callback()
  });

  this.Given(/^I have more than one collection$/, function (callback) {
    // Count the number of items in our global collection
    var collectionCount = this.server.call('test/findACollection')

    // Check to make sure it has at least 1 item
    expect(collectionCount).to.be.at.least(1);
  });

  this.Then(/^I should have access to my collections$/, function (callback) {
    // Collection names should be visible in the sidebar

    // The item count visible should be the same as the number of items in the collection

    // When the user clicks on the collection in the sidebar, he should see the documents in the table


    callback.pending();
  });

  this.Given(/^I am a developer$/, function (callback) {
    callback();
  });

  this.Given(/^some of my collections were not discovered$/, function (callback) {
    // Houston will not recognize empty collections.

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
