load 'base'

generic = compound.meg.generic

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
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  item = compound.ctrlsMeta.vars[nameModel]['instanciaModel']
  item.destroy (error) ->
    context.respondTo (format) ->
      format.json ->
        if error
          context.send code: 500, error: error
        else
          context.send code: 200
      format.html ->
        if error
          flash 'error', 'No se pudo eliminar '
        else
          flash 'info', 'Eliminado correctamente'
        context.send "'/tarjetabienvenidas/" + item.tarjeta_bienvenida + "'"