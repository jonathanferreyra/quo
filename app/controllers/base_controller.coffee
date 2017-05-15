load 'application'

before(use('authorize'))

_g = compound.meg.generic

#####################################################################

@_load_item = _g._load_item

@_load_live_item = _g._load_live_item

@_add_attrs_metadata = _g._add_attrs_metadata

@_parse_attrs_before_save = _g._parse_attrs_before_save

@_parse_attrs_before_update = (context, cb) =>
  _g._parse_attrs_before_save(context, cb)

@_get_showname_item = _g._get_showname_item

#####################################################################

@_fillReferencesData = (Vars, itemId, cb) =>
  #si existe funcion meta en model
  #  si tiene models referencia
  #  por cada model
  #    obtiene los items
  #    quita la referencia de cada uno
  #  continua

  # comprueba que exista la funcion meta
  if Vars.classModel.hasOwnProperty('meta')
    metaInfo = Vars.classModel.meta()
    refs = metaInfo.references
    if refs.hasOwnProperty('models')
      # si posee modelos al que referencia
      if refs.models.length > 0
        referencesData = {}
        referencesData.models = []
        referencesData.count = 0
        referencesData.type = metaInfo.typeRef
        referencesData.itemId = itemId
        # por cada modelo, busca las referencias
        compound.async.map refs.models, (refModel, mapCb) =>

          @._getItemsByType refs, refModel, itemId, (err, items) =>
            if items.length > 0
              # busca la info del modelo referencia
              # ASUME QUE EXISTE LA FUNCION META
              refModelMeta = compound.models[refModel].meta()

              # guarda en esta variable auxiliar
              # las referencias encontradas
              referencesData.models.push({
                model:refModel
                url: refModelMeta.url
                pluralTitle: refModelMeta.pluralTitle
                items: items
                attrText:refModelMeta.attrText
              })
              referencesData.count += items.length
            mapCb(err, items)
        , (err, data) ->
          cb(null, referencesData)
      else
        next() # go to destroy
    else
      next() # go to destroy
  else
    next() # go to destroy

@_getItemsByType = (refs, refModel, itemId, cb) =>
  _attr = refs.attr
  _linkBy = refs.linkBy
  if refs.hasOwnProperty('excepts')
    if refs.excepts.hasOwnProperty(refModel)
      if refs.excepts[refModel].attr
        _attr = refs.excepts[refModel].attr
      if refs.excepts[refModel].linkBy
        _linkBy = refs.excepts[refModel].linkBy

  if _linkBy == 'id'
    query = {}
    query[_attr] = itemId

    Vars = compound.ctrlsMeta.vars[refModel]
    if Vars.useIdentity
      query['i'] = session.user.i
    compound.models[refModel].all where: query, cb
  else if _linkBy == 'json'
    matched = []
    compound.models[refModel].all where: 'i':session.user.i, (err, items) ->
      if !err
        for item in items
          if item[_attr]
            if item[_attr].indexOf(itemId) != -1
              matched.push(item)
        cb(err, matched)
      else
        cb(err, items)

@_dereferenceByTypeRef = (metaInfo, referencesData, refModel, cb) =>
  _async = compound.async
  attr = metaInfo.references.attr
  # for cada item del modelo referencia
  referenceType = metaInfo.references.linkBy
  _async.map refModel.items, (itemRef, mapCbItem) =>
    if referenceType == 'id'
      itemRef.updateAttribute attr, '', () ->
        compound.models.Timespan.refreshCacheAfterUpdate(
          refModel.url, refModel.model, itemRef)
        mapCbItem(null,  null)

    else if referenceType == 'json'
      json_content = JSON.parse(itemRef[attr])
      json_type = metaInfo.references.jsonType
      if json_type == 'array_dict'
        current = 0
        # busca el elemento con el id itemId y lo elimina
        for item in json_content
          # obtiene los valores del item
          values = []
          for k,v of item
            values.push(v)
          # busca si itemId se encuentra en alguno de los valores
          if values.indexOf(referencesData.itemId) != -1
            # borra el elemento del contenido del json
            json_content.splice(current, 1)
            break
          current += 1

      else if json_type == 'array'
        index = json_content.indexOf(referencesData.itemId)
        if index > -1
          json_content.splice(current, 1)

      else if json_type == 'dict'
        for k, v in json_content
          if v == referencesData.itemId
            v = ''
            break
      json_content = JSON.stringify(json_content)
      itemRef.updateAttribute attr, json_content, mapCbItem
  , cb

