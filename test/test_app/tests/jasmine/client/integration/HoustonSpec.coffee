eventually = (condition, cb) ->
  poll = setInterval(->
    if condition()
      clearInterval poll
      cb()
  , 200)

setup = ({logged_in, as_admin, other_admin}, cb) ->
  run_actual_test = cb
  Meteor.call "test/clear_users", ->
    _setup_user = ->
      if logged_in
        userId = Accounts.createUser email: "you@example.com", password: "bob", ->
          if as_admin
            Houston._call 'make_admin', userId, ->
              run_actual_test()
          else
            run_actual_test()
      else
        run_actual_test()

    if other_admin
      Accounts.createUser email: "other@example.com", password: "bob", ->
        Meteor.logout -> _setup_user()
    else
      _setup_user()

describe "Can't access Meteor unless logged in", ->
  it "should send to login page",
    (done) ->
      setup {logged_in: false, as_admin: false, other_admin: false}, ->
        Houston._go "home"
        url_changed = -> window.location.pathname is "/admin/login"
        eventually url_changed, ->
          $signin_form = $('#houston-sign-in-form')
          expect($signin_form[0]).not.toBeUndefined()
          expect($signin_form.html()).toMatch(/Create an admin account/)
          done()

  it "should offer to Claim Admin if logged in",
    (done) ->
      setup {logged_in: true, as_admin: false, other_admin: false}, ->
        Houston._go "home"
        url_changed = -> window.location.pathname is "/admin/login"
        eventually url_changed, ->
          expect($('#become-houston-admin')[0]).not.toBeUndefined()
          done()
