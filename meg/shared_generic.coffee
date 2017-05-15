exports.init = (compound) ->

  shared_generic = {}

  ###################################################################
  #### BASE METHODS
  ###################################################################

  shared_generic.index = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    context.respondTo (format) =>
      format.json =>
        cbFnAll = (err, items) ->
          if req.query.hasOwnProperty('q')
            TAFFY = compound.taffy
            db = TAFFY(items)
            try
              items = db().filter(JSON.parse(req.query.q)).get()
            catch SyntaxError
              context.send code:500, data: []
          if req.query.hasOwnProperty('f')
            mask = require('json-mask')
            items = mask(items, req.query.f)
          items = compound.meg.utils.removeMetaKeys(
            items, keys = [], include = ['sharedId'])
          context.send code: 200, data: items

        sharedId = context.req.session.user.sharedInfo
        if compound.app.settings.cache and Vars.cache
          compound.meg.cache.all Vars.Model, (err, allItems) ->
            _query =
              'model': Vars.Model
              'sharedId': sharedId
            compound.meg.cache.find(_query, cbFnAll)
        else
          Vars.classModel.all({where: {'sharedId': sharedId}}, cbFnAll)
      format.html =>
        params =
          title : Vars.titlemodel
          Vars : Vars
        context.render(params)

  ###################################################################
  #### HOOK METHODS
  ###################################################################

  shared_generic._parse_attrs_before_save = (context, cb) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    dataStore = req.body[Vars.Model]
    if not req.body.hasOwnProperty(Vars.Model)
      dataStore = req.body
    ####
    for k in ['nombre', 'apellido']
      if dataStore[k]
        if typeof dataStore[k] == 'string'
          dataStore[k] = compound.utils.camelize(dataStore[k], true).trim()

    dataStore.sharedId = context.req.session.user.sharedInfo
    cb()

  shared_generic._validate_security_data = (context, cb) ->
    req = context.req
    cache = compound.meg.cache
    format = if req.params.format == undefined then 'html' else 'json'

    notFound = () ->
      if format == 'html'
        context.redirect '/notFound'
      else if format == 'json'
        context.send code:404, error:'Not found'

    # valida que el doc a visualizar
    # corresponda con el cliente actual
    cache.get req.params.id, (err, item) ->
      if !err
        if item.sharedId == context.req.session.user.sharedInfo
          cb()
        else
          notFound()
      else
        notFound()

  ###################################################################
  #### UTILS METHODS
  ###################################################################

  # valida la unicidad de un elemento segun el attr indicado
  # dentro del contexto de sharedInfoId
  shared_generic._validatesUniquenessOf = (context, attr, cb) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req

    dataStore = req.body[nameModel]
    if not req.body.hasOwnProperty(nameModel)
      dataStore = req.body

    opts =
      model: nameModel
      attr: attr
      value: dataStore[attr]
      action: context.actionName
      identityAttr: 'sharedId'
      sharedId: context.req.session.user.sharedInfo
    compound.meg.utils.validatesUniquenessOf opts, (valid) ->
      if valid
        cb()
      else
        attr = compound.utils.camelize(attr, true)
        context.flash 'error', attr + ' debe ser único'
        params =
          Vars : Vars
        params.title = Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
        context.render('new', params)

  ###################################################################

  if not compound.hasOwnProperty('meg')
    compound.meg = {}
  compound.meg.shared_generic = shared_generic