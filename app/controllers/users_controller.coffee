load 'base'

generic = compound.meg.generic

@_load_item = (context, callback) =>
  console.log '>>> '
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  cbFnGetItem = (err, item, cb) =>
    if err || !item
      if !err && !item && req.params.format == 'json'
        context.send code: 404, error: 'Not found'
      context.redirect Vars.pluralmodel
    else
      ctrl = context.controllerName
      nameModel = compound.ctrlsMeta.modelByUrls[ctrl]
      compound.models.Role.find item.roles, (err, role) ->
        item['rolesNames'] = role.name
        compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
        compound.ctrlsMeta.vars[nameModel]['instanciaRoute'] = Vars.pluralmodel + "/" + item["id"]
        cb()

  if compound.app.settings.cache and Vars.cache
    compound.meg.cache.get req.params.id, (err, item) ->
      cbFnGetItem err, item, callback
  else
    Vars.classModel.find req.params.id, (err, item) ->
      cbFnGetItem err, item, callback

@_getItem = (Vars, cb) =>
  try
    try
      item = Vars.instanciaModel.toObject()
    catch e
      item = Vars.instanciaModel
    mask = require('json-mask')
    item = mask(item, compound.ctrlsMeta.vars['User']['visibleAttrs'])
    if Vars.classModel.hasOwnProperty('meta')
      metaInfo = Vars.classModel.meta()
      item['__attrText'] = metaInfo.attrText
    cb(null, item)
  catch TypeError
    cb(null, {})

before 'validate security data', (context) ->
  cache = compound.meg.cache
  format = if params.format == undefined then 'html' else 'json'

  notFound = () ->
    if format == 'html'
      redirect '/notFound'
    else if format == 'json'
      send code:404, error:'Not found'

  # valida que el doc a visualizar
  # corresponda con el cliente actual
  userId = params.id
  cache.get session.user.i, (err, iglesia) ->
    if !err
      usersIds = []
      if iglesia.users
        usersIds = Object.keys(JSON.parse(iglesia.users))
      if usersIds.indexOf(userId) != -1
        next()
      else
        notFound()
    else
      notFound()
, only: ['show']

before 'validate presence of', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  format = if params.format == undefined then 'html' else 'json'
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body

  showError = (attr) ->
    message = attr + ' no puede ser un texto vacío'
    if format == 'html'
      flash 'error', message
      params = {Vars : Vars}
      params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
      render('new', params)
    else if format == 'json'
      context.send code: 500, error: message

  for key in ['roles','account_emails']
    if not dataStore.hasOwnProperty(key)
      break
      showError('Rol')
    else if dataStore[key].length == 0
      break
      showError('Cuentas de correo')
  next()
, only: ['create', 'update']

before 'validate unique', (context) ->
  compound.meg.generic._validatesUniquenessOf context, 'name', () ->
    next()
, only: ['create', 'update']

before 'visible attrs', (context) ->
  compound.ctrlsMeta.vars['User']['visibleAttrs'] =
    'id,displayName,email,account_emails,roles,deleted,avatar_url,disabled_date'
  next()
, only: ['index','show','getItem']

action 'new', (context) =>
  generic.new(context)

action 'index', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  cache = compound.meg.cache
  context.respondTo (format) =>
    format.json =>
      cache.get session.user.i, (err, iglesia) ->
        usersIds = []
        if iglesia.users
          usersIds = Object.keys(JSON.parse(iglesia.users))
        if usersIds.length > 0
          compound.async.map usersIds, (userId, mapCb) ->
            compound.models.User.find userId, mapCb
          , (err, userDocs) ->
            mask = require('json-mask')
            items = mask(userDocs, compound.ctrlsMeta.vars[nameModel]['visibleAttrs'])
            send code:200, data: items
        else
          send code:200, data:[]
      # if session.user.owner
      #   Vars.classModel.all
      #     where:
      #       'deleted': false
      #       'i': session.user.i
      #   , (err, AllItems) =>
      #     context.send code: 200, data: AllItems
      # else
      #   iglesiaId = session.user.i
      #   Vars.classModel.allNotOwner iglesiaId, (err, AllItems) =>
      #     context.send code: 200, data: AllItems
    format.html =>
      params =
        title : Vars.titlemodel
        Vars : Vars
      context.render(params)

