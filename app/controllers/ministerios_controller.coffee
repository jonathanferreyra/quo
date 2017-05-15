load 'base'

generic = compound.meg.generic

before 'validate unique', (context) ->
  compound.meg.generic._validatesUniquenessOf context, 'nombre', () ->
    next()
, only: ['create', 'update']

action 'new', (context) =>
  generic.new(context)

action 'create', (context) =>
  generic.create(context)

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

action 'getMembers', =>
  iId = session.user.i
  Ministerio.getMembers iId, req.params.id, (err, items) ->
    send items