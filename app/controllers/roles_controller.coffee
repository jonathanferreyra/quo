load 'base'

generic = compound.meg.generic

node_cryptojs = require('node-cryptojs-aes')

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
  Role.find params.id, (err, item) ->
    if !err
      if item.i == session.user.i
        next()
      else
        notFound()
    else
      notFound()
, only: ['show']

before 'validate unique', (context) ->
  compound.meg.generic._validatesUniquenessOf context, 'name', () ->
    next()
, only: ['create', 'update']

# reimplemented method generic
@_getItemsByType = (refs, refModel, itemId, cb) =>
  _attr = refs.attr
  _linkBy = refs.linkBy
  if refs.hasOwnProperty('excepts')
    if refs.excepts.hasOwnProperty(refModel)
      if refs.excepts[refModel].attr
        _attr = refs.excepts[refModel].attr
      if refs.excepts[refModel].linkBy
        _linkBy = refs.excepts[refModel].linkBy

  compound.meg.cache.get itemId, (err, role) =>
    matched = []
    query =
      model: refModel
      'i': session.user.i
    compound.meg.cache.find query, (err, items) =>
      if !err
        for item in items
          if item[_attr]
            if item[_attr].indexOf(role.raw_name) != -1
              matched.push(item)
        cb(err, matched)
      else
        cb(err, items)

action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  if dataStore.hasOwnProperty('authenticity_token')
    delete dataStore['authenticity_token']
  dataStore.c = session.user.c
  Vars.classModel.customCreate dataStore, (err, item) =>
    if !err
      compound.models.Timespan.refreshCacheAfterCreate(
        context.controllerName, Vars.Model, item)
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

action 'index', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  context.respondTo (format) =>
    format.json =>
      cbFnAll = (err, items) ->
        items = compound.meg.utils.removeMetaKeys(items)
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          items = mask(items, req.query.f)
        context.send code: 200, data: items

      iglesiaId = context.req.session.user.i

      if compound.app.settings.cache and Vars.cache
        compound.meg.cache.all Vars.Model, (err, allItems) ->
          _query =
            'model': Vars.Model
            'i': iglesiaId
          compound.meg.cache.find(_query, cbFnAll)
      else
        Vars.classModel.all({where: {'i': iglesiaId}}, cbFnAll)
    format.html =>
      params =
        title : Vars.titlemodel
        Vars : Vars
      context.render(params)

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
          item.permissions = Vars.classModel.decrypt(item.permissions)
          item = compound.meg.utils.removeMetaKeys([item])[0]
          if req.query.hasOwnProperty('f')
            mask = require('json-mask')
            item = mask(item, req.query.f)
          compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
          context.send code: 200, data: item
    format.html =>
      if Vars.instanciaModel.permissions.indexOf('{') == -1
        Vars.instanciaModel.permissions = Role.decrypt(Vars.instanciaModel.permissions)
      params =
        title : @._get_showname_item(nameModel) + Vars.singleTitleModel + ' - Detalles'
        Vars : Vars
      context.render(params)

action 'edit', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  context.respondTo (format) =>
    format.json =>
      Vars.classModel.find req.params.id, (err, item) =>
        if err || !item
          if !err && !item && params.format == 'json'
            context.send code: 404, error: 'Not found'
        else
          item = compound.meg.utils.removeMetaKeys([item])[0]
          context.send code: 200, data: item
    format.html =>
      Vars.instanciaModel.permissions = Role.decrypt(Vars.instanciaModel.permissions)
      params =
        title : @._get_showname_item(nameModel) + Vars.singleTitleModel + ' - Editar'
        Vars : Vars
      context.render(params)

action 'update', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  if dataStore.hasOwnProperty('authenticity_token')
    delete dataStore['authenticity_token']
  item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']

  permissions = Role._parsePermissionsToSave(dataStore.permissions)
  dataStore.permissions = Role.encrypt(permissions)

  item.updateAttributes dataStore, (err) =>
    if !err
      compound.models.Timespan.refreshCacheAfterUpdate(
        context.controllerName, Vars.Model, item)
    context.respondTo (format) =>
      format.json =>
        if err
          context.send code: 500, error: item.errors || err
        else
          item = compound.meg.utils.removeMetaKeys([item])[0]
          context.send code: 200, data: item
      format.html =>
        if !err
          context.flash 'info', 'Actualizado correctamente'
          context.redirect Vars.instanciaRoute
        else
          context.flash 'error', 'No pudo ser actualizado'
          params =
            title : Vars.singleTitleModel + ' - Editar'
            Vars : Vars
          context.render('edit', params)

action 'destroy', (context) =>
  generic.destroy(context)

action 'users', ->
  # obtiene los usuarios que poseen el rol buscado
  Role.getUsers params.id, session.user.i, (err, items) ->
    send if !err then items else []

action 'actions', ->
  send compound.models.Role._getActionsControllers()

action 'setRole', ->
  compound.models.User.find req.body.user, (err, user) ->
    if !err
      user.updateAttribute 'roles', req.body.role, () ->
        send err:null, res:true
    else
      send err:err, res:null