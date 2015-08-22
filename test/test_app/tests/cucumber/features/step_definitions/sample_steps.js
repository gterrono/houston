'use strict';

// You can include npm dependencies for support files in tests/cucumber/package.json
var _ = require('underscore');
// You can use normal require here, cucumber is NOT run in a Meteor context (by design)
var url = require('url');

module.exports = function () {

  this.Given(/^I am a new user$/, function () {
    server.call('reset'); // this.ddp is a connection to the mirror
  });

  this.When(/^I navigate to "([^"]*)"$/, function (relativePath) {
    // client is a pre-configured WebdriverIO + PhantomJS instance
    // process.env.ROOT_URL always points to the mirror
    client.url(url.resolve(process.env.ROOT_URL, relativePath));
  });

  this.Then(/^I should see the title "([^"]*)"$/, function (expectedTitle) {
    // you can use chai in step definitions also
    client.waitForExist('title');
    expect(client.getTitle()).to.equal(expectedTitle);
  });

};
