load 'application'

before 'load custom variables',=>
  model = 'home'
  @meg = {} if !@meg?
  @meg.actualModelName = model
  myModel = @meg[model]
  if !myModel?
    myModel = {}
    myModel.pluralmodel = 'home'
    myModel.titlemodel = 'Home'
    myModel.singleTitleModel = 'Home'
    myModel.letraGenero = 'a'
    myModel.subsection = ''
    @meg[model] = myModel
  @Vars = @meg[model]
  @user = session.user
  @eviroment = app.get 'env'

  #if app.get('env') == 'development'
  if not res.locals.hasOwnProperty('clients')
    compound.models.User.getUsersAccountOwner (err, items) ->
      res.locals['clients'] = items
      next()
  else
    next()
  #else
  #  next()

action 'index', =>
  @title = "Inicio"
  #if session.user.owner
  #  render 'owner_dash'

  if not app.settings.isMaintenance
    models = ['Miembro', 'Ministerio',
      'Tarjetabienvenida', 'Grupocrecimiento']
    values = {}
    values.counts = {}
    # fill with zeros
    for m in models
      values.counts[m] = 0
    compound.async.each models, (model, cb) ->
      compound.meg.cache.all model, (err, items) ->
        query =
          'model': model
          'i': session.user.i
        compound.meg.cache.find query, (err, items) ->
          values.counts[model.toLowerCase()] = items.length
          cb()
    , (err) ->
      render({
        user:session.user
        values:values
      })
  else
    @title = "En mantenimiento"
    render 'maintenance', layout:false

action 'tryapi', ->
  # API TOKEN: HjjmU6hP6pmP5Az1gsgBFQwPe6Pc2Kbv0I01r46n
  # URL: es.bibles.org
  # USER: citaenapostoles

action 'cache', ->
  send Object.keys(compound.utils)

action 'appendDB', ->
  data = req.body
  modelName = req.body.model
  delete data['model']
  compound.models[modelName].create data, (err, res) ->
    send err:err, res:res

action 'switchClient', ->
  @title = 'Cambiando...'
  compound.models.User.find req.body.id, (err, user) ->
    if !err and user
      compound.models.User.getIglesia user, (err, iglesia) ->
        session.user.i = iglesia.id
        session.user.churchTitle = iglesia.nombre
        req.login user, (err) ->
          req.session.user = user
          flash 'error', 'Error al intentar de cambiar de usuario'
          redirect '/'
    else
      redirect '/'

action 'down', ->
  @contactEmail = 'contacto@informaticameg.com'
  render({layout:false})