module.exports = (compound) ->
  app = compound.app
  compound.tools.database = ()->
    action = process.argv[3]
    switch action
      when 'migrate', 'update'
        perform action, process.exit
      else
        console.log 'Unknown action', action

  compound.tools.database.help =
    shortcut:    'db'
    usage:       'db [migrate|update]'
    description: 'Migrate or update database(s)'

  getUniqueSchemas = ()->
    schemas = []
    Object.keys(compound.models).forEach (modelName)->
      Model = compound.models[modelName]
      schema = Model.schema
      if !~schemas.indexOf(schema)
        schemas.push schema
    schemas

  perform = (action, callback)->
    wait = 0
    done = ()->
      if --wait == 0 then callback()

    console.log 'Perform', action, 'on'
    getUniqueSchemas().forEach (schema)->
      console.log ' - ' + schema.name
      if schema['auto' + action]
        wait += 1
        process.nextTick ->
          schema['auto' + action](done)

    if wait == 0
      done()
    else
      console.log wait

    return true

  deleteDocsModels = (name_models, callback) ->
    # models is a string separated by ',' the model names eg: 'modelA,modelB,modelC'
    name_models = name_models.split(',')
    compound.async.map name_models, ((modelName, mapCb) ->
      # capitalize string
      modelName = modelName.charAt(0).toUpperCase() + modelName.slice(1)
      Model = compound.models[modelName]
      Model.all (err, docs) ->
        compound.async.map docs, ((doc, mapCb2) =>
          doc.destroy (err) ->
            mapCb2(null, null)
        ), (err, results) ->
          console.log 'deleted -> ' + modelName + ' : ' + docs.length + ' docs'
          mapCb(null, null)
    ), (err, results) ->
      console.log 'deleteDocsModels OK!'
      callback()

  deleteViewsAll = (callback) ->
    models = Object.keys(compound.models)
    db = app.compound.orm._schemas[0].adapter.db
    compound.async.map models, ((modelName, mapCb) ->
      ide = "_design/" + modelName.toLowerCase()
      db.get ide, (err, doc) ->
        if doc
          db.destroy ide, doc._rev, (err, body) ->
        mapCb(null, null)
    ), (err, results) ->
      console.log 'deleteViewsAll OK!'
      callback()

  createViewsAll = (callback) ->
    deleteViewsAll () ->
      models = Object.keys(compound.models)
      db = app.compound.orm._schemas[0].adapter.db
      compound.async.map models, ((modelName, mapCb) ->
        design = views:
          view_all:
            map: "function (doc) { if (doc.model == '"+ modelName+"') emit(doc._id, doc); }"

        db.insert design, "_design/" + modelName.toLowerCase(), (err, doc) ->
          if err
            console.log 'ERROR to create view ['+modelName+'] : '+ err.reason
          mapCb(null, modelName)

      ), (err, results) ->
        console.log 'createViewsAll OK!'
        callback()

  createCustomView = () ->
    #
    # DEFINE HERE YOUR CUSTOM VIEWS
    #
    # {
    #   model:'Model'
    #   viewName:'view_name'
    #   map:"function(doc) {
    #   }
    #   "
    # }
    custom_views = [
    ]
    ############################################################################

    db = app.compound.orm._schemas[0].adapter.db
    compound.async.map custom_views, ((custom_view, mapCb) ->
      Model = compound.models[custom_view['model']]
      ide = "_design/" + custom_view['model'].toLowerCase()
      db.get ide, (err, view_doc) ->
        views = view_doc.views
        views[custom_view['viewName']] =
          map: custom_view['map']
        to_update =
          views: views
          _rev : view_doc._rev
        db.insert to_update, view_doc._id, (err, doc) ->
          if !err
            mapCb(err, doc)
          else
            console.log err

    ), (err, results) ->
      if !err
        console.log 'createCustomView OK!'
      else
        console.log 'createCustomView ERROR!'

  if compound.app.compound.orm._schemas[0].name isnt 'memory'
    if app.settings.recreateViews
      createViewsAll () ->