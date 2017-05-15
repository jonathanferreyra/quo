exports.init = (compound) ->

  generic = {}

  ###################################################################
  #### BASE METHODS
  ###################################################################

  generic.guid = (->
    s4 = ->
      Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
    ->
      s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4()
  )()

  generic.new = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    # set var instanciaModel
    compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = new Vars.classModel
    params =
      title : Vars.singleTitleModel + ' - Nuev' + Vars.letraGenero
      Vars : Vars
    context.render(params)

  generic.index = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    context.respondTo (format) =>
      format.json =>
        cbFnAll = (err, items) ->
          # filter items by query
          if req.query.hasOwnProperty('q')
            TAFFY = compound.taffy
            db = TAFFY(items)
            try
              items = db().filter(JSON.parse(req.query.q)).get()
            catch SyntaxError
              context.send code:500, data: []
          # filter attrs of the items
          if req.query.hasOwnProperty('f')
            mask = require('json-mask')
            items = mask(items, req.query.f)
          # remove keys like: creation_date, i, _rev, etc
          items = compound.meg.utils.removeMetaKeys(items)
          context.send code: 200, data: items

        identityId = context.req.session.user.i
        if compound.app.settings.cache and Vars.cache
          compound.meg.cache.all Vars.Model, (err, allItems) ->
            _query =
              'model': Vars.Model
            if Vars.useIdentity
              _query['i'] = identityId
            compound.meg.cache.find(_query, cbFnAll)
        else
          if Vars.useIdentity
            Vars.classModel.all({where: {'i': identityId}}, cbFnAll)
          else
            Vars.classModel.all(cbFnAll)
      format.html =>
        params =
          title : Vars.titlemodel
          Vars : Vars
        context.render(params)

  generic.create = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    dataStore = req.body[Vars.Model]
    if not req.body.hasOwnProperty(Vars.Model)
      dataStore = req.body
    if dataStore.hasOwnProperty('authenticity_token')
      delete dataStore['authenticity_token']

    if compound.app.compound.orm._schemas[0].name == 'memory'
      dataStore._id = generic.guid()

    console.log ':)'
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
              if Vars.redirectToIndexBeforeCreate
                context.redirect '/' + Vars.pluralmodel
              else
                context.redirect '/' + Vars.pluralmodel + '/' + item.id

  generic.show = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req

    context.respondTo (format) =>
      format.json =>
        compound.meg.cache.getEver req.params.id, (err, item) =>
          if err || !item
            context.send code: 404, error: 'Not found'
          else
            compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
            item = compound.meg.utils.removeMetaKeys([item])[0]
            if req.query.hasOwnProperty('f')
              mask = require('json-mask')
              item = mask(item, req.query.f)
            context.send code: 200, data: item
      format.html =>
        params =
          title : generic._get_showname_item(nameModel) + Vars.singleTitleModel + ' - Detalles'
          Vars : Vars
        context.render(params)

  generic.edit = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req

    context.respondTo (format) =>
      format.json =>
        compound.meg.cache.getEver req.params.id, (err, item) =>
          if err || !item
            if !err && !item && params.format == 'json'
              context.send code: 404, error: 'Not found'
          else
            item = compound.meg.utils.removeMetaKeys([item])[0]
            context.send code: 200, data: item
      format.html =>
        params =
          title : generic._get_showname_item(nameModel) + Vars.singleTitleModel + ' - Editar'
          Vars : Vars
        context.render(params)

  generic.update = (context) =>
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
            context.redirect Vars.instanciaRoute
          else
            context.flash 'error', 'No pudo ser actualizado'
            params =
              title : Vars.singleTitleModel + ' - Editar'
              Vars : Vars
            context.render('edit', params)

  generic.destroy = (context) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']
    item.destroy (error) =>
      if !error
        compound.models.Timespan.refreshCacheAfterDestroy(
          context.controllerName, Vars.Model, item)
      context.respondTo (format) =>
        format.json =>
          if error
            context.send code: 500, error: error
          else
            context.send code: 200
        format.html =>
          if error
            context.flash 'error', 'No se pudo eliminar '
          else
            context.flash 'info', 'Eliminado correctamente'
      context.send "'/" + Vars.pluralmodel + "'"

  ###################################################################
  #### HOOK METHODS
  ###################################################################

  generic._load_item = (context, callback) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    cbFnGetItem = (err, item, cb) =>
      if err || !item
        #if !err && !item && req.params.format == 'json'
        #  context.send code: 404, error: 'Not found'
        context.redirect Vars.pluralmodel
      else
        ctrl = context.controllerName
        nameModel = compound.ctrlsMeta.modelByUrls[ctrl]
        compound.ctrlsMeta.vars[nameModel]['instanciaModel'] = item
        compound.ctrlsMeta.vars[nameModel]['instanciaRoute'] = Vars.pluralmodel + "/" + item["id"]
        cb(err, item)

    if compound.app.settings.cache and Vars.cache
      compound.meg.cache.getEver req.params.id, (err, item) ->
        if typeof item is 'undefined'
          Vars.classModel.find req.params.id, callback
        else
          cbFnGetItem err, item, callback
    else
      Vars.classModel.find req.params.id, (err, item) ->
        cbFnGetItem err, item, callback

  generic._load_live_item = (context, cb) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req
    Vars.classModel.find req.params.id, (err, item) =>
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

  generic._parse_attrs_before_save = (context, cb) =>
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
          dataStore[k] = compound.utils.camelize(dataStore[k].toLowerCase(), true).trim()

    # setea el attr iglesiaId
    if Vars.useIdentity
      dataStore.i = context.req.session.user.i
    cb()

  ###################################################################
  #### UTILS METHODS
  ###################################################################

  generic._add_attrs_metadata = (context, cb) =>
    nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
    Vars = compound.ctrlsMeta.vars[nameModel]
    req = context.req

    dataStore = req.body[Vars.Model]
    if not req.body.hasOwnProperty(Vars.Model)
      dataStore = req.body
    ####
    dataStore.creation_date = new Date().toISOString()
    dataStore.user = context.req.session.user.id
    # setea el attr identityId
    if Vars.useIdentity
      dataStore.i = context.req.session.user.i
    cb()

  generic._get_showname_item = (nameModel) =>
    Vars = compound.ctrlsMeta.vars[nameModel]
    text = ''
    item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']
    if Vars.classModel.hasOwnProperty('meta')
      metaInfo = Vars.classModel.meta()
      show_attrs = metaInfo.attrText
      errMessage = 'Attribute <' + show_attrs + '> is not defined in model <' + nameModel + '>'
      if typeof show_attrs == 'string'
        if item[show_attrs]
          text = item[show_attrs]
        else
          throw new Error(errMessage)
      else if typeof show_attrs == 'object'
        for k in show_attrs
          if item[k]
            text += item[k] + ' '
          else
            throw new Error(errMessage)
    if text.length > 0
      text += ' - '
    text

  # valida la unicidad de un elemento segun el attr indicado
  # dentro del contexto de identityId
  generic._validatesUniquenessOf = (context, attr, cb) =>
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
      identityAttr: 'i'
      'i': context.req.session.user.i
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
  compound.meg.generic = generic