if Meteor.isServer
  this.TestCollection = new Meteor.Collection('test_collection')
  unless TestCollection.findOne()
    TestCollection.insert({hey:'hi'})
  Meteor.methods
    wipe_users: ->
      for user in Meteor.users.find().fetch()
        Meteor.users.remove user
      if Houston._admins.findOne()
        Houston._admins.remove Houston._admins.findOne()._id
    print_users: ->
      console.log Meteor.users.find().fetch()
      console.log Houston._admins.find().fetch()
    print_collections: ->
      console.log Houston._collections.collections.find().fetch()

if Meteor.isClient
  testAsyncMulti('Houston - Admin creation is functional', [
    (test, expect) ->
      Meteor.call 'wipe_users', expect (error) ->
        test.equal error, undefined
    ,
    (test, expect) ->
      # Taken from Meteors account-password tests
      this.username = Random.id()
      this.email = Random.id() + '-intercept@example.com'
      this.password = 'password'

      Accounts.createUser(
        {username: this.username, email: this.email, password: this.password}, expect (error) ->
          Houston._subscribe 'admin_user'
          test.equal error, undefined)
    ,
    (test, expect) ->
      test.isFalse Houston._user_is_admin Meteor.userId()
      Meteor.call '_houston_make_admin', Meteor.userId(), expect (error) ->
        test.equal error, undefined
    ,
    (test, expect) ->
      test.isTrue Houston._user_is_admin Meteor.userId()
  ])

  testAsyncMulti('Houston - Normal collection is seen by Houston', [
    (test, expect) ->
      test.isTrue Houston._user_is_admin Meteor.userId()
      Houston._subscribe 'collections', expect ->
        collections = Houston._collections.collections.find().fetch()
        test.equal collections.length, 1
        col = _.omit collections[0], '_id'
        test.equal col, {"name":"test_collection","count":1,"fields":["_id","hey"]}
  ])
