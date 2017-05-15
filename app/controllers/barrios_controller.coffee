load 'base'

generic = compound.meg.generic

before 'normalize name', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  dataStore = req.body[nameModel]
  if not req.body.hasOwnProperty(nameModel)
    dataStore = req.body

  dataStore.name = compound.meg.utils.normalizeName(dataStore.name)
  next()
, only: ['create', 'update']

before 'validate unique', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  dataStore = req.body[nameModel]
  if not req.body.hasOwnProperty(nameModel)
    dataStore = req.body

  query =
    model:'Barrio'
    localidad: dataStore.localidad
    name: { 'isnocase': dataStore.name }
  compound.meg.cache.find query, (err, res) ->
    if res.length == 0
      next()
    else
      errMsg = 'Ya existe un barrio creado con el mismo nombre y localidad'
      context.respondTo (format) ->
        format.json ->
          context.send code: 500, error: errMsg
        format.html ->
          context.flash 'error', errMsg
          params =
            Vars : Vars
          params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
          context.render('new', params)
, only: ['create']

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
        items = compound.meg.utils.removeMetaKeys(
          items, keys = [], include = ['lat','long'])
        if req.query.hasOwnProperty('q')
          _ = require('lodash')._
          try
            items = _.where(items, JSON.parse(req.query.q))
          catch SyntaxError
            context.send code:500, data: []
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          items = mask(items, req.query.f)
        context.send code: 200, data: items
      # cache only
      compound.meg.cache.find({'model': Vars.Model}, cbFnAll)
    format.html =>
      params =
        title : Vars.titlemodel
        Vars : Vars
      context.render(params)

action 'show', (context) =>
  generic.show(context)

action 'show_json', (context) =>
  context.req.params.format = 'json'
  generic.show(context)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  generic.destroy(context)

action 'getMembers', =>
  Barrio.getMembers session.user.i, params.id, (err, items) ->
    items = compound.meg.utils.removeMetaKeys(items)
    send items