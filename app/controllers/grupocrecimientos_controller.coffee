load 'base'

generic = compound.meg.generic

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
  dataStore.i = session.user.i

  Vars.classModel.all where: 'i': dataStore.i, (err, items) ->

    nros = [parseInt(item['nro']) for item in items]
    nros = if nros.length > 0 then nros[0] else []
    # valida que no exista un grupo con el mismo numero
    if nros.indexOf(parseInt(dataStore['nro'])) == -1
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
    else
      context.flash 'error', 'El actual número de grupo ya se encuentra en uso'
      params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
      context.render('new', {Vars : Vars})

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

action 'allgcs', ->
  Grupocrecimiento.all
    order: 'nro'
    where: 'i': session.user.i
  , (err, docs) =>
    send docs