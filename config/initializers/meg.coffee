module.exports = (compound) ->

  if not compound.hasOwnProperty('meg')
    compound.meg = {}

  ########################################################

  # variables usadas por las funciones de meg.cache:
  # _getTimeSpanFromBD , all
  compound.ctrlsMeta = {}
  compound.ctrlsMeta.modelByName = {}

  models = Object.keys(compound.models)
  for m in models
    model = compound.models[m]
    if model.hasOwnProperty('meta')
      compound.ctrlsMeta.modelByName[m] = model.meta()['url']

  compound.ctrlsMeta.modelByUrls = {}
  for name, url of compound.ctrlsMeta.modelByName
    compound.ctrlsMeta.modelByUrls[url] = name

  ########################################################
  #### CREATE VARS FOR EACH MODEL

  compound.ctrlsMeta.vars = {}

  # indicar aqui a que subsistema pertenece el modelo
  subsections =
    'Grupos':['Grupocrecimiento','Regsemanalgc']
    'Membresía':['Miembro','Ministerio','Familia',
      'Tarjetabienvenida','Evento']
    'Tablas básicas':['Estadocivil','Estadomembresia','Clasificacionsocial']
    'Datos regionales':['Pais','Provincia','Localidad','Barrio']
    'Administración':['User','Role']
  idx_subsections = {}
  for _name, _models of subsections
    for _model in _models
      idx_subsections[_model] = _name
  keys_subsections = Object.keys(idx_subsections)

  # indicar aqui si el modelo es femenino
  letraGenero_a = ['Familia','Localidad','Provincia',
    'Tarjetabienvenida','Clasificacionsocial']

  for m in models
    model = compound.models[m]
    if model.hasOwnProperty('meta')
      metaInfo = model.meta()
      if not metaInfo.hasOwnProperty('model')
        throw new Error('Model ['+m+'] is not defined meta().model attribute')
      myModelvars = {}
      myModelvars.model = metaInfo.model
      myModelvars.Model = metaInfo.model.charAt(0).toUpperCase() + metaInfo.model.slice(1)
      myModelvars.pluralmodel = metaInfo.url
      myModelvars.classModel = compound.models[myModelvars.Model]
      myModelvars.titlemodel = metaInfo.pluralTitle
      myModelvars.singleTitleModel = metaInfo.title
      myModelvars.letraGenero = if letraGenero_a.indexOf(m) != -1 then 'a' else 'o'
      myModelvars.subsection = if keys_subsections.indexOf(m) != -1 then idx_subsections[m] else ''
      myModelvars.cache = if metaInfo.hasOwnProperty('cache') then metaInfo.cache else true
      myModelvars.refsDelListed = false
      myModelvars.isExportable = if metaInfo.hasOwnProperty('exportable') then metaInfo.exportable else true
      myModelvars.useIdentity = if metaInfo.hasOwnProperty('useIdentity') then metaInfo.useIdentity else true
      myModelvars.redirectToIndexBeforeCreate = if metaInfo.hasOwnProperty('redirectToIndexBeforeCreate') then metaInfo.redirectToIndexBeforeCreate else false
      compound.ctrlsMeta.vars[m] = myModelvars

  console.log '>>> Model Vars are loaded...'

  ########################################################

  cache = require('../../meg/cache')
  cache.init(compound)
  utils = require('../../meg/utils')
  utils.init(compound)

  generic = require('../../meg/generic')
  generic.init(compound)
  shared_generic = require('../../meg/shared_generic')
  shared_generic.init(compound)

  app = compound.app

  if app.compound.orm._schemas[0].name == 'memory'
    app.settings.cache = false
