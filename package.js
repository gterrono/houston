Package.describe({
  summary: "Mongo Admin for Meteor"
});

Package.on_use(function(api) {
  api.use("coffeescript", ['client', 'server']);

  api.add_files(['client/router.coffee', 'client/admin_login.coffee', 'client/collection_view.coffee', 'client/document_view.coffee'], 'client');
  
  api.add_files(['client/style.css', 'client/main.html', 'client/admin_login.html', 'client/db_view.html', 'client/collection_view.html', 'client/document_view.html'], 'client');

  api.add_files('lib/collections.coffee', ['client', 'server']);
  
  api.add_files('server/publications.coffee', 'server');
});
