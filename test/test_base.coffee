wait = (fn, ms=500) -> casper.wait ms, fn
PORT = 3500

test = (name, num_tests, path, fn, wait_time=500) ->
  url = "http://localhost:#{PORT}#{path}"
  casper.test.begin name, num_tests, (test) ->
    casper.start url, (response) ->
      fn.bind(@)
      wait fn, wait_time
    casper.run ->
      test.done()

test 'User can sign up', 3, '/admin', ->
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

test 'User can log out', 1, '/admin/login', ->
  @click 'a.houston-logout'
  wait ->
    @test.assertEval (-> !Meteor.user()?), 'admin logged out successfully'

test 'User can log in', 3, '/admin', ->
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

test 'DB view', 2, '/admin', (->
  @test.assertSelectorHasText 'td[record-name="HiddenCollection"].num-records', '1'
  @test.assertSelectorHasText 'td[record-name="GlobalCollection"].num-records', '1000'),
  1000
