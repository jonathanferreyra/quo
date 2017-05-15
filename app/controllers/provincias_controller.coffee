load 'base'

generic = compound.meg.generic

before 'validate unique', (context) ->
  compound.meg.generic._validatesUniquenessOf context, 'name', () ->
    next()
, only: ['create', 'update']

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
        items = compound.meg.utils.removeMetaKeys(
          items, keys = [], include = ['lat','long'])
        if req.query.hasOwnProperty('q')
          _ = require('lodash')._
          try
            items = _.where(items, JSON.parse(req.query.q))
          catch SyntaxError
            context.send code:500, data: []
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          items = mask(items, req.query.f)
        context.send code: 200, data: items

      # cache only
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

action 'getLocalities', =>
  Provincia.getLocalities params.id, (err, items) ->
    send items