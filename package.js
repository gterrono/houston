Package.describe({
  summary: "Mongo Admin for Meteor"
});

Package.on_use(function(api) {
  api.use('coffeescript', ['client', 'server']);
  api.use('accounts-base', ['client', 'server']);
  api.use('accounts-password', ['client', 'server']);

  api.use(['templating', 'router', 'spin', 'handlebars', 'paginated-subscription'], 'client');

  // adding our custom version of bootstrap, to ensure no-conflict with
  // whichever CSS framework the client app uses.
  api.add_files(['client/style.css', 'client/bootstrap.css'], 'client')

  // load html first, https://github.com/meteor/meteor/issues/282
  api.add_files([
    'client/admin_login.html', 'client/db_view.html',
    'client/collection_view.html', 'client/document_view.html',
    'client/admin_navbar.html', 'client/main.html'],
  'client');

  api.add_files([
    'client/router.coffee', 'client/admin_login.coffee',
    'client/collection_view.coffee', 'client/document_view.coffee',
    'client/lib/jquery.autosize.js', 'client/zma_helpers.coffee',
    'client/admin_navbar.coffee', 'client/db_view.coffee'],
  'client');

  api.add_files(['lib/collections.coffee', 'lib/shared.coffee'], ['client', 'server']);

  api.add_files('server/publications.coffee', 'server');
});
