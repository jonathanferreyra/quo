load 'base'

generic = compound.meg.generic

before 'load title', =>
  @title = 'Configuraciones'
  next()
, only: ['index', 'show', 'edit', 'update']

before 'load setting', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]

  Vars.classModel.findOne
    where:
      'i': session.user.i
  , (err, setting) =>
    if err
      render 'edit'
    else
      compound.ctrlsMeta.vars['Setting']['instanciaModel'] = setting
      @Vars = Vars
      next()
, only: ['show', 'edit', 'update', 'destroy']

action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  generic.create(context)

action 'index', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  context.respondTo (format) =>
    Vars.classModel.findOne
      where:
        'i': session.user.i
    , (err, setting) ->
      format.json =>
        setting = compound.meg.utils.removeMetaKeys([setting])[0]
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          setting = mask(setting, req.query.f)
        context.send code: 200, data: setting
      format.html =>
        compound.ctrlsMeta.vars['Setting']['instanciaModel'] = setting
        params =
          Vars : Vars
        context.render('edit', params)

action 'show', (context) =>
  generic.show(context)

action 'edit', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  context.respondTo (format) =>
    format.json =>
      Vars.classModel.find context.req.params.id, (err, item) =>
        if err || !item
          if !err && !item && params.format == 'json'
            context.send code: 404, error: 'Not found'
        else
          item = compound.meg.utils.removeMetaKeys([item])[0]
          context.send code: 200, data: item
    format.html =>
      Vars.classModel.findOne
        where:
          'i': session.user.i
      , (err, setting) ->
        compound.ctrlsMeta.vars['Setting']['instanciaModel'] = setting
        params =
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
          context.redirect '/settings'
        else
          context.flash 'error', 'No pudo ser actualizado'
          params =
            title : Vars.singleTitleModel + ' - Editar'
            Vars : Vars
          context.render('edit', params)

action 'destroy', (context) =>
  generic.destroy(context)