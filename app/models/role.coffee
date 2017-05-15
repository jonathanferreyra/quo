module.exports = (compound, Role) ->
  # define Role here
  node_cryptojs = require('node-cryptojs-aes')
  CryptoJS = node_cryptojs.CryptoJS
  _ = require('lodash')

  Role.validatesPresenceOf('name', {message: 'no puede ser un texto vacío'})

  # For more info of meta() view models/user.coffee file
  Role.meta = () ->
    return meta =
      model: 'role'
      url: 'roles'
      title: 'Rol'
      pluralTitle: 'Roles'
      attrText: 'name'
      typeRef:'hard'
      exportable:false
      attrs :
        name:
          text:'Nombre'
        description:
          text:'Descripción'
        raw_name:
          text:''
        permissions:
          text:'Permisos'
      references:
        linkBy:'json'
        attr:'roles'
        models:[
          'User'
        ]
      actions:
        include:[]
        exclude:[]
        ignore:['users','actions', 'setRole']
        ajax:['users','actions', 'setRole']

  Role.parseRawName = (value) ->
    # parse strings name like
    # 'Administrador' -> 'administrador'
    # 'Usuario de caja  ' -> 'usuario_de_caja'
    if value.length > 0
      value = value.toLowerCase()
      value = value.trim()
      while value.indexOf(' ') != -1
        value = value.replace(' ','_')
      return value
    ''

  Role.decrypt = (value) ->
    CryptoJS.AES.decrypt(value, 'c474f41b11').toString(CryptoJS.enc.Utf8)

  Role.encrypt = (value) ->
    CryptoJS.AES.encrypt(JSON.stringify(value), 'c474f41b11').toString()

  Role.customCreate = (new_data, cb) ->
    new_data.creation_date = new Date().toISOString()
    new_data.raw_name = Role.parseRawName(new_data.name)
    permissions = Role._parsePermissionsToSave(new_data.permissions)
    new_data.permissions = Role.encrypt(permissions)
    Role.create new_data, cb

  Role._parsePermissionsToSave = (perms) ->
    perms = JSON.parse(perms)
    for ctrl, actions of perms
      if actions.indexOf('create') != -1 and actions.indexOf('new') == -1
        actions.push('new')
      if actions.indexOf('update') != -1 and actions.indexOf('edit') == -1
        actions.push('edit')
    return JSON.stringify(perms)

  # retorna los usuarios que pertenecen al rol indicado
  # dentro de la iglesia indicada
  Role.getUsers = (roleId, identityId, cb) ->
    m = compound.models
    m.Iglesia.find identityId, (err, iglesia) ->
      users = {}
      if iglesia.users.length > 0
        users = JSON.parse(iglesia.users)
      userIds = []
      for userId, rolId of users
        if rolId == roleId
          userIds.push(userId)
      compound.async.map userIds, (userId, mapCb) ->
        m.User.find userId, mapCb
      , cb

  ###############################################################
  ### META INFO FOR GENERATE CONTROLLER ACTIONS
  ###############################################################

  Role._ctrlsExcludes = () ->
    # lista de controladores que seran ignorados
    # para aparecer en la seccion de crear un nuevo rol
    # :controladores a nivel core system
    return  [
      "base"
      "home"
      "application"
      "authorization"
      "login"
      "error"
      "useraccesses"
      "generic"
      "generic2"
      "timespans"
      "settings"
      "cuentas"
      "movimientos"
      "categorias"
      "seguimientopersonas"
      "reports"
      "site"
      "clients"
    ]

  Role._getAllNameControllers = () =>
    # Retorna una lista con los nombres en plural
    # de los controladores, ej: empleados, categorias
    excludes = Role._ctrlsExcludes()
    all = Object.keys(compound.structure.controllers)
    ctrls_names = []
    for ctrl in all
      if ctrl.indexOf('controller') != -1
        split_ctrl = ctrl.split('_')
        if excludes.indexOf(split_ctrl[0]) == -1
          ctrls_names.push split_ctrl[0]
    return ctrls_names

  Role._getExceptionsForController = () ->
    # Cada controlador puede contener reglas
    # extras fuera de las operaciones por defecto:
    # create,new,index,edit,update,show
    # => Este metodo lee la info meta de cada modelo
    # Return: {Object} dict de dict
    # Ej: key = name_controller, value = exclude,include actions
    # { pluralnamemodel: { exclude:[], include:[] } }
    exceptions = {}
    for model in Object.keys(compound.models)
      instanceModel = compound.models[model]
      if instanceModel.hasOwnProperty('meta')
        metaInfo = instanceModel.meta()
        if metaInfo.hasOwnProperty('actions')
          exceptions[metaInfo.url] = metaInfo.actions
    exceptions

  Role._getShowNameControllers = () ->
    # Lee de cada modelo.meta el nombre a mostrar
    # de cada controlador (Model.meta().pluralTitle)
    # Retorna un diccionario
    # { pluralcontroller: {single:'', plural:''}, ...}
    names = {}
    for model in Object.keys(compound.models)
      instanceModel = compound.models[model]
      if instanceModel.hasOwnProperty('meta')
        metaInfo = instanceModel.meta()
        names[metaInfo.url] =
          single: metaInfo.title.toLowerCase()
          plural: metaInfo.pluralTitle
    names

  Role._getActionsControllers = () ->
    actions =
      'create':'Agregar'
      'update':'Editar'
      'destroy':'Eliminar'
      'show':'Ver detalles de'
      'index':'Listar'
    names = Role._getShowNameControllers()
    keys_actions = Object.keys(actions)
    ctrls = Role._getAllNameControllers()
    exceptions = Role._getExceptionsForController()
    meta = {}
    for ctrl in ctrls
      # create a copy of <keys_actions>
      aux_keys_actions = _.clone(keys_actions)
      ctrl_actions = []
      to_include = []
      if exceptions.hasOwnProperty(ctrl)
        # remove all actions indicated to exclude
        to_exclude = exceptions[ctrl].exclude
        to_include = exceptions[ctrl].include
        if to_exclude.length > 0
          for action_exclude in to_exclude
            idx_element = aux_keys_actions.indexOf(action_exclude)
            if idx_element != -1
              delete aux_keys_actions[idx_element]
              aux_keys_actions = _.compact(aux_keys_actions)

      try
        for action in aux_keys_actions
          ctrl_actions.push({
            action: action,
            showName: actions[action] + ' ' + names[ctrl].single
          })
        if to_include.length > 0
          for action in to_include
            ctrl_actions.push action
        meta[ctrl] =
          'actions' : ctrl_actions
          'showName': names[ctrl].plural
          'rawName' : ctrl
      catch e
        throw new Error('Controller (' + ctrl + ') not found in list of controllers names')
    meta

  Role._getRawActionsControllers = () ->
    actions = {}
    all_ctrls = Role._getActionsControllers()
    for ctrl, data of all_ctrls
      ctrl_actions = []
      for action in data.actions
        ctrl_actions.push(action.action)
      actions[ctrl] = ctrl_actions
    actions

  Role._getActionsToIgnore = () ->
    actions = {}
    for model in Object.keys(compound.models)
      instanceModel = compound.models[model]
      if instanceModel.hasOwnProperty('meta')
        metaInfo = instanceModel.meta()
        if metaInfo.hasOwnProperty('actions')
          if metaInfo.actions.hasOwnProperty('ignore')
            if metaInfo.actions.ignore.length > 0
              actions[metaInfo.url] = metaInfo.actions.ignore
    actions

  Role._getActionsAjax = () ->
    actions = {}
    for model in Object.keys(compound.models)
      instanceModel = compound.models[model]
      if instanceModel.hasOwnProperty('meta')
        metaInfo = instanceModel.meta()
        if metaInfo.hasOwnProperty('actions')
          if metaInfo.actions.hasOwnProperty('ajax')
            if metaInfo.actions.ajax.length > 0
              actions[metaInfo.url] = metaInfo.actions.ajax
    actions