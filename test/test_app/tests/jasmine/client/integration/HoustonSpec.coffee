eventually = (cb, condition) ->
  poll = setInterval(->
    if condition()
      clearInterval poll
      cb()
  , 200)

describe "Can't access Meteor unless you are logged in in CS", ->
  it "should send you to the login page if you aren't logged in and try to access the admin",
  (done) ->
    Houston._go "home"
    eventually done, ->
      window.location.pathname is "/admin/login"
