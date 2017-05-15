 exports.routes = (map)->
  map.root 'home#index'

  # grupos
  map.resources 'grupocrecimientos'
  map.resources 'regsemanalgcs', (_map) ->
    _map.get 'getByGrupo/:id', 'regsemanalgcs#getByGrupo'
    _map.get 'st_asistencias_mensuales_gcs_total/:year/:month', 'regsemanalgcs#asistencias_mensuales_gcs_total'
    _map.get 'asistentes', 'regsemanalgcs#asistentes'

  # finanzas
  map.resources 'movimientos'
  map.resources 'cuentas'
  map.resources 'categorias'

  # membresia
  map.resources 'miembros', (_map) ->
    _map.get 'empty_family','miembros#empty_family'
  map.resources 'ministerios'
  map.resources 'tarjetabienvenidas', (_map) ->
    _map.get 'getby', 'tarjetabienvenidas#getby'
    _map.post 'storeTracing', 'tarjetabienvenidas#storeTracing'
    _map.post 'createMember', 'tarjetabienvenidas#createMember'
  map.resources 'seguimientopersonas'
  map.resources 'eventos'
  map.resources 'familias'
  map.resources 'iglesias'

  # tablas basicas
  map.resources 'estadomembresias'
  map.resources 'estadosciviles'
  map.resources 'clasificacionsocials'

  map.resources 'paises'
  map.resources 'barrios'
  map.resources 'localidades'
  map.resources 'provincias', (_map) ->
    _map.get 'getLocalities/:id', 'provincias#getLocalities'
  map.get 'barrios/show/json/:id?', 'barrios#show_json'
  map.get 'localidades/show/json/:id?', 'localidades#show_json'
  map.get 'provincias/show/json/:id?', 'provincias#show_json'
  map.get 'paises/show/json/:id?', 'paises#show_json'


  map.resources 'roles', (_map) ->
    _map.get 'actions', 'roles#actions'
    _map.post 'setRole', 'roles#setRole'
  map.resources 'useraccesses'
  map.resources 'login'

  map.resources 'reports', (rep) ->
    rep.get 'miembro/:id', 'reports#miembro'

  map.get "logout", "login#logout"
  map.get "email_not_valid", "login#email_not_valid"

  map.resources 'users'
  map.get "profile", "users#profile"
  map.post "upd_personal_info", "users#upd_personal_info"
  map.post "add_account_email", "users#add_account_email"
  map.post "remove_account_email", "users#remove_account_email"
  map.get "/get_user_account_emails/:id", "users#get_user_account_emails"
  map.post "/users/setEnabled", "users#setEnabled"
  map.post "/users/existEmail/:email", "users#existEmail"

  map.resources 'clients'
  map.put 'clients/updateChurch/:id', 'clients#updateChurch'
  map.put 'clients/updateUser/:id', 'clients#updateUser'
  map.put 'clients/updateAccount/:id', 'clients#updateAccount'
  map.post 'clients/refreshModelInCache', 'clients#refreshModelInCache'

  map.get '/loginaccesses.:format?', 'loginaccesses#index'

  map.resources 'settings', only: ['edit', 'update']
  map.get '/settings', 'settings#edit'

  map.get  '/conceptos/:id.:format?/movimiento/new.:format?', 'conceptos#movimiento_new'
  map.post '/conceptos/:id.:format?/movimiento.:format?', 'conceptos#movimiento_create'

  #
  map.get '/unauthorized', 'error#unAuthorized'
  map.get '/notFound', 'error#notFound'

  #timespan
  map.get 'timespans/get/:id.:format?', 'timespans#get'
  map.get 'cache', 'home#cache'
  map.post 'switchClient', 'home#switchClient'
  map.post 'appendDB', 'home#appendDB'
  map.get 'down', 'home#down'

  # Generic routes. Add all your routes below this line
  # feel free to remove generic routes
  map.all ':controller/:action'
  map.all ':controller/:action/:id'
  map.all ':controller/:action/:id?.:format?'