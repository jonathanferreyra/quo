load 'base'

generic = compound.meg.generic

action 'new', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = new Vars.classModel
  iId = session.user.i
  compound.models.Setting.getValue iId, 'miembro_last_ide', (err, ide) ->
    params =
      nextIde : ide
      title : Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero + ' #' + ide
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

  iId = session.user.i
  compound.models.Setting.getValue iId, 'miembro_last_ide', (err, ide) =>
    dataStore['ide'] = ide

    if compound.app.compound.orm._schemas[0].name == 'memory'
      dataStore._id = @._guid()

    Vars.classModel.create dataStore, (err, item) =>
      if !err
        compound.models.Timespan.refreshCacheAfterCreate(
          context.controllerName, Vars.Model, item)
      compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
      context.respondTo (format) =>
        format.json ->
          if err
            context.send code: 500, error: item.errors || err
          else
            context.send code: 200, data: item.toObject()
        format.html =>
          params =
            Vars : Vars
          if err
            context.flash 'error', Vars.singleTitleModel + ' no pudo ser cread' + Vars.letraGenero
            params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
            context.render('new', params)
          else
            compound.models.Setting.incrementKey iId,  'miembro_last_ide', ->
              context.flash 'info', Vars.singleTitleModel + ' cread' + Vars.letraGenero
              if req.body.hasOwnProperty('continue')
                context.redirect '/' + Vars.pluralmodel + '/new'
              else
                context.redirect '/' + Vars.pluralmodel + '/' + item.id

action 'index', (context) =>
  generic.index(context)

action 'show', (context) =>
  generic.show(context)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  generic.destroy(context)

action 'empty_family', ->
  Miembro.getEmptyFamily session.user.i, (err, items) ->
    send items

####

action 'stats', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  @Vars = compound.ctrlsMeta.vars[nameModel]
  @title = 'Estadísticas - Miembros'
  render()

action 'goTo', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  # redirecciona al miembro # ide
  _nro = params.id
  if typeof _nro == 'string'
    _nro = parseInt(_nro)
  Vars.classModel.findOne
    where:
      'ide': _nro
      'i': session.user.i
  , (err, item) ->
    if err || !item
      flash 'error', 'No se ha encontrado un miembro con el número #' + _nro.toString()
      redirect '/' + Vars.pluralmodel
    else
      redirect '/' + Vars.pluralmodel + '/' + item['id']