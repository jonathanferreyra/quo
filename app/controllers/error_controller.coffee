load 'application'

before 'load clients', ->
  #if app.get('env') == 'development'
  if not res.locals.hasOwnProperty('clients')
    compound.models.User.getUsersAccountOwner (err, items) ->
      res.locals['clients'] = items
      next()
  else
    next()
  # else
  #     next()

action 'unAuthorized', ->
  @title = "Acceso denegado"
  render "unAuthorized"

action 'notFound', ->
  @title = 'Página no encontrada'
  render 'notFound'
