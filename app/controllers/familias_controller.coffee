load 'base'

generic = compound.meg.generic

action 'new', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = new Vars.classModel
  iId = session.user.i
  compound.models.Setting.getValue iId, 'familia_last_ide', (err, ide) ->
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
  compound.models.Setting.getValue iId, 'familia_last_ide', (err, ide) ->
    dataStore['ide'] = ide
    compound.models.Familia.create dataStore, (err, item) ->
      if !err
        compound.models.Timespan.refreshCacheAfterCreate(
          context.controllerName, Vars.Model, item)
      compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
      respondTo (format) =>
        format.json ->
          if err
            send code: 500, error: item.errors || err
          else
            item = compound.meg.utils.removeMetaKeys([item.toObject()])[0]
            context.send code: 200, data: item
        format.html =>
          params =
            Vars : Vars
          if err
            flash 'error', Vars.singleTitleModel + ' no pudo ser cread' + Vars.letraGenero
            params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
            render('new', params)
          else
            compound.models.Setting.incrementKey iId, 'familia_last_ide', () ->
              flash 'info', Vars.singleTitleModel + ' cread' + Vars.letraGenero
              if req.body.hasOwnProperty('continue')
                redirect '/' + Vars.pluralmodel + '/new'
              else
                redirect '/' + Vars.pluralmodel + '/' + item.id

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

@_parse_attrs_before_save = (context, cb) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  ####
  for k in ['nombre', 'apellido']
    if dataStore.hasOwnProperty(k)
      if typeof dataStore[k] == 'string'
        dataStore[k] = compound.utils.camelize(dataStore[k], true).trim()
  cb()

action 'addMember', =>
  compound.models.Familia.addMember body.familia, body.miembro, (err) ->
    send err

action 'getMembers', ->
  compound.models.Familia.getMembers session.user.i, params.id, (err, items) ->
    mask = require('json-mask')
    items = mask(items, 'id,ide,nombre,apellido')
    items = compound.meg.utils.removeMetaKeys(items)
    send items

action 'delMember', =>
  compound.models.Familia.delMember body.miembro, (err) ->
    send err