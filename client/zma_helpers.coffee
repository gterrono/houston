if Handlebars?
  Handlebars.registerHelper('isAdminPage', ->
    window.location.pathname.indexOf('/admin') == 0)
