wait = (fn, ms=500) -> casper.wait ms, fn

test = (name, num_tests, url, fn, wait_time=500) ->
  casper.test.begin name, num_tests, (test) ->
    casper.start url, (response) ->
      fn.bind(@)
      wait fn, wait_time
    casper.run ->
      test.done()

test 'User sign up works w/ custom route', 3, 'http://localhost:3500/bob', ->
  @test.assertUrlMatch /\/bob\/login/, 'redirected to login'
  @test.assertExists 'input[value="Sign up"]', 'sign up form exists'
  @fill '#houston-sign-in-form'
    'houston-email': 'ad@min.com'
    'houston-password': 'admin'
    true
  wait ->
    @test.assertEval (->
      Meteor.user().emails[0].address == 'ad@min.com'),
      'admin logged in successfully'
