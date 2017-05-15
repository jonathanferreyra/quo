before "initChecks", (_req)->
  actn = _req.actionName
  ctrl = _req.controllerName

  if app.settings.isMaintenance # si se encuentra en mantenimiento
    # cualquier otro controlador que se quiera ejecutar
    # redireccionara a / indefectiblemente
    if ctrl not in ['site', 'home']
      redirect '/'
    else
      if (ctrl == 'home' and actn == 'index') or (ctrl == 'site')
        next()
      else
        # si no es ninguna de las condiciones anteriores
        # redireccionara a la pagina de mantenimiento
        redirect '/'
  else
    next()

before "initializeAuthorization", ->
  @loggedIn = (if (session.user) then true else false)
  acl = compound.acomplish.acl or false
  @cacheRoles = false
  @cacheAbilities = false
  return next()  unless acl
  @systemRoles = compound.acomplish.acl.roles or []
  if acl.settings
    @cacheRoles = (if (acl.settings.cacheRoles) then true else false)
    @cacheAbilities = (if (acl.settings.cacheAbilities) then true else false)
  next()

#
# Verifies that a user has the permission to perform a
# certain action on a certain controller.
#
# @param {Object} req (Compound) Request object.
#
authorize = (req) =>
  format = if req.params.format == undefined then 'html' else 'json'
  reject = () =>
    if format == 'html'
      redirect "/unauthorized"
    else if format == 'json'
      send code: 403, error: "Forbidden"
  notFound = () ->
    if format == 'html'
      redirect '/notFound'
    else if format == 'json'
      send err:404, error:'Not found'

  actn = req.actionName
  ctrl = req.controllerName
  user = session.user
  #format = if req.params.format == undefined then 'html' else 'json'

  if user.owner || app.get('env') == 'development'
    if app.settings.isTesting
      if ctrl == 'home' and actn == 'switchClient'
        next()
  if not user
    redirect path_to.root
  # si la accion se encuentra en la lista de ignoradas pasa de largo
  to_ignore = compound.acomplish.permissions.to_ignore
  if to_ignore.hasOwnProperty(ctrl)
    if to_ignore[ctrl].indexOf(actn) != -1
      return next()

  # verifica si el usuario posee acceso a estos controladores y acciones
  if user.owner
    return next()
  else
    if format == 'html'
      if ctrl in ['clients','paises', 'provincias', 'localidades', 'barrios']
        notFound()
    else if format == 'json'
      if ctrl in ['paises', 'provincias', 'localidades', 'barrios']
        if actn in ['destroy','update']
          reject()
        else
          next()

  # verifica si posee permiso para ejecutar la accion
  userAbilities = session.user.abilities or {}
  if userAbilities
    if userAbilities.hasOwnProperty(ctrl)
      if userAbilities[ctrl][0] is "*"
        return next()
      if userAbilities[ctrl].indexOf(actn) isnt -1
        return next()

  # No rules matched, User is NOT authorized.
  reject()

#
# Carga en la session toda la informacion relacionada al usuario
#
# Procedimiento:
#   obtener usuario a partir de session.passport.user
#   si no es owner o client
#     cargar los permisos segun el rol que posea
#   cargar valores isOwner, isClient
#   cagar funciones utiles jade-side
#   cargar los datos de la iglesia que maneja

