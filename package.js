Package.describe({
  summary: "A zero-config Meteor Admin"
});

Package.on_use(function(api) {
  api.use('deps', ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);
  api.use('accounts-base', ['client', 'server']);
  api.use('accounts-password', ['client', 'server']);

  api.use(['templating', 'check',  'iron-router', 'spin', 'handlebars', 'paginated-subscription'], 'client');

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
