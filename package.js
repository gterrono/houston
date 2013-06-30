Package.describe({
  summary: "Mongo Admin for Meteor"
});

Package.on_use(function(api) {
  api.use("coffeescript", ['client', 'server']);
  api.use('accounts-base', ['client', 'server']);
  api.use('accounts-password', ['client', 'server']);
  api.use(['templating'], 'client');

  // load html first, https://github.com/meteor/meteor/issues/282
  api.add_files('client/main.html', 'client');

  api.add_files(['client/style.css', 'client/admin_login.html', 'client/db_view.html', 'client/collection_view.html', 'client/document_view.html', 'client/admin_navbar.html'], 'client');

  api.add_files(['client/router.coffee', 'client/admin_login.coffee', 'client/collection_view.coffee', 'client/document_view.coffee'], 'client');
  

  api.add_files('lib/collections.coffee', ['client', 'server']);
  
  api.add_files('server/publications.coffee', 'server');
});
