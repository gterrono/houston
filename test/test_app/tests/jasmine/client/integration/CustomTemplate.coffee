eventually = (condition, cb) ->
  poll = setInterval(->
    if condition()
      clearInterval poll
      cb()
  , 200)

setup = (run_actual_test) ->
  Meteor.call "test/clear_users", (err) ->
    expect(err).toBeUndefined()
    Accounts.createUser email: "you@example.com", password: "bob", ->
      console.log("created user: ", Meteor.userId())
      Houston._call 'make_admin', Meteor.userId(), (err) ->
        expect(err).toBeUndefined()
        run_actual_test()

describe "Custom Template", ->
  it "should display a a menu link", ->
    setup ->
      Houston._go "home"
      $menu_link = $('a:contains("MyTmplMenuText")')
      expect($menu_link.length).toEqual(1)
      expect($menu_link.attr('href')).toEqual("/admin/custom/MyTmpl")

  it "should display content of the template", ->
    setup ->
      Houston._go "custom_template", {template: "MyTmpl"}
      expect(window.location.pathname).toEqual("/admin/custom/MyTmpl")
      $p = $('p.MyTmplClass')
      expect($p.length).toEqual(1)
