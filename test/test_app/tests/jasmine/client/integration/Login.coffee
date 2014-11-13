eventually = (condition, cb) ->
  poll = setInterval(->
    if condition()
      clearInterval poll
      cb()
  , 200)

setup = ({logged_in, as_admin, other_admin}, cb) ->
  run_actual_test = cb
  Meteor.call "test/clear_users", (err) ->
    expect(err).toBeUndefined()
    _setup_user = ->
      if logged_in
        Accounts.createUser email: "you@example.com", password: "bob", ->
          if as_admin
            Houston._call 'make_admin', Meteor.userId(), (err) ->
              expect(err).toBeUndefined()
              run_actual_test()
          else
            run_actual_test()
      else
        run_actual_test()

    if other_admin
      Accounts.createUser email: "other@example.com", password: "bob", ->
        Houston._call 'make_admin', Meteor.userId(), (err) ->
          expect(err).toBeUndefined()
          Meteor.logout (err) ->
            expect(err).toBeUndefined()
            _setup_user()
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

  it "tells you to go away if an admin exists",
    (done) ->
      setup {logged_in: true, as_admin: false, other_admin: true}, ->
        Houston._go "home"
        url_changed = -> window.location.pathname is "/admin/login"
        eventually url_changed, ->
          expect($('#become-houston-admin').length).toEqual(0)
          expect($('.form-heading').first().html()).toMatch(/You are not an Admin./)
          done()
