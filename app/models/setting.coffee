module.exports = (compound, Setting) ->

  # For more info of meta() view models/user.coffee file
  Setting.meta = () ->
    return meta =
      model: 'setting'
      url: 'settings'
      title: 'Configuraciones'
      pluralTitle: 'Configuraciones'
      attrText: ''
      attrs : {}
      references: {}
      actions:
        exclude:["new", "create", "destroy", "show", "index"]
        include:[]
        ajax:[]
        ignore:[]

  Setting.getValue = (iglesiaId, key, cb) ->
    Setting.findOne where:{ 'i': iglesiaId }, (err, doc) ->
      cb(err, doc[key])

  Setting.getValues = (iglesiaId, cb) ->
    Setting.findOne where:{ 'i': iglesiaId }, cb

  Setting.setValue = (iglesiaId, key, value, cb) ->
    Setting.findOrCreate (setting) =>
      if setting.hasOwnProperty(key)
        setting.updateAttribute key, value, () ->
          cb(false)
      else
        cb(true)

  Setting.getOwnerEmails = (iglesiaId, cb) ->
    Setting.findOne where:{ 'i': iglesiaId }, (err, item) ->
      emails = []
      if !err
        if item.hasOwnProperty('owner_emails')
          emails = item.owner_emails.split('\r\n')
      cb(err, emails)

  Setting.incrementKey = (iglesiaId, value, cb) ->
    Setting.findOne where:{ 'i': iglesiaId }, (err, doc) ->
      doc.updateAttribute value, parseInt(doc[value]) + 1, cb

  # agrega al indice de emails el nuevo indicado
  # el contenido de setting.users_accounts_emails
  # es un diccionario con formato {user_email:user_id}
  Setting.addUserAccountEmail = (iglesiaId, user, email, cb) ->
    Setting.getValues iglesiaId, (err, setting) ->
      emails = JSON.parse(setting.users_accounts_emails)
      emails[email] = user.id
      setting.updateAttribute 'users_accounts_emails', JSON.stringify(emails), (err) ->
        cb(err)

  Setting.removeUserAccountEmail = (iglesiaId, user, email, cb) ->
    Setting.getValues iglesiaId, (err, setting) ->
      emails = JSON.parse(setting.users_accounts_emails)
      delete emails[email]
      setting.updateAttribute 'users_accounts_emails', JSON.stringify(emails), (err) ->
        cb(err)

  # retorna el id de un usuario a partir del email
  # solamente busca dentro de los emails secundarios
  Setting.getUserIdByEmail = (iglesiaId, user_email, cb) ->
    Setting.getValues iglesiaId, (err, setting) ->
      emails = JSON.parse(setting.users_accounts_emails)
      user_id = null
      if emails.hasOwnProperty(user_email)
        user_id = emails[user_email]
        return cb(null, user_id)
      else
        compound.models.User.findOne
          where:
            email: user_email
        , (err, user) ->
          cb(err, if user then user.id else null)