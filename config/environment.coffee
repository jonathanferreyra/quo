module.exports = (compound) ->

  express = require 'express'
  app = compound.app
  passport = require('passport')
  acomplish = require('./acomplish')
  auth = require('./passport')
  methodOverride = require("method-override")
  device = require 'express-device'
  compound.async = require 'neo-async'
  compound.taffy = require('../public/javascripts/taffy').taffy
  useragent = require('express-useragent')
  helmet = require('helmet')

  ## Locale things
  app.configure ->
    app.set "defaultLocale", "es"

  app.configure "development", ->
    app.use express.errorHandler(
      dumpExceptions: true
      showStack: true
    )
    app.set "translationMissing", "display"

  app.configure "production", ->
    app.use express.errorHandler()
    app.set "translationMissing", "default"

  app.use (req, res, next) ->
    res.locals.isDemo = false
    res.locals.isMaintenance = false
    res.locals.isTesting = false

    app.settings.isDemo = res.locals.isDemo
    app.settings.isMaintenance = res.locals.isMaintenance
    app.settings.isTesting = res.locals.isTesting
    next()

  ## App things
  app.configure ->

    app.enable 'coffee'
    app.set 'cssEngine', 'stylus'
    app.set 'view engine', 'jade'


    #helpers for mobile
    express.application.app = @
    app.use device.capture()
    device.enableDeviceHelpers(@)
    # device.enableViewRouting(@)

    #optimize assets
    compound.app.cookieParser = express.cookieParser 'your_secret'
    app.use express.compress()
    year = 86400000 * 365
    app.use express.static(app.root + '/public', maxAge: year)
    # app.use express.bodyParser()
    app.use compound.app.cookieParser
    app.use express.urlencoded()
    app.use express.json()
    app.use methodOverride("X-HTTP-Method-Override")
    #other configs
    compound.loadConfigs __dirname

    #sessions manager
    if process.env.NODE_ENV == 'production'
      env_host = process.env.SESSION_HOST_ENV or "localhost"
      env_port = process.env.SESSION_PORT_ENV or "6379"
      env_session_db = process.env.SESSION_DATABASE_ENV or "sessions"
      env_pass = process.env.SESSION_PASS_ENV or ""

      RedisStore = require('connect-redis')(express)
      compound.app.mysessionstore = new RedisStore(
        host:     env_host
        port:     env_port
        pass:     env_pass
        db:       env_session_db
      )
      app.use express.session secret: 'your_secret', store: compound.app.mysessionstore
    else
      app.use express.session secret: 'secret'

    # secure things
    app.use(helmet.xssFilter())
    app.use(helmet.frameguard())
    app.use(helmet.hidePoweredBy())
    app.use(helmet.ieNoOpen())

    # acomplish
    app.use(acomplish.init(compound))

    # Initialize Passport Sessions, then Setup Passport
    # This MUST Be done in the right order, and BEFORE
    # the `app.router`
    app.use(passport.initialize())
    app.use(passport.session())
    app.use(useragent.express())

    # Must be called after ACL
    auth.init(compound)

    app.use app.router
    # redirect if nothing else sent a response
    # app.use (req, res) ->
    #   res.redirect '/'

    #### SETTINGS THINGS
    if process.env.IS_DEMO
      app.settings.isDemo = "true" == process.env.IS_DEMO
    if process.env.IS_MAINTENANCE
      app.settings.isMaintenance = "true" == process.env.IS_MAINTENANCE