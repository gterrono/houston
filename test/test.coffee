casper.test.begin 'User can sign up', 3, (test) ->
  casper.start 'http://localhost:3000/admin', (response) ->
    casper.wait 500, ->
      @test.assertUrlMatch /\/admin\/login/, 'redirected to login'
      @test.assertExists 'input[value="Sign up"]', 'sign up form exists'
      @fill '#houston-sign-in-form'
        'houston-email': 'ad@min.com'
        'houston-password': 'admin'
        true
      casper.wait 500, ->
        @test.assertEval (->
          Meteor.user().emails[0].address == 'ad@min.com'),
          'admin logged in successfully'
  casper.run ->
    test.done()

casper.test.begin 'User can log out', 1, (test) ->
  casper.start 'http://localhost:3000/admin/login', (response) ->
    casper.wait 500, ->
      @click 'a.houston-logout'
      casper.wait 500, ->
        @test.assertEval (-> !Meteor.user()?), 'admin logged out successfully'
  casper.run ->
    test.done()
