module.exports = (compound) ->
  app = compound.app

  # settings
  app.settings.cache = true # meg-cache
  app.settings.recreateViews = false # db-tools.coffee
  app.settings.saveUserAccess = false # useracceess
  app.settings.saveAjaxAccess = false # useracceess
  app.settings.deleteByReference = true
  app.settings.loadGeographicDataAtStart = true
  app.settings.login = false

  app.configure 'development', ->
    # html sale prettyfied
    app.locals.pretty = true
    app.enable 'log actions'
    app.enable 'env info'
    app.enable 'watch'
    # recompila los assets por load
    app.enable 'force assets compilation'
    app.use require('express').errorHandler
      dumpExceptions: true, showStack: true