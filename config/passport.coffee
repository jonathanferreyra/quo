exports.init = (compound) ->

  app = compound.app
  passport = require("passport")
  confs = compound.acomplish.passport

  passport.serializeUser serializeUser = (user, done) ->
    done null, user.id

  passport.deserializeUser deserializeUser = (userId, done) ->
    compound.models.User.find userId, (err, user) ->
      done err, user

  ##
  ## Google
  ##

  GoogleStrategy = require("passport-google-oauth").OAuth2Strategy

  # https://console.developers.google.com/project
  # skeletor > APIS & AUTH > Credentials
  GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID"
  GOOGLE_CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET"
  passport.use new GoogleStrategy(
    clientID: GOOGLE_CLIENT_ID
    clientSecret: GOOGLE_CLIENT_SECRET
    callbackURL: confs.host + "/auth/google/callback"
  , (accessToken, refreshToken, profile, done) ->
    compound.models.User.findOrCreate
      openId: accessToken
      profile: profile
    , (err, user) ->
      done err, user
  )

  app.get "/auth/google", passport.authenticate("google", {
    scope: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email'
    ]
  })
  app.get "/auth/google/callback", passport.authenticate("google",
    successRedirect: "/"
    failureRedirect: "/login"
  )

  ##
  ## Windows Live
  ##

  # WindowsLiveStrategy = require('passport-windowslive').Strategy
  # WINDOWS_LIVE_CLIENT_ID = "YOUR_WINDOWS_LIVE_CLIENT_ID"
  # WINDOWS_LIVE_CLIENT_SECRET = "YOUR_WINDOWS_LIVE_CLIENT_SECRET"
  # passport.use new WindowsLiveStrategy(
  #   clientID: WINDOWS_LIVE_CLIENT_ID
  #   clientSecret: WINDOWS_LIVE_CLIENT_SECRET
  #   callbackURL: confs.host +  "/auth/windowslive/callback"
  # , (accessToken, refreshToken, profile, done) ->
  #   compound.models.User.findOrCreate
  #     openId: ''
  #     profile: profile
  #   , (err, user) ->
  #     done err, user
  # )

  # app.get "/auth/windowslive", passport.authenticate("windowslive",
  #   scope: [ "wl.signin", "wl.basic" ]
  # ), (req, res) ->

  # app.get "/auth/windowslive/callback", passport.authenticate("windowslive",
  #   failureRedirect: "/login"
  # ), (req, res) ->
  #   res.redirect "/"

  ##
  ## Yahoo
  ##
  YahooStrategy = require('passport-yahoo').Strategy
  passport.use new YahooStrategy(
    returnURL: confs.host + "/auth/yahoo/return"
    realm: confs.host + confs.path
    profile: true
  , (identifier, profile, done) ->
    compound.models.User.findOrCreate
      openId: identifier
      profile: profile
    , (err, user) ->
      done err, user
  )
  app.get "/auth/yahoo", passport.authenticate("yahoo")
  app.get "/auth/yahoo/return", passport.authenticate("yahoo",
    failureRedirect: "/"
  ), (req, res) ->
    res.redirect "/"