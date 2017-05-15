exports.init = (compound) ->

  utils = {}

  # Busca los doc referencias y los agrega al documento actual
  # USO:
  # myDoc = { "_id": "999","nombre": "Apostoles","cp": "3350",
  #   "provincia": "123","model": "Localidad"}
  # >> fillReferenceFields myDoc, ['provincia'], true, cb
  # RESULT:
  # >> { "_id": "999","nombre": "Apostoles","cp": "3350",
  #   "provincia": {"_id": "123","nombre": "Misiones","model": "Provincia"}
  #   ,"model": "Localidad"}
  utils.fillReferenceFields = (docItem, attrs, cache=true, cb) ->
    if docItem.hasOwnProperty('toObject')
      docItem = docItem.toObject()
    refs = {}
    compound.async.each attrs, (attr, callback) =>
      cbFn = (err, item, _callback) ->
        if !err and item
          if item.hasOwnProperty('toObject')
            item = item.toObject()
          refs[attr] = item
        _callback()

      if cache
        compound.meg.cache.get docItem[attr], (err, itemRef) ->
          cbFn err, itemRef, callback
      else
        db = compound.orm._schemas[0].adapter.db
        db.get docItem[attr], (err, itemRef) ->
          cbFn err, itemRef, callback
    , (err, res) ->
      for k, v of refs
        docItem[k] = v
      cb(err, docItem)

  # retorna una lista con los attributos referencia
  # de un modelo, especificados en la funcion meta()
  utils.getReferenceAttrsOfModel = (nameModel, cb) ->
    attrs = []
    if compound.models[nameModel].hasOwnProperty('meta')
      metaInfo = compound.models[nameModel].meta()
      if metaInfo.hasOwnProperty('attrs')
        for k, v of metaInfo.attrs
          if Object.keys(v).indexOf('ref') != -1
            attrs.push(k)
    cb(null, attrs)

  utils.removeMetaKeys = (docs, keys=[], include=[], omit=[]) ->
    if keys.length == 0
      keys = ['_rev', 'i', 'c', 'user', 'creation_date',
        '___id','___s','model']
    if include.length > 0
      keys = keys.concat(include)
    _docs = []
    for doc in docs
      _doc = JSON.parse(JSON.stringify(doc))
      for k in keys
        if _doc.hasOwnProperty(k) || _doc[k]
          if k not in omit
            delete _doc[k]
      _docs.push(_doc)
    _docs

  # valida que un attributo sea unico
  # dentro de un modelo para un iglesia
  #opts =
  #  model : nombre del modelo
  #  attr: nombre atributo
  #  value: el valor a validar
  #  action : create | update
  #  iglesiaId :
  utils.validatesUniquenessOf = (opts, cb) ->
    valid = false
    query =
      'model': opts.model
    query[opts.identityAttr] = opts[opts.identityAttr]
    value = {}
    value['leftnocase'] = opts.value
    query[opts.attr] = value
    items = compound.meg.cache.dataset().filter(query).get()
    if items.length == 0
      valid = true
    else
      if opts.action == 'create'
        valid = false
      else if opts.action == 'update'
        valid = true
    cb(valid)

  # retorna un string en formato capitalize
  # para cada palabra incluida en el string
  # Ej: JUANA DE LAS CASTAÑAS -> Juana de las Castañas
  utils.normalizeName = (value) ->
    words = value.split(' ')
    newWord = []
    for w in words
      w = compound.utils.camelize(w, true).trim()
      if w.toLowerCase() in ['de','del']
        w = w.toLowerCase()
      newWord.push(w)
    return newWord.join(' ')

  ###################################################################

  if not compound.hasOwnProperty('meg')
    compound.meg = {}
  compound.meg.utils = utils