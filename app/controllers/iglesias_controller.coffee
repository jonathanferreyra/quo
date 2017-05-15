load 'base'

before 'validate access', (context) ->
  actn = context.actionName
  ctrl = context.controllerName
  format = if params.format == undefined then 'html' else 'json'
  if not session.user.owner
    if actn == 'index' and format == 'json'
      send code: 401, error: 'Authentication failed or user does not have permissions for the requested operation'
  next()

@_load_item = (context, callback) =>
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
      compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
      compound.ctrlsMeta.vars[nameModel]['instanciaRoute'] = Vars.pluralmodel + "/" + item["id"]
      cb()

  Iglesia.find session.user.i, (err, item) ->
    cbFnGetItem null, item, callback

before 'load item', (context) =>
  @._load_item context, () =>
    next()
, only: ['index','show', 'edit', 'update', 'destroy']

before 'load title', =>
  @title = 'Datos de la iglesia'
  next()
, only: ['index', 'show', 'edit']

generic = compound.meg.generic

action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  generic.create(context)

action 'index', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  context.respondTo (format) =>
    format.json =>
      cbFnAll = (err, items) ->
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          items = mask(items, req.query.f)
        context.send code: 200, data: items

      if compound.app.settings.cache and Vars.cache
        compound.meg.cache.all Vars.Model, cbFnAll
      else
        Vars.classModel.all Vars.Model, cbFnAll
    format.html =>
      params =
        title : Vars.titlemodel
        Vars : Vars
      context.render('edit', params)

action 'show', (context) =>
  generic.show(context)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  if dataStore.hasOwnProperty('authenticity_token')
    delete dataStore['authenticity_token']
  delete dataStore['i']
  Iglesia.find params.id, (err, item) ->
    # item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']
    item.updateAttributes dataStore, (err) =>
      if !err
        compound.models.Timespan.refreshCacheAfterUpdate(
          context.controllerName, Vars.Model, item)
      context.respondTo (format) =>
        format.json =>
          if err
            context.send code: 500, error: item.errors || err
          else
            context.send code: 200, data: item
        format.html =>
          if !err
            context.flash 'info', 'Cambios guardados correctamente'

            # set the church name showed in navheader
            session.user.churchTitle = item['nombre']

            context.redirect '/' + Vars.pluralmodel
          else
            context.flash 'error', 'No se pudieron guardar los cambios'
            params =
              title : 'Datos de la iglesia'
              Vars : Vars
            context.render('edit', params)

action 'destroy', (context) =>
  generic.destroy(context)