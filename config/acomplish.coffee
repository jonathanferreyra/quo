# This should be called as Connect middleware, and
# extends the underlying CompoundJS framework.

dir = "./config/acomplish/"
files = require("fs").readdirSync(dir)
cjson = require("cjson")

exports.init = (compound) ->
  env = compound.app.settings.env
  acomplish = {}
  files.forEach (conf) ->
    name = conf.replace(/\.[^/.]+$/, "")
    data = cjson.load(dir + conf)

    if name in ["settings","permissions","controllers"]
      acomplish[name] = data
    else if name is "acl"
      acomplish[name] = data['development']
    else
      acomplish[name] = data[env]
  compound.acomplish = acomplish
  compound.acomplish._user = {}

  if process.env.BASE_HOST_URL
    compound.acomplish.passport.host = process.env.BASE_HOST_URL
  compound