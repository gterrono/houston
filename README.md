Houston
===============
Houston (formerly Z-Mongo-Admin) is a zero-config Meteor Admin, modeled after [Django Admin](https://docs.djangoproject.com/en/dev/ref/contrib/admin/).  

Houston is available on [meteorite](https://atmosphere.meteor.com/package/houston)

TODO screenshot

Install
----------
```
mrt add houston
```

Once installed, navigate to `/admin` to set up your admin account. You can either create a new user to act as Houston Admin, or upgarde an existing user into an admin by going to /admin with a logged in user.  

Dependencies
-----

* **Router**: As of v1.0, Houston is compatible with both IronRouter and Router-less solutions that don't conflict with IronRouter. [Let us know](https://github.com/gterrono/houston/issues/new)
* **Accounts**: Houston piggybacks on top of Meteor Accounts.  
* * **CSS**: Houston uses Bootstrap, but makes an effort to avoid having its CSS interfere with yours.

Demo
------------
* [Dinners](http://interndinners.meteor.com/dinners)
* [Dinners Admin](http://interndinners.meteor.com/admin)
