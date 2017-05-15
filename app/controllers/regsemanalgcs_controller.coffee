load 'base'

generic = compound.meg.generic

@_parse_attrs_before_save = (context, cb) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  ####
  for k in ['timonel', 'timoteo']
    delete dataStore[k]
  dataStore['reunion_suspendida'] = if dataStore['reunion_suspendida'] then true else false
  dataStore.total_asistencias = Regsemanalgc.cantidadAsistencias(context.req.body[Vars.Model])
  context.req.body[Vars.Model] = dataStore
  cb()

@_parse_attrs_before_update = @_parse_attrs_before_save


action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  generic.create(context)

action 'index', (context) =>
  generic.index(context)

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
          item = compound.meg.utils.removeMetaKeys([item])[0]
          if req.query.hasOwnProperty('f')
            mask = require('json-mask')
            item = mask(item, req.query.f)
          compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
          context.send code: 200, data: item
    format.html =>
      Regsemanalgc.splitKeys Vars.instanciaModel, (regsemanalgc) =>
        compound.meg.cache.get regsemanalgc.grupo, (er, gc_data) =>
          params =
            title : @_get_showname_item(nameModel) + Vars.singleTitleModel + ' - Detalles'
            Vars : Vars
            regsemanalgc: regsemanalgc
            grupo: gc_data
          context.render(params)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  generic.destroy(context)

uniqueArray = (items) ->
  results = []
  results = items.filter((elem, pos) ->
    items.indexOf(elem) is pos
  )
  results

action 'asistentes', ->
  keys = ['anfitriones', 'miembros_de_equipo', 'asistentes_frecuentes',
    'personas_por_primera_vez', 'nuevos_iglesia', 'otras_iglesias'
  ]
  compound.meg.cache.find {'model': 'Regsemanalgc', 'i': session.user.i}, (err, docs) ->
    res_nombres = []
    for doc in docs
      docCopy = JSON.parse(JSON.stringify(doc))
      for key in keys
        if docCopy[key] != ''
          nombres = docCopy[key]
          if not Array.isArray(nombres)
            splited = nombres.split(',')
            res_nombres = res_nombres.concat(splited)
    res_nombres = uniqueArray(res_nombres)
    nombres_dict = []
    for nombre in res_nombres
      nombres_dict.push({id:nombre,text:nombre})
    send nombres_dict

action 'asistencias_mensuales_gcs_total', ->
  params.i = session.user.i
  Regsemanalgc.asistenciasMensualesTotales params, (err, to_send) ->
    send to_send

action 'getTime', ->
  type = params.id
  types =
      esta_semana: Regsemanalgc.obtener
      semana_pasada: Regsemanalgc.obtener
      este_mes: Regsemanalgc.obtener
      mes_pasado: Regsemanalgc.obtener
      pasado: Regsemanalgc.obtener
  if type in Object.keys(types)
      Func = types[type]
      iglesiaId = session.user.i
      Func(iglesiaId, type, (err, docs) ->
        send docs
      )
  else
      send []

action 'getByGrupo', ->
  compound.meg.cache.all 'Regsemanalgc', (err, items) ->
    compound.meg.cache.find
      'model': 'Regsemanalgc'
      'grupo': params.id
      'i': session.user.i
    , (err, items) ->
      if req.query.hasOwnProperty('f')
        mask = require('json-mask')
        items = mask(items, req.query.f)
      send items