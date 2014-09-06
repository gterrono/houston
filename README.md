Houston 
===============
Houston is a zero-config Meteor Admin, modeled after [Django Admin](https://docs.djangoproject.com/en/dev/ref/contrib/admin/), intended as a simple way for developers to give end-users (or themselves) an easy way to view and manipulate their app's data.

#### [Video presentation](https://www.youtube.com/watch?v=vXeWxbJQr5o)

Houston is available through the [Atmosphere](https://atmospherejs.com/package/houston) package manager.

Play around with the demo [here](http://houston-test.meteor.com/admin). The email is `ad@min.com`, and the password is `admin`.

### Getting Started

```
meteor add houston:admin
```


Once installed, navigate to `/admin` to set up your admin account. You can either create a new user to act as Houston's Admin, or upgrade an existing user into an admin.

#### Auto-discovery
Houston will auto-discover your collections by exploring the top-level (root) namespace on the server for collections.  If your collections are not on the global namespace, see [Customizing Houston](#customizing-houston)

Features
========

#### /admin: Get a list of available collections
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
By default, Houston is hosted on `/admin`, but you're welcome to change this using `Meteor.settings` [(see the docs)](http://docs.meteor.com/#meteor_settings).

Don't want to read the settings docs? Here's your TL;DR:

####Setup
Add a settings.json file to your project. Something like:
```bash
echo {\"public\": {\"houston_root_route\": \"/your_fancy_route\"}} > settings.json
```

####Run locally
`mrt --settings=settings.json`

####Run on meteor.com hosting
`meteor deploy <site> --settings settings.json`

### Defining Custom Menu Items
![Custom Menu](https://raw.github.com/gterrono/houston/master/doc/menu.png)

Often, when delivering an admin interface for an end user, you may want to have
more functionality than simply editing the models.
Houston provides for adding custom functionality in two ways: (1) Templates,
which live in their own section of the Houston UI, or (2) Links,
which are easily available from the Houston interface and point to wherever you
need them to. You can add several object arguments to menu and it will process
them as single menu items.

#### Template
```javascript
Houston.menu({
  'type': 'template',
  'use': 'my_analytics_template',
  'title': 'Analytics'
}, {...}, {...});
```

#### Link
```javascript
Houston.menu({
  'type': 'link',
  'use': 'http://google.com',
  'title': 'Google',
  'target': 'blank'
});
```

Running Tests
-----
Requires Casper.js
run with ./run-tests.sh

Dependencies
-----

* **Router**: As of v1.0, Houston is compatible with both IronRouter and Router-less solutions that don't conflict with IronRouter. [Let us know](https://github.com/gterrono/houston/issues/new) if that's not true for you.
* **Accounts**: Houston piggybacks on top of Meteor Accounts.
* **CSS**: Houston uses Bootstrap, but makes an effort to avoid having its CSS interfere with yours.
* **Meteor**: Houston 1.0 was tested with Meteor 0.6.6.3, but there's no (strict) reasons that older versions shouldn't work.

###Current State
We've put a fair bit of work into the 1.0 release and will be actively supporting it. Please send in feature requests, bug reports, and contribute.


Wishlist
-------
- Test coverage (first priority, probably before adding any additional features)
- Custom admin roles: let package users write their own allow/deny scripts for admin types
- Allow package user to add custom CSS or functionality buttons per collection / per view
- Full support for Arrays / all sorts of complicated nested documents
- Log of all actions done on Houston and (though this is tough) ability to roll back actions.
- Get arbitrary mongo filters to work again.
- Proper Meteor/IronRouter support for mounting Houston to /admin (to replace the current CSS/router hackery).

History
-------
Houston was originally created during the [Summer 2013 Meteor Hackathon](http://www.meteor.com/blog/2013/07/09/congratulations-to-the-meteor-summer-hackathon-2013-teams) by [@gterrono](https://github.com/gterrono), [@alexeymk](https://twitter.com/alexeymk), [@yefim](https://twitter.com/yefim) and [@ceasar_bautista](https://twitter.com/ceasar_bautista).
