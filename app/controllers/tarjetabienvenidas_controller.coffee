load 'base'

generic = compound.meg.generic

action 'new', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = new Vars.classModel
  iId = session.user.i
  compound.models.Setting.getValue iId, 'tarjeta_bienvenida_last_ide', (err, ide) ->
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
  dataStore.i = iId
  compound.models.Setting.getValue iId, 'tarjeta_bienvenida_last_ide', (err, ide) ->
    dataStore['ide'] = ide
    compound.models.Tarjetabienvenida.create dataStore, (err, item) ->
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
            send code: 200, data: item
        format.html =>
          params =
            Vars : Vars
          if err
            flash 'error', Vars.singleTitleModel + ' no pudo ser cread' + Vars.letraGenero
            params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
            render('new', params)
          else
            compound.models.Setting.incrementKey iId, 'tarjeta_bienvenida_last_ide', () ->
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

####

action 'getby', =>
  Tarjetabienvenida.getBy session.user.i, req.query.f, req.query.v, (err, items) ->
    items = compound.meg.utils.removeMetaKeys(items)
    send err: err, items:items

action 'getTracing', =>
  # retorna los seguimientos para una tarjeta
  Tarjetabienvenida.getTracing session.user.i, params.id, (err, items) ->
    items = compound.meg.utils.removeMetaKeys(items)
    send items

action 'storeTracing', =>
  # guarda un nuevo siguimiento sobre una tarjeta
  Tarjetabienvenida.storeTracing session.user.i, body, session.user['id'], (err, res) ->
    send if err then false else true

action 'lastTracing', =>
  # obtiene el seguimiento con la fecha mas reciente
  compound.models.Seguimientopersona.all where: 'tarjeta_bienvenida': params.id, (err, items) ->
    if items.length > 0
      _ = require('lodash')._
      res = _.max items, (item) ->
        dt = item.fecha.replace('-','/')
        value = new Date(dt).valueOf()
        value
      send compound.meg.utils.removeMetaKeys([res])[0]
    else
      send {}

action 'createMember', =>
  Tarjetabienvenida.createMember session.user.i, session.user['id'], req.body.id, (err, item) ->
    if !err
      item = compound.meg.utils.removeMetaKeys([item])[0]
      send err: err, item:item
    else
      send err: err, item:item
      #flash 'error', 'Esta tarjeta ya se ha convertido en miembro anteriormente'
      #redirect '/tarjetabienvenidas/' + params.id

action 'getUserName', =>
  # devuelve el nombre del usuario que cargo la tarjeta
  Tarjetabienvenida.getUserName params.id, (err, res) ->
    send res

action 'goTo', =>
  # redirecciona a la tarjeta # ide
  _nro = params.id
  if typeof _nro == 'string'
    _nro = parseInt(_nro)
  Tarjetabienvenida.findOne
    where:
      'ide': _nro
      'i': session.user.i
  , (err, item) ->
    if err || !item
      flash 'error', 'No se ha encontrado una tarjeta con el número #' + _nro.toString()
      redirect '/tarjetabienvenidas'
    else
      redirect '/tarjetabienvenidas/' + item['id']

action 'stats', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  @Vars = compound.ctrlsMeta.vars[nameModel]
  @title = 'Estadísticas - Tarjetas de bienvenida'
  render()
