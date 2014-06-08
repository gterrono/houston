wait = (fn, ms=500) -> casper.wait ms, fn

test = (name, num_tests, url, fn) ->
  casper.test.begin name, num_tests, (test) ->
    casper.start url, (response) ->
      fn.bind(@)
      wait fn
    casper.run ->
      test.done()

test 'User can sign up', 3, 'http://localhost:3000/admin', ->
  @test.assertUrlMatch /\/admin\/login/, 'redirected to login'
  @test.assertExists 'input[value="Sign up"]', 'sign up form exists'
  @fill '#houston-sign-in-form'
    'houston-email': 'ad@min.com'
    'houston-password': 'admin'
    true
  wait ->
    @test.assertEval (->
      Meteor.user().emails[0].address == 'ad@min.com'),
      'admin logged in successfully'

test 'User can log out', 1, 'http://localhost:3000/admin/login', ->
  @click 'a.houston-logout'
  wait ->
    @test.assertEval (-> !Meteor.user()?), 'admin logged out successfully'

test 'User can log in', 3, 'http://localhost:3000/admin', ->
  @test.assertUrlMatch /\/admin\/login/, 'redirected to login'
  @test.assertExists 'input[value="Sign in"]', 'sign in form exists'
  @fill '#houston-sign-in-form'
    'houston-email': 'ad@min.com'
    'houston-password': 'admin'
    true
  wait (->
    @test.assertEval (->
      Meteor.user().emails[0].address == 'ad@min.com'),
      'admin logged in successfully'),
    2000
