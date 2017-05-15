load 'base'

generic = compound.meg.generic
shared_generic = compound.meg.shared_generic

before 'set shared id', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  dataStore = req.body[Vars.Model]
  if not req.body.hasOwnProperty(Vars.Model)
    dataStore = req.body
  dataStore.sharedId = session.user.sharedInfo
  next()
, only: ['create']

before 'validate security data', (context) ->
  shared_generic._validate_security_data context, () ->
    next()
, only: ['show']

before 'validate unique', (context) ->
  compound.meg.shared_generic._validatesUniquenessOf context, 'nombre', () ->
    next()
, only: ['create', 'update']

action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  generic.create(context)

action 'index', (context) =>
  shared_generic.index(context)

action 'show', (context) =>
  generic.show(context)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  generic.destroy(context)
  
action 'getMembers', =>
  Clasificacionsocial.getMembers session.user.i, req.params.id, (err, items) ->
    if req.query.hasOwnProperty('f')
      mask = require('json-mask')
      items = mask(items, req.query.f)
    items = compound.meg.utils.removeMetaKeys(items)
    send items