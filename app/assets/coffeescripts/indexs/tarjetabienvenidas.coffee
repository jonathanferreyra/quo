@tableVars = {}
@tableVars.actions = '<div class="btn-group">
  <a class="btn " href="/{{=it.url}}/{{=it.id}}" data-rel="tooltip" item="{{=it.id}}" data-original-title="Ver detalles"><i class="glyphicon glyphicon-color fa fa-search"></i></a>
  <a class="btn " href="/{{=it.url}}/{{=it.id}}/edit" data-rel="tooltip" data-original-title="Editar"><i class="glyphicon glyphicon-color fa fa-edit"></i></a>
  <a class="btn item-del" href="#" data-rel="tooltip" item="{{=it.id}}" data-original-title="Eliminar"><i class="glyphicon glyphicon-color fa fa-trash-o"></i></a>
</div>'
@tableVars.row = '<div class="row col-md-12">
  <div class="row">
    <div class="col-md-10">
      <a class="tname" href="{{=it.url}}">#{{=it.ide}} {{=it.name}}</a>
    </div>
  </div>
  <div class="row">
    <div class="col-md-6">
      <p class="tdet nmb">{{=it.details1}}</p>
    </div>
  </div>
</div>'

generateRow = (id, ide, name, lastname, telefonos, dir, fecha, evento) ->
  vars =
    url : 'tarjetabienvenidas'
    id : id
  _actions = doT.template(tableVars.actions)(vars)

  det1 = []

  # telefonos
  if (telefonos != null) and (typeof telefonos != 'undefined')
    if telefonos.length > 0
      try
        tels = JSON.parse(telefonos)
        for t in tels
          det1.push(t.num)
      catch e
  if dir.length > 0
    det1.push(dir)

  det2 = []
  fecha = '<i class="fa fa-calendar" title="Fecha de la tarjeta" data-rel="tooltip"> ' + fecha + '</i>'
  for field in [fecha, evento]
    if field.length > 0
      det2.push(field)
  vars =
    ide : ide.toString()
    url : '/tarjetabienvenidas/' + id
    name : name + ' ' + lastname
    details1 : det1.join(' | ')
    details2 : det2.join(' | ')
    actions : _actions
  row = doT.template(tableVars.row)(vars)
  row

@listaordenada = () ->
  [
    name : ''
    showname : 'Nombre y apellido'
    parser: generateRow
    params: [
      'id','ide', 'nombre', 'apellido',
      'telefonos', 'direccion',
      'fecha', 'evento_text'
    ]
  ,
    name : 'fecha'
    showname : 'Fecha'
  ,
    name:"ultimo_seguimiento"
    showname:"Último seguimiento"
    params: [ "ultimo_seguimiento" ]
    parser: (value) ->
      st_seguimiento = ''
      if value.length > 0
        doc = JSON.parse(value)
        st_seguimiento = doc.fecha
      else
        st_seguimiento = '<span class="label label-default">Sin seguimientos</span>'
      st_seguimiento
  ,
    name:"ultimo_seguimiento"
    showname:"Estado"
    params: [ "ultimo_seguimiento" ]
    parser: (value) ->
      text = ''
      if value.length > 0
        doc = JSON.parse(value)
        if doc.estado == 'dejar_llamar'
          color = 'danger'
          title = 'Dejar de llamar'
        else
          color = 'success'
          title = 'Volver a llamar'
        text = '<i class="fa fa-phone-square text-' + color + '" title="' + title + '" data-rel="tooltip"></i>'
      text
  ,
    name: "accciones"
    showname: "Acciones"
    parser: setActions
    params: [ "id" ]
  ]

@fnFormatField =
  sexo:(value) ->
    if !value?
      return 'Masculino'
    sexos =
      m: 'Masculino'
      f: 'Femenino'
    return sexos[value]
  barrio:(value) ->
    meg.data.references['idx']['barrio'][value]['name']
  localidad:(value) ->
    meg.data.references['idx']['localidad'][value]['name']
  estado_civil:(value) ->
    meg.data.references['idx']['estado_civil'][value]['nombre']
  clasificacion_social:(value) ->
    meg.data.references['idx']['clasificacion_social'][value]['nombre']
  evento:(value) ->
    item = meg.data.references['idx']['evento'][value]
    item['nombre'] + ' (' + item['fecha'] + ')'
  telefonos:(value) ->
    if value?
      if value.length > 0
        _value = JSON.parse(value)
        _value = [item['num'] for item in _value]
        _value = if _value.length > 0 then _value[0] else []
        _value = _value.join(',')
        return _value
    return ''
  religion:(value) ->
    if value then values.religion[value] else ''
  tipo_desicion:(value) ->
    if value then values.tipo_desicion[value] else ''
  lugar_lleno_tarjeta:(value) ->
    if value then values.lugar_lleno_tarjeta[value] else ''