@_deleteWithReferences = (Vars, referencesData, cb) =>
  _async = compound.async
  # quita las referencias al item actual
  # Accion segun tipo:
  # - full: elimina el elemento pero mantiene sus referencias
  # - soft: elimina el elemento y quita sus referencias
  # - hard: no permite eliminar el elemento ni sus referencias
  metaInfo = Vars.classModel.meta()
  valueTimeSpan = new Date().valueOf()
  # for cada modelo referencia
  _async.map referencesData.models, (refModel, mapCbModel) =>
    if metaInfo.typeRef == 'soft'
      @._dereferenceByTypeRef metaInfo, referencesData, refModel, () =>
        compound.models.Timespan.updateTS Vars.pluralmodel, valueTimeSpan, mapCbModel
  , (err, res) =>
    Vars.instanciaModel.destroy () -> # elimina el item
      compound.models.Timespan.refreshCacheAfterDestroy(
        Vars.pluralmodel, Vars.Model, Vars.instanciaModel)
      cb()

@_getItem = (Vars, cb) =>
  try
    try
      item = Vars.instanciaModel.toObject()
    catch e
      item = Vars.instanciaModel
    if req.query.hasOwnProperty('f')
      mask = require('json-mask')
      item = mask(item, req.query.f)
    delete item['_rev']
    if Vars.classModel.hasOwnProperty('meta')
      metaInfo = Vars.classModel.meta()
      item['__attrText'] = metaInfo.attrText
    cb(null, item)
  catch TypeError
    cb(null, {})

#####################################################################
#### HOOKS

before 'load global vars', =>
  @user = session.user
  @enviroment = app.get 'env'
  #if app.get('env') == 'development'
  # if not res.locals.hasOwnProperty('clients')
  #   compound.models.User.getUsersAccountOwner (err, items) ->
  #     res.locals['clients'] = items
  #     next()
  # else
  next()
  #else
  #    next()

before 'validations', (context) ->
  cache = compound.meg.cache
  format = if params.format == undefined then 'html' else 'json'
  ctrl = controllerName
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]

  notFound = () ->
    if format == 'html'
      redirect '/notFound'
    else if format == 'json'
      send code:404, error:'Not found'

  if ctrl in ['roles', 'clients','users',
    'clasificacionsocials','estadomembresias','estadosciviles',
    'paises','provincias','localidades','barrios'] # superadmin & shared ctrls
    next()
  else
    # valida que el doc a visualizar
    # corresponda con el identityId actual
    cache.get params.id, (err, item) ->
      if !err
        if Vars.useIdentity
          if item.i == session.user.i
            next()
          else
            notFound()
        else
          next()
      else
        notFound()
, only: ['show']

before 'load item', (context) =>
  @._load_item context, (err, item) =>
    next()
, only: ['show']

before 'load live item', (context) =>
  @._load_live_item context, () ->
    next()
, only: ['edit', 'update', 'destroy']

before 'add attrs metadata', (context) =>
  @._add_attrs_metadata context, () =>
    next()
, only: ['create']

before 'parse attrs before save', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  # set iglesia id
  if Vars.useIdentity
    dataStore['i'] = session.user.i
  @._parse_attrs_before_save context, () =>
    next()
, only: ['create']

before 'parse attrs before update', (context) =>
  @._parse_attrs_before_update context, () =>
    next()
, only: ['update']

before 'check references item', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]

  if app.settings.deleteByReference
    @._fillReferencesData Vars, context.req.params.id , (err, referencesData) =>
      if referencesData.count == 0
        next()
      else
        if referencesData.type in ['hard', 'soft']
          if Vars.refsDelListed and referencesData.type == 'soft'
            @._deleteWithReferences Vars, referencesData, () =>
              compound.ctrlsMeta.vars[Vars.Model]['refsDelListed'] = false
              context.send "'" + '/' + Vars.pluralmodel + "'"
          else
            compound.ctrlsMeta.vars[Vars.Model]['refsDelListed'] = true
            context.send "'" + '/' + Vars.pluralmodel + '/dependences/' + context.req.params.id + "'"
        else if referencesData.type == 'full'
          next()
  else
    next()
, only: ['destroy']

action 'dependences', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  params =
    Vars : Vars
    title : Vars.singleTitleModel + ' - Dependencias'
  context.render('../includes/dependences', params)

action 'getDependences', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]

  @._fillReferencesData Vars, context.req.params.id, (err, referencesData) =>
    context.send referencesData

# Retorna el item/doc accedido una vez
# ejecutadas las actions: edit, show
action 'getItem', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  @._getItem Vars, (err, item) ->
    context.send item

action 'metaFields', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  if compound.models[nameModel].hasOwnProperty('meta')
    send compound.models[nameModel].meta().attrs
  else
    send {}