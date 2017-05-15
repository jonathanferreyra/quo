module.exports = (compound, User) ->

  User.validatesPresenceOf('displayName', {message: 'no puede ser un texto vacío'})

  # {string} url = direccion desde la que se accede al modelo
  # {string} title = titulo para mostrar
  # {string} pluralTitle = titulo para mostrar
  # {string|array} attrText = atributo que se usara por defecto para mostrar
  # {object} attrs = informacion de los atributos del modelo
  #   nombreattr :
  #     text:'' {string} nombre a mostrar del atributo
  #     type:'' {number|date|text} default: text
  #     required:bool {true|false} default: false
  #     ref:'NombreModeloReferencia'
  # references = informacion de los modelos que hacen referencia a este modelo
  #   linkBy:'{id|json}' = forma en que esta guardada la relacion al otro modelo
  #   hard:{true|false} = si es true, este modelo debe existir para que existan los demas
  #   attr:'nombreAttr' = nombre del atributo por defecto al que referencia en los otros modelos
  #   models:['Array','Of','Models'] = lista de nombres de modelos que dependen de este
  # exceptions: = indicar aqui si en algun modelo cualquiera de los valores
  #               anteriormente mensionados es diferente
  #   nombreModelo: {} = ej: hard:false, linkBy:json
  # actions = informacion meta sobre las acciones del controlador de este modelo
  #   include:[array of dict] = lista de acciones a incluir fuera de new|create|edit|show|index|destroy
  #     ej: [{action:'actionName',showname:'Text to show in GUI'}, ...]
  #   exclude:[array] = acciones a excluir dentro de new|create|edit|show|index|destroy
  #   ajax:[array] = lista de acciones que son request ajax
  #   ignore:[array] = lista de acciones a ignorar por el gestor de permisos
  # {bool} useIdentity = true si usa el atributo 'i'. 'i' especifica en que iglesia fue creado el elemento
  User.meta = () ->
    return meta =
      model: 'user'
      url: 'users'
      title: 'Usuario'
      pluralTitle: 'Usuarios'
      attrText: 'displayName'
      typeRef:'hard'
      exportable:false
      useIdentity:false
      attrs : {}
      references:
        linkBy:'id'
        attr:'user'
        models:[
        ]
      actions:
        include:[]
        exclude:[]
        ajax:[
          'get_user_account_emails'
          'add_account_email'
          'remove_account_email'
        ]
        ignore:[
          'profile'
          'upd_profile'
          'add_account_email'
          'remove_account_email'
          'get_user_account_emails'
        ]

  # Crea un nuevo usuario y toda la informacion
  # relacionada con una nueva cuenta:
  # User, Iglesia, Role, Setting, Accountinfo, Sharedinfo
  # Procedimiento:
  #   crear el usuario
  #   crear el accountinfo del usuario
  #   asociar el accountinfo al usuario
  #   crear la iglesia
  #   asociar la iglesia al usuario
  #   asociar el usuario a la lista de owners
  #   crear el setting de la iglesia
  #   crear el sharedinfo de la iglesia
  #   crear el rol administrador para la iglesia
  User.createNewAccount = (dataAccount, callback) ->
    m = compound.models

    compound.async.waterfall([
      (cb) ->
        # crea el user
        toSave =
          displayName: dataAccount.nombre + ' ' + dataAccount.apellido
          email: dataAccount.emails
          creation_date: new Date().toISOString()
          roles:''
          account_emails:JSON.stringify([dataAccount.emails])
        m.User.create toSave, cb
      , (user, cb) ->
        # crea el account info
        toSave =
          user: user.id
          nombre: dataAccount.nombre
          apellido: dataAccount.apellido
          telefonos: dataAccount.telefonos
          emails: dataAccount.emails
          pais: dataAccount.pais
          fechaAlta: new Date().toISOString().split('T')[0]
          creation_date: new Date().toISOString()
        if dataAccount.mode
          toSave.mode = dataAccount.mode
        m.Accountinfo.create toSave, (err, ai) ->
          cb(err, user)
      , (user, cb) ->
        # crea la iglesia
        toSave =
          nombre: 'Mi iglesia'
          owners: JSON.stringify([user.id])
        m.Iglesia.create toSave, (err, iglesia) ->
          user.updateAttribute 'iglesias', JSON.stringify([iglesia.id]), () ->
            cb(err, user, iglesia)
      , (user, iglesia, cb) ->
        # crea el setting de la iglesia
        toSave =
          i: iglesia.id
          creation_date: new Date().toISOString()
        m.Setting.create toSave, (err, setting) ->
          cb(err, user, iglesia)
      , (user, iglesia, cb) ->
        # crea el shared info
        toSave =
          iglesias: JSON.stringify([iglesia.id])
        m.Sharedinfo.create toSave, (err, si) ->
          iglesia.updateAttribute 'shared_info', si.id, () ->
            cb(err, user, iglesia)
      , (user, iglesia, cb) ->
        # crea el rol administrador para la iglesia
        all_permissions = JSON.stringify(
          compound.acomplish.permissions.all_actions)
        m.Role.customCreate {
          i: iglesia.id
          name:'Administrador'
          description:'Administrador general'
          permissions:all_permissions
        }, (err, role) ->
          compound.models.Timespan.refreshCacheAfterUpdate('roles', 'Role', role)
          # setea el rol al usuario
          user.updateAttribute 'roles', role.id, () ->
            # agrega el user/rol a la iglesia
            value = {}
            value[user.id] = role.id
            iglesia.updateAttribute 'users', JSON.stringify(value), () ->
              compound.models.Timespan.refreshCacheAfterUpdate 'iglesias', 'Iglesia', iglesia, () ->
                compound.models.Timespan.refreshCacheAfterUpdate 'users', 'User', user, () ->
                  cb(err, user, role)
    ], callback )

  User.convertUserInAccountOwner = () ->

  User.customCreate = (data, cb) ->
    # console.log 'User.customCreate', data
    role = ''
    if data.hasOwnProperty('role')
      role = data.role
    avatar = ''
    if data.profile.hasOwnProperty('_json')
      avatar = data.profile['_json']['picture']
    User.create
      displayName: data.profile.displayName
      email: data.profile.emails[0].value
      openId: data.openId
      creation_date : new Date().toISOString()
      account_emails:JSON.stringify([data.profile.emails[0].value])
      avatar_url: avatar
      roles: role
    , cb

  User.findOrCreate = (data, done) ->
    # console.log '>>> User.findOrCreate : ', data
    getUser = (data, cb) ->
      User.all
        where:
          openId: data.openId
        limit: 1
      , (err, user) ->
        if user.lenght > 0
          cb(err, user[0])
        else
          User.customCreate data, cb

    user_email = data.profile.emails[0].value
    User.isInternalEmail user_email, (user, isInternal) ->
      if isInternal
        if user
          if not user.deleted
            compound.acomplish._user.email_in_use = user_email
            # guarda el email con el que accedio
            if user.email != user_email
              user.updateAttribute 'email', user_email, () ->
            # if have empty fields
            haveEmptyFields = false
            if user.hasOwnProperty('openId')
              if user.openId.length == 0
                haveEmptyFields = true
            if user.hasOwnProperty('displayName')
              if user.displayName.length == 0
                haveEmptyFields = true
            if user.hasOwnProperty('avatar_url')
              if user.avatar_url.length == 0
                haveEmptyFields = true
            else
                haveEmptyFields = true
            if haveEmptyFields
              User.fillEmptyFields user, data, (fill_user) ->
                done(null, fill_user)
            else
              done(null, user)
          else
            # user is disabled
            done(null, false, { message: 'Your accout has been disabled.' })
        else
          User.customCreate data, done
      else
        # interrumpír aquí si se desea guardar un log
        # de aquellos intentos de logueo con
        # emails no dados de alta
        done(null, false, { message: 'Email not valid.' })

  User.checkOwner = (email) ->
    owners = compound.acomplish.settings.owners or false
    unless owners
      return false
    owners.indexOf(email) isnt -1

  # asocia un nuevo email a la cuenta del usuario
  User.addEmailAccount = (user_id, new_email, cb) ->
    User.find user_id, (err, user) ->
      user_account_emails = JSON.parse(user.account_emails)
      if user_account_emails.indexOf(new_email) is -1
        user_account_emails.push(new_email)
        user.updateAttribute 'account_emails', JSON.stringify(user_account_emails), cb
        # si es un user owner, agrega el email a settings.owners
        for e in user_account_emails
          if compound.acomplish.settings.owners.indexOf(e) != -1
            compound.acomplish.settings.owners.push(new_email)
      else
        cb(null)

  User.removeEmailAccount = (user_id, email, cb) ->
    User.find user_id, (err, user) ->
      emails = JSON.parse(user.account_emails)
      index = emails.indexOf(email)
      if index > -1
        emails.splice(index, 1) #remove element of specific position
        user.updateAttribute 'account_emails', JSON.stringify(emails), (err) ->
          # compound.models.Setting.removeUserAccountEmail user, email, (err) ->
            cb(err)

  # Retorna una lista de los emails asociados a un usuario
  User.getAccountEmails = (user_id, cb) ->
    User.find user_id, (err, user) ->
      emails = []
      try
        emails = JSON.parse(user['account_emails'])
      catch e
        emails.push(user['email'])
      cb(err, emails)

  # check if email is registered in the system
  User.isInternalEmail = (user_email, cb) ->
    User.all (err, items) ->
      user = null
      isInternal = false
      stEmailOwners = JSON.stringify(compound.acomplish.settings.owners)
      for item in items
        # checkea si el email es algun email
        # existente dentro de los usuarios actuales
        if item.email.indexOf(user_email) != -1 or item.account_emails.indexOf(user_email) != -1
          isInternal = true
          user = item
          break
      # checkea si el email es alguno de los superadmins
      if not isInternal
        if compound.acomplish.settings.owners.indexOf(user_email) != -1
          isInternal = true
      cb(user, isInternal)

  # Comprueba que los datos de un usuario esten completos
  # Al loguearce si hay algun campo vacio, lo rellena
  User.fillEmptyFields = (data_user, data_profile, cb) ->
    to_fill = {}
    source =
      openId: data_profile.openId
      displayName: data_profile.profile.displayName

    for k in ['openId', 'displayName']
      if data_user.hasOwnProperty(k)
        if data_user[k].length == 0
          to_fill[k] == source[k]
      else
        to_fill[k] == source[k]

    try
      obj_data_user = data_user.toObject()
    catch e
      obj_data_user = {}

    to_fill['avatar_url'] = ''
    if obj_data_user.hasOwnProperty('avatar_url')
      if typeof obj_data_user['avatar_url'] != 'undefined'
        if obj_data_user['avatar_url'].length == 0
          if data_profile.profile.hasOwnProperty('_json')
            to_fill['avatar_url'] = data_profile.profile._json.picture

    if Object.keys(to_fill).length > 0
      data_user.updateAttributes to_fill, (err) ->
        cb(data_user)
    else
      cb(data_user)

  # retorna los usuarios que son owner = false
  User.allNotOwner = (iglesiaId, cb) ->
    User.all
      where:
        'deleted': false
        'i': iglesiaId
    , (err, items) ->
      result = []
      for item in items
        if not User.checkOwner(item.email)
          result.push(item)
      cb(err, result)

  # carga el nombre de la iglesia con la que
  # se esta trabajando, en la sesion actual
  User.getIglesia = (user, callback) ->
    getIglesiaByUser = (user, cb) ->
      iglesiaId = ''
      if user.iglesias.length > 0
        iglesias = JSON.parse(user.iglesias)
        if iglesias.length > 0
          iglesiaId = iglesias[0]
      if iglesiaId.length == 0
        cb(throw new Error('User has no asignned church'), null)
      else
        compound.models.Iglesia.find iglesiaId, cb

    # carga la iglesia de prueba para los users owners
    if user.email in compound.acomplish.settings.owners
      compound.models.User.findOne where: email:'develop@quo.com', (err, devUser) ->
        compound.models.User.find user.id, (err, docUser) ->
          if user.iglesias.length == 0
            # actualiza attrs in user owner
            docUser.updateAttribute 'iglesias', devUser.iglesias, () ->
              compound.models.Iglesia.find JSON.parse(devUser.iglesias)[0], (err, iglesia) ->
                users = JSON.parse(iglesia.users)
                users[user.id] = devUser.roles
                iglesia.updateAttribute 'users', JSON.stringify(users), () ->
                getIglesiaByUser(devUser, callback)
          else
            getIglesiaByUser(devUser, callback)
    else
      getIglesiaByUser(user, callback)

  # verifica si el usuario indicado
  # es propietario de una cuenta
  User.isClient = (user, cb) ->
    isClient = false
    compound.models.Accountinfo.all (err, items) ->
      if !err
        usersIds = [item.user for item in items]
        if usersIds.length > 0
          usersIds = usersIds[0]
        isClient = usersIds.indexOf(user.id) != -1
      cb(err, isClient)

  # retorna los usuarios que son
  # propietarios de cuenta
  User.getUsersAccountOwner = (cb) ->
    compound.models.Accountinfo.all (err, items) ->
      compound.async.map items, (item, mapCb) ->
        compound.meg.cache.get item.user, mapCb
      , cb