action 'create', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  if dataStore.hasOwnProperty('authenticity_token')
    delete dataStore['authenticity_token']

  if compound.app.compound.orm._schemas[0].name == 'memory'
    dataStore._id = generic.guid()

  identityId = session.user.i
  if dataStore.account_emails
    dataStore.email = JSON.parse(dataStore.account_emails)[0]
  dataStore.iglesias = JSON.stringify([identityId])
  Vars.classModel.create dataStore, (err, item) =>
    if !err
      compound.models.Timespan.refreshCacheAfterCreate(
        context.controllerName, Vars.Model, item)

      # setea el user a iglesia.users
      compound.models.Iglesia.find identityId, (err, iglesia) ->
        users = {}
        if iglesia.users
          users = JSON.parse(iglesia.users)
        users[item.id] = item.roles
        iglesia.updateAttribute 'users', JSON.stringify(users), () ->
          compound.models.Timespan.refreshCacheAfterUpdate(
            'iglesias', 'Iglesia', iglesia)

    compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item

    context.respondTo (format) =>
      format.json ->
        if err
          context.send code: 500, error: item.errors || err
        else
          item = compound.meg.utils.removeMetaKeys([item.toObject()])[0]
          context.send code: 200, data: item
      format.html =>
        params =
          Vars : Vars
        if err
          context.flash 'error', Vars.singleTitleModel + ' no pudo ser cread' + Vars.letraGenero
          params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
          context.render('new', params)
        else
          context.flash 'info', Vars.singleTitleModel + ' cread' + Vars.letraGenero
          if req.body.hasOwnProperty('continue')
            context.redirect '/' + Vars.pluralmodel + '/new'
          else
            context.redirect '/' + Vars.pluralmodel + '/' + item.id

action 'show', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  context.respondTo (format) =>
    format.json =>
      Vars.classModel.find req.params.id, (err, item) =>
        if err || !item
          if !err && !item && req.params.format == 'json'
            context.send code: 404, error: 'Not found'
        else
          compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
          item = compound.meg.utils.removeMetaKeys([item])[0]
          mask = require('json-mask')
          if req.query.hasOwnProperty('f')
            item = mask(item, req.query.f)
          item = mask(item, compound.ctrlsMeta.vars[nameModel]['visibleAttrs'])
          context.send code: 200, data: item
    format.html =>
      params =
        title : generic._get_showname_item(nameModel) + Vars.singleTitleModel + ' - Detalles'
        Vars : Vars
      context.render(params)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']
  item.updateAttribute 'deleted', true, (error) ->
    item.updateAttribute 'disabled_date', new Date().toISOString(), (error) ->
      if !error
        compound.models.Timespan.refreshCacheAfterDestroy(
          context.controllerName, Vars.Model, item)
      context.respondTo (format) ->
        format.json ->
          if error
            context.send code: 500, error: error
          else
            context.send code: 200
        format.html ->
          if error
            flash 'error', 'No se pudo deshabilitar '
          else
            flash 'info', 'Deshabilitado correctamente'
  context.send "'/" + Vars.pluralmodel + "/" + item['id'] + "'"

action 'profile', ->
  @title = 'Perfil'
  render()

action 'upd_profile', ->
  attrs =
    displayName : body.dn
  User.find session.user.id, (err, doc_user) ->
    doc_user.updateAttributes attrs, (err) ->
      session.user.displayName = doc_user.displayName
      send true

action 'add_account_email', ->
  userId = if body.hasOwnProperty('id') then body.id else session.user.id
  User.addEmailAccount userId, body.email, (err) ->
    send true

action 'remove_account_email', ->
  userId = if body.hasOwnProperty('id') then body.id else session.user.id
  User.removeEmailAccount userId, body.email, (err) ->
    send true

action 'get_user_account_emails', ->
  userId = if params.id == 'id' then session.user.id else params.id
  User.getAccountEmails userId, (err, emails) ->
    send emails

action 'setEnabled', ->
  itemId = req.body.id
  User.find itemId, (err, user) ->
    user.updateAttribute 'deleted', false, () ->
      compound.models.Timespan.updateTS 'users', new Date().valueOf(), () ->
        send "'/users/" + itemId + "'"

action 'existEmail', ->
  checkEmail = params.id
  compound.meg.cache.all 'User', (err, items) ->
    exist = false
    for item in items
      if typeof item.account_emails != 'undefined' or item.account_emails != null
        value = item.account_emails
        if value.indexOf(checkEmail) != -1
          exist = true
      else
        if typeof item.email != 'undefined' or item.email != null
          value = item.email
          if value.indexOf(checkEmail) != -1
            exist = true
    send { 'exist': exist }