Houston
===============
Houston is a zero-config Meteor Admin, modeled after [Django Admin](https://docs.djangoproject.com/en/dev/ref/contrib/admin/), intended as a simple way for developers to give end-users (or themselves) an easy way to view and manipulate their app's data.  [Watch a video demo from Meteor Devshop](https://www.youtube.com/watch?v=vXeWxbJQr5o) or read below for more.

##### Latest News
Houston is no longer being maintained. Interested in the story behind Houston? Check out [Confessions of a Deadbeat Open Source Maintainer](http://alexeymk.com/2017/05/06/confessions-of-a-deadbeat-open-source-maintainer.html).

### Getting Started

```
meteor add houston:admin
```

Once installed, navigate to `/admin` to set up your admin account. You can either create a new user to act as Houston's Admin, or upgrade an existing user into an admin.

Features
========

#### Auto-discovery
Houston will auto-discover your collections by exploring the top-level (root) namespace on the server for collections.  If your collections are not on the global namespace, see [Customizing Houston](#customizing-houston)

#### /admin: See available collections
![Home View](https://raw.github.com/gterrono/houston/master/doc/home.png)

#### /admin/collection: View all items in collection
![Collection View](https://raw.github.com/gterrono/houston/master/doc/collection.png)

Collection view includes support for
- deleting and creating documents
- inline editing (double-click on a cell)
- filtering and sorting by names
- support for nested objects
- (limited, mostly read-only) support for arrays

#### /admin/collection/document_id: Edit a particular document
![Document View](https://raw.github.com/gterrono/houston/master/doc/document.png)

#### /admin/login: User-defined Admin based on Meteor Accounts
![Login](https://raw.github.com/gterrono/houston/master/doc/login.png)

#### Custom actions
![Custom Actions](https://raw.github.com/gterrono/houston/master/doc/custom-actions.png)

Declare custom actions for specific collections using a `Meteor.methods`-like syntax.

##### On the server
```javascript
Houston.methods("Posts", {
  "Publish": function (post) {
    Posts.update(post._id, {$set: {published: true}});
    return post.name + " published successfully.";
  }
});

```
Call `Houston.methods` for every collection you want to add custom actions for. The first argument is the collection name (or the `Mongo.Collection` itself), and the second argument is a `{method_name: function}` dictionary, as in `Meteor.methods`.

Each `Houston.methods` method should `return` a string, which will be display to the user as the success message. If you `throw` an exception, the `exception.message` will be shown to the user (`Internal Server Error` by default).

The actions will be visible as buttons in both the collection and document view.

#### Custom Menu Items
![Custom Menu](https://raw.github.com/gterrono/houston/master/doc/menu.png)

Often, when delivering an admin interface for an end user, you may want to have
more functionality than simply editing the models.
Houston provides for adding custom functionality in two ways: (1) Templates,
which live in their own section of the Houston UI, or (2) Links,
which are easily available from the Houston interface and point to wherever you
need them to. You can add several object arguments to menu and it will process
them as single menu items.

##### Template
```javascript
Houston.menu({
  'type': 'template',
  'use': 'my_analytics_template',
  'title': 'Analytics'
}, {...}, {...});
```

##### Link
```javascript
Houston.menu({
  'type': 'link',
  'use': 'http://google.com',
  'title': 'Google',
  'target': 'blank'
});
```

Customizing Houston
========

### Adding undiscovered collections to Houston
If Houston didn't find your collection automatically, you can always add it manually on the server via
```javascript
Houston.add_collection(collection);
```

The users collection is hidden by default. If you want to access your users in Houston and/or be able to add houston admins just:
```javascript
Houston.add_collection(Meteor.users);
Houston.add_collection(Houston._admins);
```

You can also `Houston.hide_collection(collection)`, though this is not as well-tested.

### Changing the root path of Houston from `/admin`
By default, Houston is hosted on `/admin`, but you're welcome to change this by setting `public.houston_root_route` in `Meteor.settings` [(see the docs)](http://docs.meteor.com/#meteor_settings).

### Configuring items per page in collection view
By default, Houston displays 20 items per page (infinite scroll is currently buggy - pull requests most welcome).

If you need to see more items per page and filters don't do the trick, set "public.houston_documents_per_page" in your `Meteor.settings.`

### TL;DR How do use Meteor Settings
#### Setting up
Add a settings.json file to your project. Something like:
```bash
echo {\"public\": {\"houston_root_route\": \"/your_fancy_route\", \"houston_documents_per_page\": 9001}} > settings.json
```

#### Run locally
`meteor --settings=settings.json`

#### Run on meteor.com hosting
`meteor deploy <site> --settings settings.json`

Running Tests
-----
Tests are currently based on a test app and Velocity.
run with ./run-tests.sh

Test coverage is currently rather meager. Pull requests & contributors welcome. Be the hero you always knew you could be.

Dependencies
-----

* **Router**: As of v1.0, Houston is compatible with both IronRouter and Router-less solutions that don't conflict with IronRouter. [Let us know](https://github.com/gterrono/houston/issues/new) if that's not true for you.
* **Accounts**: Houston piggybacks on top of Meteor Accounts.
* **CSS**: Houston uses Bootstrap, but makes an effort to avoid having its CSS interfere with yours.
* **Meteor**: As of Houston 1.2.0, Houston requires Meteor 1.0 or newer.

###Current State
The 1.3 release should fully support Meteor 1.0. We intend to support it. Please send in feature requests, bug reports, and contribute.

Wishlist
-------
- Test coverage (first priority, probably before adding any additional features)
- Custom admin roles: let package users write their own allow/deny scripts for admin types
- Allow package user to add custom CSS per collection / per view
- Full support for Arrays / all sorts of complicated nested documents
- Log of all actions done on Houston and (though this is tough) ability to roll back actions.
- Get arbitrary mongo filters to work.
- Proper Meteor/IronRouter support for mounting Houston to /admin (to replace the current CSS/router hackery).

History
-------
Houston was originally created during the [Summer 2013 Meteor Hackathon](http://www.meteor.com/blog/2013/07/09/congratulations-to-the-meteor-summer-hackathon-2013-teams) by [@gterrono](https://github.com/gterrono), [@alexeymk](https://twitter.com/alexeymk), [@yefim](https://twitter.com/yefim) and [@ceasar_bautista](https://twitter.com/ceasar_bautista).
