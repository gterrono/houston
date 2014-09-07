Package.describe({
  name: "houston:admin",
  summary: "A zero-config Meteor Admin",
  version: "1.1.0",
  git: "https://github.com/gterrono/houston.git"
});

Package.on_use(function(api) {
  api.versionsFrom('METEOR@0.9.0');

  //////////////////////////////////////////////////////////////////
  // Meteor-provided packages
  //////////////////////////////////////////////////////////////////
  api.use('deps@1.0.0', ['client', 'server']);
  api.use('coffeescript@1.0.0', ['client', 'server']);
  api.use('accounts-base@1.0.0', ['client', 'server']);  // ?optional
  api.use('accounts-password@1.0.0', ['client', 'server']);
  api.use('templating@1.0.0', 'client');  // ?optional

  api.use('check@1.0.0', 'client');
  api.use('spacebars@1.0.0', 'client');  // ?used to be handlebars - hopefully works cleanly

  //////////////////////////////////////////////////////////////////
  // Third-party package dependencies
  //////////////////////////////////////////////////////////////////
  api.use('iron:router@0.9.0', 'client');
  api.use('tmeasday:paginated-subscription@0.2.0', 'client');

  //////////////////////////////////////////////////////////////////
  // internal files
  //////////////////////////////////////////////////////////////////
  // load html first, https://github.com/meteor/meteor/issues/282
  api.add_files([
    'client/third-party/bootstrap.html', 'client/style.html',
    'client/admin_login.html', 'client/db_view.html',
    'client/collection_view.html', 'client/document_view.html',
    'client/admin_nav.html', 'client/master_layout.html',
    'client/admin_change_password.html', 'client/custom_template_view.html'],
  'client');

  api.add_files(['lib/collections.coffee', 'lib/shared.coffee', 'lib/menu.coffee'], ['client', 'server']);

  api.add_files([
    'client/third-party/bootstrap.min.js',
    'client/lib/shared.coffee',
    'client/custom_template_view.coffee',
    'client/router.coffee', 'client/admin_login.coffee',
    'client/collection_view.coffee', 'client/document_view.coffee',
    'client/admin_change_password.coffee',
    'client/admin_nav.coffee', 'client/db_view.coffee'],
  'client');

  api.add_files(['server/publications.coffee', 'server/exports.coffee'], 'server');
});
