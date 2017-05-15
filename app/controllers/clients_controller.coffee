load 'base'

generic = compound.meg.generic

before 'check owner', ->
  if session.user.owner
    next()
  else
    redirect '/'

action 'new', (context) ->
  generic.new(context)

action 'create', (context) ->
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

  compound.models.User.createNewAccount dataStore, (err, item) =>
    if !err
      compound.models.Timespan.refreshCacheAfterCreate(
        'users', 'User', item)
    compound.ctrlsMeta.vars['User']['instanciaModel'] = item

    context.respondTo (format) =>
      format.json ->
        if err
          context.send code: 500, error: item.errors || err
        else
          context.send code: 200, data: item.toObject()
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
            context.redirect '/' + Vars.pluralmodel + '/' + item.id

action 'index', (context) ->
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req
  context.respondTo (format) =>
    format.json =>
      cbFnAll = (err, items) ->
        items = compound.meg.utils.removeMetaKeys(items)
        if req.query.hasOwnProperty('f')
          mask = require('json-mask')
          items = mask(items, req.query.f)
        context.send code: 200, data: items

      compound.models.User.getUsersAccountOwner(cbFnAll)

    format.html =>
      params =
        title : Vars.titlemodel
        Vars : Vars
      context.render(params)

action 'show', (context) =>
  nameModel = compound.ctrlsMeta.modelByUrls[context.controllerName]
  Vars = compound.ctrlsMeta.vars[nameModel]
  req = context.req

  context.respondTo (format) =>
    format.json =>
      compound.models.User.find req.params.id, (err, item) =>
        if err || !item
          if !err && !item && req.params.format == 'json'
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
      m = compound.models
      m.User.find Vars.instanciaModel.id, (err, userDoc) ->
        m.User.getIglesia userDoc, (err, iglesia) ->
          m.Accountinfo.findOne where: 'user': userDoc.id, (err, account) ->
            params.iglesia = iglesia
            params.item = userDoc
            params.account = account
            context.render(params)

action 'edit', (context) =>
  generic.edit(context)

action 'update', (context) =>
  generic.update(context)

action 'destroy', (context) =>
  generic.destroy(context)

action 'updateChurch', (context) =>
  compound.models.Iglesia.find params.id, (err, iglesia) ->
    dataStore = req.body['Iglesia']
    iglesia.updateAttributes dataStore, (err) =>
      context.respondTo (format) =>
        format.html =>
          ownerId = JSON.parse(iglesia.owners)[0]
          if !err
            context.flash 'info', 'Cambios guardados correctamente'
            context.redirect '/clients/' + ownerId
          else
            context.flash 'error', 'No se pudieron guardar los cambios'
            context.redirect '/clients/' + ownerId

action 'updateUser', (context) =>
  compound.models.User.find params.id, (err, item) ->
    dataStore = req.body['User']
    item.updateAttributes dataStore, (err) =>
      context.respondTo (format) =>
        format.html =>
          ownerId = item.id
          if !err
            context.flash 'info', 'Cambios guardados correctamente'
            context.redirect '/clients/' + ownerId
          else
            context.flash 'error', 'No se pudieron guardar los cambios'
            context.redirect '/clients/' + ownerId

action 'updateAccount', (context) =>
  compound.models.Accountinfo.find params.id, (err, item) ->
    dataStore = req.body['Accountinfo']
    item.updateAttributes dataStore, (err) =>
      context.respondTo (format) =>
        format.html =>
          ownerId = item.user
          if !err
            context.flash 'info', 'Cambios guardados correctamente'
            context.redirect '/clients/' + ownerId
          else
            context.flash 'error', 'No se pudieron guardar los cambios'
            context.redirect '/clients/' + ownerId

action 'getUser', ->
  compound.models.User.find params.id, (err, item) ->
    send item

###########################################################################

action 'dash', ->
  c = compound.meg.cache
  @title = 'Dashboard'

  values = {}
  models = ['User','Miembro','Iglesia','Accountinfo']
  compound.async.each models, (model, cb) ->
    compound.meg.cache.all model, (err, items) ->
      values[model.toLowerCase()] = items.length
      cb()
  , (err) ->
    @values = values
    render()

action 'refreshModelInCache', ->
  try
    nameModel = compound.ctrlsMeta.modelByUrls[req.body.ctrl]
    compound.meg.cache.reloadModel nameModel, (err, res) ->
      send res:true
  catch error
    send res:false
