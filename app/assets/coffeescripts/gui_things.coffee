+gui_things = {}

###* @expose ###
gui_things.instanceTelefonosSimpleTable = (model_id, data=null) ->
  _mode = 'edit'
  if typeof data == 'string'
    _mode = 'show'
  options =
    mode: _mode
    btAddClass:'btn btn-default btn-sm'
    fillAllRow:true
    columns: [
      name: 'tipo'
      display: 'Tipo'
      type: 'select'
      keyId: 'id'
      keyText: 'text'
      options: defaults.get('telefonos')
    ,
      name: 'num'
      display: 'Número'
      type: 'tel'
    ]

  if _mode == 'edit'
    # mode form
    sel_telefonos = model_id + 'telefonos'
    if $(sel_telefonos).val().length > 0
      options.data = JSON.parse($(sel_telefonos).val())
    $('#div-telefonos').MEGSimpleTable(options)
  else if _mode == 'show'
    #mode show
    if (data.length > 0) and (data != '[]')
      options.data = JSON.parse(data)
      $('#div-telefonos').MEGSimpleTable(options)
    else
      $('#div-telefonos').append(
        '<div class="callout callout-info">No hay datos para mostrar.</div>')


###* @expose ###
gui_things.instanceEmailsSimpleTable = (model_id, data=null) ->
  _mode = 'edit'
  if typeof data == 'string'
    _mode = 'show'
  options =
    mode: _mode
    btAddClass:'btn btn-default btn-sm'
    columns: [
      name: 'email'
      display: 'Email'
      type: 'text'
      placeholder:'nombreusuario@dominio.com'
    ]

  if _mode == 'edit'
    # mode form
    sel = model_id + 'emails'
    if $(sel).val().length > 0
      options.data = JSON.parse($(sel).val())
    $('#div-emails').MEGSimpleTable(options)
  else if _mode == 'show'
    #mode show
    if (data.length > 0) and (data != '[]')
      options.data = JSON.parse(data)
      $('#div-emails').MEGSimpleTable(options)
    else
      $('#div-emails').append(
        '<div class="callout callout-info">No hay datos para mostrar.</div>')

gui_things.calculateAge = (dateString) ->
  birthday = +new Date(dateString)
  return~~ ((Date.now() - birthday) / (31557600000))

@["gui_things"] = gui_things