attrs = '?f=id,nombre'
refs_urls = [
  {url:'eventos.json' + attrs, name:'evento', attr:'nombre'}
]
#{url:'seguimientopersonas.json?f=id,fecha', name:'ultimo_seguimiento', attr:'fecha'}

opts_estados_llamada = [
  {id:'', text:'Nunca se llamó'}
]
for k, v of @values.estados_llamada
  opts_estados_llamada.push({id:k, text:v})

@filter_fields = [
  name: 'fecha'
  text: 'Fecha'
  type: 'date'
,
  name: 'estado_seguimiento'
  text: 'Estado de llamada'
  type: 'opts'
  options:opts_estados_llamada
]
@filter_fields_ajax = {
  'evento':{t:'Evento',u:'/eventos.json' + attrs + ',fecha'}
  'clasificacion_social':{t:'Clasificación social',u:'/clasificacionsocials.json' + attrs}
  'estado_civil':{t:'Estado civil',u:'/estadosciviles.json' + attrs}
  'barrio':{t:'Barrio',u:'/barrios.json?f=id,name', ktext:'name'}
  'localidad':{t:'Localidad',u:'/localidades.json?f=id,name&force=true', ktext:'name'}
  }
@filter_fields_values = {
  'religion':'Religión'
  'lugar_lleno_tarjeta':'Lugar llenó tarjeta'
  'tipo_desicion':'Tipo desición'
  'sexo':'Sexo'
  }

@load_filter_fields_ajax()
@load_filter_fields_values()

# init filter plugin
@filter_fields = _.sortBy(@filter_fields, 'text')
$("#filters").MEGFilter(fields:@filter_fields)

#####

attrs = ['id','ide','nombre','apellido','telefonos', 'direccion'
  ,'fecha','evento', 'ultimo_seguimiento','estado_seguimiento']
#agrega los attr que son criterios de busqueda
for k, v of @filter_fields_ajax
  attrs.push(k)
for k, v of @filter_fields_values
  attrs.push(k)
@itemsUrl = '/tarjetabienvenidas.json?f=' + attrs.join(',')

@beforeLoadTable = (listadatos) =>
  console.time 'tabla'
  @reloadTable listadatos, () ->
    console.timeEnd 'tabla'
    # modal registrar seguimiento
    #$('.reg-seguimiento').on 'click', ->
    #  $('#table').parent().parent().parent()
    #    .addClass('item-id').attr('id',$(@).attr('item'))
    @bindEvents()

@documentReady = (cb=null) ->
  $('.loader').show()
  meg.server.ajax @itemsUrl, {}, (err, listadatos) ->
    if listadatos.length > 0

      if not meg.data?
        meg.data = {}
      meg.data.currentItems = listadatos
      #carga los items referencia indicados en 'refs_urls'
      async.map refs_urls, (ref, cb) ->
        meg.server.ajax ref.url, {}, (err, items) ->
          @references[ref.name] = _.indexBy(items, 'id')
          for item in listadatos
            item[ref.name + '_text'] = ''
            if item.hasOwnProperty(ref.name)
              try
                if item[ref.name].length > 0
                  item[ref.name + '_text'] = @references[ref.name][item[ref.name]][ref.attr]
              catch e
                item[ref.name + '_text'] = '-'

          cb()
      , (err, res) ->
        @items = listadatos
        @beforeLoadTable(listadatos)
    else
      @items = listadatos
      @reloadTable listadatos, cb

$('#btn-filtrar-ult-seg').on 'click', =>
  condicional = $('#sel-flt-op').val() # may | men
  value = $('#sel-flt-value').val() # 1..10
  periodo = $('#sel-flt-periodo').val() # d | s | m

  dtInit = Date.today()
  value = parseInt(value)
  if periodo == 'd'
    dtInit.addDays(-value)
  else if periodo == 's'
    dtInit.addWeeks(-value)
  else if periodo == 'm'
    dtInit.addMonths(-value)

  $('#loader-filter').show()
  new Parallel([meg.data.currentItems, condicional, dtInit], { evalPath: '/vendor/parallel/eval.js' })
    .require('/javascripts/date.js')
    .spawn (params) ->
      items = params[0]
      condicional = params[1]
      dtInit = params[2]
      result = []
      for item in items
        if item['ultimo_seguimiento']
          if item['ultimo_seguimiento'].length > 0
            obj = JSON.parse(item['ultimo_seguimiento'])
            dtFechaSeguimiento = Date.parseExact(obj['fecha'], "yyyy-MM-dd")
            condiciones = {may:dtInit > dtFechaSeguimiento, men:dtInit < dtFechaSeguimiento}
            if condiciones[condicional]
              result.push(item)
      return result
    .then (res, err) =>
      meg.data.currentFiltered = res
      @beforeLoadTable(res)
      $('#loader-filter').hide()