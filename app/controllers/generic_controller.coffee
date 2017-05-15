load 'base'

_g = compound.meg.generic

####

@_guid = _g.guid # UTIL FUNCTION TO CREATE DOC ID

@_new = _g.new

@_index = _g.index

@_create = _g.create

@_show = _g.show

@_edit = _g.edit

@_update = _g.update

@_destroy = _g.destroy

#####################################################################
#### HOOKS

action 'new', (context) =>
  @._new(context)

action 'create', (context) =>
  @._create(context)

action 'index', (context) =>
  @._index(context)

action 'show', (context) =>
  @._show(context)

action 'edit', (context) =>
  @._edit(context)

action 'update', (context) =>
  @._update(context)

action 'destroy', (context) =>
  @._destroy(context)