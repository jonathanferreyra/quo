load 'base'

generic = compound.meg.generic

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
          items, keys = [], include = ['lat','long'])
        context.send code: 200, data: items

      # cache only
      if req.query['force']
        compound.meg.cache.find({'model': Vars.Model}, cbFnAll)
      else
        hasProvincia = true
        if Object.keys(req.query).length == 0
          hasProvincia = false
        else
          try
            query = JSON.parse(req.query.q)
            hasProvincia = query.hasOwnProperty('provincia')
          catch SyntaxError
            hasProvincia = false

        if not hasProvincia
          context.send code:500, data: [], err: "param <provincia> is required"
        else
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

action 'getBarrios', =>
  Localidad.barrios req.params.id, (err, items) ->
    items = compound.meg.utils.removeMetaKeys(items)
    send items