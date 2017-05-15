module.exports = (compound) ->
  app = compound.app

  # settings
  app.settings.cache = true
  app.settings.recreateViews = true
  app.settings.saveUserAccess = true
  app.settings.saveAjaxAccess = false
  app.settings.deleteByReference = true
  app.settings.loadGeographicDataAtStart = true
  app.settings.login = true

  if app.settings.isDemo
    app.settings.login = false

  app.configure 'production', ->
    app.set 'view cache', true
    app.enable 'minify'
    app.enable 'merge javascripts'
    app.enable 'merge stylesheets'
    app.disable 'assets timestamps'
    app.use require('express').errorHandler()
    app.enable 'quiet'