loadUserPassport = (req) ->

  setFunctionsJadeSide = (data_user) ->
    # Function accesible from jade template to
    # check role of current user.
    # Use:
    #   user.is('admin') OR user.is(['admin','guest'])
    data_user.is = (roles) ->
      if typeof roles is 'string'
        return if data_user.roles == roles then true else false
      else
        return if roles.indexOf(data_user.roles) != -1 then true else false
    # Function accesible from jade template to
    # check if user can execute an action.
    # Use:
    #   user.can('administration','home')
    #   user.can('users',['index','create'])
    data_user.can = (ctrl, action=null) ->
      if data_user.owner
        return true
      if data_user.abilities.hasOwnProperty(ctrl)
        if action isnt null
          if typeof action == 'string'
            if data_user.abilities[ctrl].indexOf(action) != -1
              return true
          else if typeof action == 'object'
            for act in action
              if data_user.abilities[ctrl].indexOf(act) != -1
                return true
        else
          return true
      return false
    # Function accesible from jade template to
    # check if user can execute a controllers
    # Use:
    #   user.canCtrls(['ctrl1','ctrl2'],'AND')
    #   user.canCtrls(['ctrl1','ctrl2'],'OR')
    data_user.canCtrls = (ctrls, operator='OR') ->
      if data_user.owner
        return true
      if typeof data_user.abilities != 'object'
        return false
      user_ctrls = Object.keys(data_user.abilities)
      operator = operator.toUpperCase()
      can_and = false
      for ctrl in ctrls
        if user_ctrls.indexOf(ctrl) != -1
          if operator == 'OR'
            return true
          else
            can_and = true
        else
          can_and = false
      return can_and

  loadPermissions = (data_user, iglesia, cb) ->
    # si no estan cargados los permisos
    if data_user.owner
      data_user.rolesNames = 'SA'
    if data_user.isClient
      data_user.rolesNames = 'Propietario'
    if data_user.owner or data_user.isClient
      allActions = compound.acomplish.permissions.all_actions
      allActions = compound.models.Role._parsePermissionsToSave(
          JSON.stringify(allActions))
      data_user.abilities = JSON.parse(allActions)
      cb(data_user)
    else
      # obtiene el rol del usuario y carga las acciones que puede ejecutar
      users = JSON.parse(iglesia.users)
      roleId = users[data_user.id]
      compound.models.Role.find roleId, (err, doc) ->
        _permissions = compound.models.Role.decrypt(doc.permissions)
        if typeof _permissions == 'string'
          _permissions = JSON.parse(_permissions)
        if typeof _permissions == 'string'
          _permissions = JSON.parse(_permissions)
        data_user.abilities = _permissions
        data_user.rolesNames = doc.name
        cb(data_user)

  loadIglesia = (data_user, cb) ->
    compound.models.User.getIglesia data_user, (err, iglesia) ->
      if !err
        data_user.i = iglesia.id
        data_user.churchTitle = iglesia.nombre
        data_user.sharedInfo = iglesia.shared_info
      cb(err, data_user, iglesia)

  loadUser = (data_user, callback) ->
    data_user = JSON.parse(JSON.stringify(data_user))
    if data_user.hasOwnProperty('toObject')
      data_user = data_user.toObject()
    data_user.owner = compound.models.User.checkOwner(data_user.email)

    setFunctionsJadeSide(data_user)
    compound.models.User.isClient data_user, (err, isClient) ->
      data_user.isClient = isClient
      loadIglesia data_user, (err, data_user, iglesia) ->
        loadPermissions data_user, iglesia, (data_user_res) ->
          callback(data_user_res)

  ###################################################################
  if session.user
    if not session.user.hasOwnProperty('abilities')
      loadUser session.user, (userLoaded) ->
        session.user = userLoaded
        @user = userLoaded
        res.locals['user'] = userLoaded
        next()
    else
      @user = session.user
      setFunctionsJadeSide(@user)
      next()
  else
    @user = false
    session.user = false
    if req.app.settings.login
      unless session.passport.user
        req.session.redirect = req.path
        redirect "/login"
      else
        User.find session.passport.user, (err, user) ->
          if not err or user
            loadUser user.toObject(), (userLoaded) ->
              session.user = userLoaded
              @user = userLoaded
              next()
    else
      # DEVELOP MODE
      User.findOne where: email:'develop@quo.com', (err, user) ->
      #User.findOne where: email:'sergiodeleokrivas@gmail.com', (err, user) ->
        loadUser user, (userLoaded) ->
          session.user = userLoaded
          @user = userLoaded
          next()

# Load a User's Roles into the session.
# Load is skipped if 'cachedRoles' is set to 'true'
loadRoles = ->
  #TODO: update to new format of roles (ene-2014)
  unless @loggedIn
    return next()
  if @cacheRoles and session.user.roles
    return next()

  # As a security precaution, reset the user's roles.
  session.user.roles = []
  User.find session.user.id, (err, user) ->
    session.user.roles = user.roles
    return next()

# Loads a User's Abilities based on the Role(s) they have.
# Load is skipped if 'cachedAbilities' is set to 'true'.
loadAbilities = ->
  unless @loggedIn
    return next()
  # if @cacheAbilities and session.user.abilities
  #   return next()
  userRoles = [session.user.roles]
  userAbilities = {}
  for role of @systemRoles
    if userRoles.indexOf(role) isnt -1
      abilities = @systemRoles[role].permissions
      if typeof abilities is 'string'
        abilities = JSON.parse(abilities)
      abilities.forEach (ability) ->
        ctrl = ability.controller
        if userAbilities[ctrl]
          return "*"  if userAbilities[ctrl].indexOf("*") isnt -1
          userAbilities[ctrl] = merge(userAbilities[ctrl].concat(ability.actions))
        else
          userAbilities[ctrl] = ability.actions
  session.user.abilities = userAbilities
  session.user.modules_can_access = Object.keys(userAbilities)
  compound.acomplish._user.abilities = userAbilities
  next()

# Util method for merging an array by removing duplicates.
#
# @param {Array} array Array to merge.
merge = (array) ->
  a = array.concat()
  i = 0

  while i < a.length
    j = i + 1

    while j < a.length
      a.splice j--, 1  if a[i] is a[j]
      ++j
    ++i
  a

publish "authorize", authorize
publish "loadRoles", loadRoles
publish "loadAbilities", loadAbilities
publish "loadUserPassport", loadUserPassport