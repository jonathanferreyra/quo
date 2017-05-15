module.exports = (compound) ->

  # lista de acciones que seran ignoradas para no ser
  # guardadas como registro de accesos del usuario
  toIgnore = compound.models.Role._getActionsToIgnore()
  for ctrl, actions of toIgnore
    actions.push('getItem', 'dependences', 'getDependences', 'metaFields')
  compound.acomplish.permissions.to_ignore = toIgnore

  compound.acomplish.permissions.ajax = compound.models.Role._getActionsAjax()
  compound.acomplish.permissions.all_actions = compound.models.Role._getRawActionsControllers()

  createTestUsers = (cb) ->
    # crea el primer user
    compound.models.User.all (err, items) ->
      if !err
        if items.length == 0
          data =
            nombre:'Usuario'
            apellido:'DePrueba'
            telefonos:'111222333'
            emails:'develop@quo.com'
            pais: 'Argentina'
          compound.models.User.createNewAccount data, (err, res) ->
            if !err
              console.log '>>> Test user created...'
            else
              console.log '>>> ERROR during creating user test:', err
            cb()
        else
          cb()
      else
        cb()

  createTestUsers () ->
    if compound.app.settings.loadGeographicDataAtStart
      console.log 'Loading geographic data in cache...'
      compound.async.series([
        (cb) ->
          compound.meg.cache.all('Pais', cb)
        , (cb) ->
          compound.meg.cache.all('Provincia', cb)
        , (cb) ->
          compound.meg.cache.all('Localidad', cb)
        , (cb) ->
          compound.meg.cache.all('Barrio', cb)
      ], () ->
        console.log 'Loading geographic data in cache...OK'
      )