# VERSION : 1.5.0

exports.init = (compound) ->

  TAFFY = compound.taffy
  cache = {}
  cache.timeSpans = {}
  cache.dataset = TAFFY()
  # para aquellos modelos que tengan
  # la funcion all reimplementada
  allFuncExcepts = {}

  _getAllOfModelFromBD = (_model, cb) ->
    # IMPORTANTE: asegurarce de actualizar el timespan
    # antes de ejecutar esta funcion
    modelFn = _model
    allFn = 'all'
    if allFuncExcepts.hasOwnProperty(_model)
      modelFn = allFuncExcepts[_model].m
      allFn = allFuncExcepts[_model].fn
    if compound.models[modelFn] is undefined
      throw new Error('Model [' + _model + '] not exists or is not defined.')
    compound.models[modelFn][allFn] (err, items) ->
      cache.dataset().filter({ model:_model }).remove()
      _items = []
      for item in items
        _item = item.toObject()
        _item['model'] = _model
        _items.push(_item)
      cache.dataset.insert(_items)
      cb(err, items)

  _getTimeSpanFromBD = (model, cb) ->
    urlModel = compound.ctrlsMeta.modelByName[model]
    compound.models.Timespan.find urlModel + "TimeSpan", (err, docTS) ->
      if !err and docTS
        modelTS = docTS.v
        cache.timeSpans[model] = modelTS
        cb(err, modelTS)
      else
        toSave =
          id: urlModel + "TimeSpan"
          v: JSON.stringify(new Date().valueOf())
        compound.models.Timespan.create toSave, (err, docTS) =>
          modelTS = docTS.v
          cache.timeSpans[model] = modelTS
          cb(err, modelTS)

  # Recarga desde la BD el doc indicado
  cache.reloadItem = (docId, cb) ->
    # recarga desde la bd
    # actualiza los indices
    db = compound.orm._schemas[0].adapter.db
    db.get docId, (err, doc) ->
      cache.dataset( { id:docId } )
        .update(doc)
      cb(err, doc)

  # Recarga desde la BD el modelo indicado
  cache.reloadModel = (model, cb) ->
    _getTimeSpanFromBD model, (err, modelTS) ->
      _getAllOfModelFromBD model, (err, items) ->
        cb(err, items)

  # Recarga todos los modelos que estan en cache desde la BD
  cache.reloadAll = (cb) ->
    models = Object.keys(cache.timeSpans)
    compound.async.map models, (model, mapCallback) ->
      _getTimeSpanFromBD model, (err, modelTS) ->
        _getAllOfModelFromBD model, (err, items) ->
          mapCallback(err, null)
    , cb

  # Limpia la cache del modelo indicado
  cache.clearModel = (_model, cb) ->
    delete cache.timeSpans[_model]
    cache.dataset().filter({ model:_model }).remove()
    cb()

  # Retorna el TS actual que contiene el server en ram
  cache.getTimeSpan = (model, cb) ->
    currentTS = cache.timeSpans[model]
    _getTimeSpanFromBD model, (err, modelTS) ->
      # chequea que el ts actual del modelo
      # sea el mismo que el actual en la bd
      if currentTS == modelTS
        cb(null, currentTS)
      else
        _getAllOfModelFromBD model, (err, items) ->
          cb(null, cache.timeSpans[model])

  # Establece el TS indicado a un modelo
  cache.setTimeSpan = (model, value) ->
    if cache.timeSpans.hasOwnProperty(model)
      cache.timeSpans[model] = value
    else
      new Error('Model not exist in cache.')

  # Agrega un doc a la cache del server.
  cache.append = (model, doc, cb) ->
    # agrega el item al modelo
    doc['model'] = model
    cache.dataset.insert([doc])
    _getTimeSpanFromBD model, (err, modelTS) ->
      cb()

  # Quita de la cache el doc indicado
  cache.delete = (doc, cb) ->
    cache.dataset().filter({ id:doc.id }).remove()
    _getTimeSpanFromBD doc.model, (err, modelTS) ->
      cb()

  # Reemplaza un doc ya existente por el indicado
  cache.set = (doc, cb) ->
    cache.dataset({ id:doc.id }).update(doc)
    # actualiza el timespan
    _getTimeSpanFromBD doc.model, (err, modelTS) ->
      cb()

  # Retorna todos los docs de un modelo
  cache.all = (model, cb) ->
    currentTS = cache.timeSpans[model]
    _getTimeSpanFromBD model, (err, modelTS) ->
      # si el modelo no existe en la cache
      if not cache.timeSpans.hasOwnProperty(model)
        _getAllOfModelFromBD model, cb
      else
        if currentTS == modelTS
          # console.log 'cache.getAll... TS IGUALES'
          items = cache.dataset().filter({model:model}).get()
          cb(null, items)
        else
          # console.log 'cache.getAll... TS DIFERENTES'
          _getAllOfModelFromBD model, cb

  # Retorna el doc indicado
  cache.get = (id, cb) ->
    _get = (doc, cb) ->
      # refresca todo el modelo desde la bd
      _getAllOfModelFromBD doc.model, (err, items) ->
        item = cache.dataset().filter({ id:id }).first()
        cb(null, item)
    if id.length > 0
      # recupera el doc desde la BD
      db = compound.orm._schemas[0].adapter.db
      db.get id, (err, doc) ->
        if !err
          if doc.hasOwnProperty('model')
            currentTS = cache.timeSpans[doc.model]
            _getTimeSpanFromBD doc.model, (err, modelTS) ->
              # chequea que el ts actual del modelo
              # sea el mismo que el actual en la bd
              if currentTS == modelTS
                # chequea si el doc existe en la cache
                item = cache.dataset().filter({ id:id }).first()
                if item
                  cb(null, item)
                else
                  _get(doc, cb)
              else
                _get(doc, cb)
        else
          cb(err, doc)
    else
      cb(new Error('Document ID is not valid.'), null)

  cache.getRefId = (itemId, keyRef, cb=null) ->
    item = cache.dataset().filter({ id:itemId }).first()
    item = item[keyRef]
    if cb
      cb(null, item)
    else
      item

  cache.find = (query, cb=null) ->
    # query = dict
    res = cache.dataset().filter(query).get()
    if cb
      cb(null, res)
    else
      res

  cache.findOne = (query, cb=null) ->
    # query = dict
    res = cache.dataset().filter(query).first()
    if cb
      cb(null, res)
    else
      res

  # Obtiene un doc. Busca primero en cache y
  # si no lo encuentra lo trae desde la bd
  cache.getEver = (docId, cb) ->
    res = cache.dataset().filter({'id':docId}).first()
    if res is false
      db = compound.orm._schemas[0].adapter.db
      db.get docId, cb
    else
      cb(null, res)

  cache.count = (query, cb=null) ->
    # params
    # {Object} query con los criterios de busqueda
    if typeof query == 'string'
      query =
        model: query
    res = cache.dataset().filter(query).get().length
    if cb
      cb(null, res)
    else
      res

  ###################################################################

  # crea el namespace en compound para la cache
  if not compound.hasOwnProperty('meg')
    compound.meg = {}
  compound.meg.cache = cache