Package.describe({
  name: "houston:admin",
  summary: "A zero-config Meteor Admin",
  version: "1.2.0",
  git: "https://github.com/gterrono/houston.git"
});

Package.on_use(function(api) {
  api.versionsFrom('METEOR@1.0');

  //////////////////////////////////////////////////////////////////
  // Meteor-provided packages
  //////////////////////////////////////////////////////////////////
  api.use('deps@1.0.0', ['client', 'server']);
  api.use('coffeescript@1.0.0', ['client', 'server']);
  api.use('accounts-base@1.0.0', ['client', 'server']);  // ?optional
  api.use('accounts-password@1.0.0', ['client', 'server']);
  api.use('templating@1.0.0', 'client');  // ?optional
  api.use('check@1.0.0', 'client');
  api.use('spacebars@1.0.0', 'client');

  //////////////////////////////////////////////////////////////////
  // Third-party package dependencies
  //////////////////////////////////////////////////////////////////
  api.use('iron:router@1.0.1', 'client');
  api.use('tmeasday:paginated-subscription@0.2.4', 'client');

  //////////////////////////////////////////////////////////////////
  // internal files
  //////////////////////////////////////////////////////////////////
  // load html first, https://github.com/meteor/meteor/issues/282
  api.add_files([
    // views
    'client/admin_login.html', 'client/db_view.html',
    'client/collection_view.html', 'client/document_view.html',
    'client/admin_change_password.html', 'client/custom_template_view.html',
    // partials
    'client/partials/admin_nav.html', 'client/partials/flash_message.html',
    // layout
    'client/master_layout.html',
    'client/third-party/collapse.js.html',
    'client/third-party/bootstrap.html',
    'client/style.css.html'
    ],
  'client');

  api.add_files(['lib/collections.coffee',
                 'lib/shared.coffee',
                 'lib/menu.coffee'],
                ['client', 'server']);

  api.add_files([
    // shared
    'client/lib/shared.coffee',
    // shared partials
    'client/partials/admin_nav.coffee', 'client/partials/flash_message.coffee',
    // view logic
    'client/custom_template_view.coffee', 'client/admin_login.coffee',
    'client/collection_view.coffee', 'client/document_view.coffee',
    'client/admin_change_password.coffee', 'client/db_view.coffee',
    // router
    'client/router.coffee'
    ],
  'client');

  api.add_files(['server/publications.coffee', 'server/exports.coffee', 'server/methods.coffee'], 'server');
});
