meg.server.ajax '/miembros/getItem/id', {}, (err, instanciaModel) ->
  meg.gui.showFromValueName '#razon_alta', values.razon_alta, instanciaModel.razon_alta
  meg.gui.showFromValueName '#relacion_familia', values.relacion_familia, instanciaModel.relacion_familia


  user_badges = ''
  async.series([
    (cb) ->
      meg.gui.showRefName 'familias', 'nombre', instanciaModel.familia, '#familia', true, cb
    , (cb) ->
      meg.gui.showRefName 'clasificacionsocials', 'nombre', instanciaModel.clasificacion_social, '#clasificacion_social', false, cb
    , (cb) ->
      meg.gui.showRefName 'estadomembresias', 'nombre', instanciaModel.estado_membresia, '#estado_membresia', false, (err, text) ->
        if text isnt null
          user_badges += '<span class="label label-primary">' + text + '</span>'
        if instanciaModel.bautizado_por_inmersion in [true, 'true', 1, '1']
          user_badges += '  <span class="label label-success">Bautizado</span>'
        if user_badges.length > 0
          $('#user-badges').append(user_badges)
        cb()
    , (cb) ->
      meg.gui.showRefName 'estadosciviles', 'nombre', instanciaModel.estado_civil, '#estado_civil', false, cb
    , (cb) ->
      meg.gui.showRefName 'grupocrecimientos', 'nro', instanciaModel.pertenece_gc, '#pertenece_gc', false, cb
    , (cb) ->
      if typeof instanciaModel.barrio isnt 'undefined'
        meg.server.ajax '/barrios/show/json/' + instanciaModel.barrio, {}, (err, barrio) ->
          meg.server.ajax '/localidades/show/json/' + instanciaModel.localidad, {}, (err, localidad) ->
            if barrio and localidad
              text = ' B° ' + barrio.name + ', ' + localidad.name
              $('#user-location').text(text)
            cb()
  ], (err, res) ->

  )

  tbId = instanciaModel.tarjeta_bienvenida
  if typeof tbId isnt 'undefined'
    if tbId.length > 0
      meg.server.ajax '/tarjetabienvenidas/' + tbId + '.json', {}, (err, tb) ->
        if tb
          $('#tarjeta_bienvenida').append(
            '<a href="/tarjetabienvenidas/' + tb.id + '">#' + [tb.ide, tb.nombre, tb.apellido].join(' ') + '</a>')

  ministerios = instanciaModel.ministerio
  items = []
  if (ministerios.length > 0) and (ministerios != '[]')
    meg.server.ajax '/ministerios.json', {}, (err, items) ->
      options =
        mode: 'show'
        columns: [
          name: 'ministerio'
          display: 'Ministerio'
          type: 'select'
          keyId: 'id'
          keyText: 'nombre'
          options: items
        ,
          name: 'funcion'
          display: 'Función que cumple'
          type: 'text'
        ]
      options.data = JSON.parse(ministerios)
      $('#div-ministerios').MEGSimpleTable(options)
  else
    $('#div-ministerios').append(
      '<div class="alert alert-info">No hay ministerios para mostrar.</div>')

  #### telefonos table
  data = instanciaModel.telefonos
  if data.length > 0 and data != '[]'
    data = JSON.parse(data)
    trs = ''
    user_telefonos = []
    for t in data
      tipo = defaults.telefonos[t.tipo]
      num = '<a href="tel:' + t.num + '">' + t.num + '</a>'
      trs += '<tr><td>' + tipo + '</td><td>' + num + '</td></tr>'
      user_telefonos.push(num)

    # set user phones
    if user_telefonos.length > 0
      $('#user-phones').append(' ' + user_telefonos.join(' | '))

    tb = '<table class="table"><thead><tr><th>Tipo</th><th>Número</th></tr></thead>
      <tbody>' + trs + '</tbody></table>'
    $('#div-telefonos').empty().append(tb)
  else
    $('#div-telefonos').append('<div class="callout callout-info">No hay datos para mostrar.</div>')

  #### emails table
  data = instanciaModel.emails
  if data.length > 0 and data != '[]'
    data = JSON.parse(data)
    trs = ''
    user_emails = []
    for e in data
      email = '<a href="mailto:' + e.email + '">' + e.email + '</a>'
      trs += '<tr><td>' + email + '</td></tr>'
      user_emails.push(email)

    # set user emails
    if user_emails.length > 0
      $('#user-emails').append(' ' + user_emails.join(' | '))

    tb = '<table class="table"><thead><tr><th>Email</th></tr></thead>
      <tbody>' + trs + '</tbody></table>'
    $('#div-emails').empty().append(tb)
  else
    $('#div-emails').append('<div class="callout callout-info">No hay datos para mostrar.</div>')


  #### redes sociales table
  redes_sociales = instanciaModel.redes_sociales
  if (redes_sociales.length > 0) and (redes_sociales != '[]')
    options =
      mode:'show'
      columns: [
        name: 'rs'
        display: 'Red social'
        type: 'select'
        keyId: 'id'
        keyText: 'text'
        options: defaults.get('redes_sociales')
      ,
        name: 'url'
        display: 'Link / Nombre de usuario'
        type: 'text'
      ]
    options.data = JSON.parse(redes_sociales)
    $('#div-redes-soc').MEGSimpleTable(options)
  else
    $('#div-redes-soc').append(
      '<div class="callout callout-info">No hay datos para mostrar.</div>')

  # mostrar edad al dado de la fecha de nacimiento
  if $('#fecha_nacimiento').text().length > 0
    fn = $('#fecha_nacimiento').text().trim()
    age = gui_things.calculateAge(fn)
    new_value = fn
    if age > 1
      new_value += ' (' + age.toString() + ' años)'
    else if age == 1
      new_value += ' (' + age.toString() + ' año)'
    $('#fecha_nacimiento').text(new_value)

    # set user birthday
    dtFn = fn.split('-')
    months = {1:'Enero', 2:'Febrero', 3:'Marzo', 4:'Abril'
      , 5:'Mayo',6:'Junio',7:'Julio',8:'Agosto'
      , 9:'Septiembre',10:'Octubre',11:'Noviembre',12:'Diciembre'}
    $('#user-birthday').text(' ' + dtFn[2] + ' de ' + months[parseInt(dtFn[1])])

# Ir al miembro
$('.to-ide').on 'click', ->
  bootbox.prompt "Ingresa el número de miembro al que deseas ir", (result) ->
    if result != null
      if not isNaN(result)
        window.location = '/miembros/goTo/' + result