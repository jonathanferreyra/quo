showName = (ide, nom, ap) ->
  value = ''
  if nom.length > 0
    value = nom
  if ap.length > 0
    value = nom + ' ' + ap
  '<a href="/miembros/' + ide + '">' + value + '</a>'

@listaordenada = () ->
  [
    name: "ide"
    showname: "#"
  ,
    name: "nombre"
    showname: "Nombre y Apellido"
    params: [ "id","nombre","apellido" ]
    parser: showName
    parser: (id, n , ap) ->
      name = ''
      if n.length > 0
        name += ' ' + n
      if ap.length > 0
        name += ' ' + ap
      '<a class="tname" href="/miembros/' + id + '">' + name + '</a>'
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
  familia:(value) ->
    meg.data.references['idx']['familia'][value]['nombre']
  estado_civil:(value) ->
    meg.data.references['idx']['estado_civil'][value]['nombre']
  pertenece_gc:(value) ->
    meg.data.references['idx']['pertenece_gc'][value]['nro']
  clasificacion_social:(value) ->
    meg.data.references['idx']['clasificacion_social'][value]['nombre']
  estado_membresia:(value) ->
    meg.data.references['idx']['estado_membresia'][value]['nombre']
  relacion_familia:(value) ->
    if value then values.relacion_familia[value] else ''
  razon_alta:(value) ->
    if value then values.razon_alta[value] else ''
  emails:(value) ->
    if value?
      if value.length > 0
        _value = JSON.parse(value)
        _value = [item['email'] for item in _value]
        _value = if _value.length > 0 then _value[0] else []
        _value = _value.join(',')
        return _value
    return ''
  telefonos:(value) ->
    if value?
      if value.length > 0
        _value = JSON.parse(value)
        _value = [item['num'] for item in _value]
        _value = if _value.length > 0 then _value[0] else []
        _value = _value.join(',')
        return _value
    return ''
  ministerio:(value) ->
    if value?
      if value.length > 0
        _value = JSON.parse(value)
        _value = [meg.data.references['idx']['ministerio'][item['ministerio']]['nombre'] for item in _value]
        _value = if _value.length > 0 then _value[0] else []
        _value = _value.join(', ')
        return _value
    return ''

####

attrs = '?f=id,nombre'
@filter_fields = [
    name: 'bautizado_por_inmersion'
    text: 'Bautizado por inmersión'
    type: 'bool'
  ,
    name: 'bautizado_en_esta_iglesia'
    text: 'Bautizado en esta iglesia'
    type: 'bool'
]
@filter_fields_ajax = {
  'familia':{t:'Familia',u:'/familias.json' + attrs}
  'clasificacion_social':{t:'Clasificación social',u:'/clasificacionsocials.json' + attrs}
  'estado_civil':{t:'Estado civil',u:'/estadosciviles.json' + attrs}
  'estado_membresia':{t:'Estado membresía',u:'/estadomembresias.json' + attrs}
  'barrio':{t:'Barrio',u:'/barrios.json?f=id,name',ktext:'name' + '&force=true'}
  'localidad':{t:'Localidad',u:'/localidades.json?f=id,name&force=true',ktext:'name' + '&force=true'}
  'pertenece_gc':{t:'Grupo al que pertenece',u:'/grupocrecimientos.json?f=id,nro',ktext:'nro'}
  'ministerio':{t:'Ministerio',u:'/ministerios.json' + attrs, json:true}
}
@filter_fields_values = {
  'tipo_sangre':'Tipo de sangre'
  'razon_alta':'Razón alta'
  'sexo':'Sexo'
  }

@load_filter_fields_ajax()
@load_filter_fields_values()

# init filter plugin
@filter_fields = _.sortBy(@filter_fields, 'text')
$("#filters").MEGFilter(fields:@filter_fields)

####

attrs = ['id','ide','nombre','apellido']
#agrega los attr que son criterios de busqueda
for filter in @filter_fields
  attrs.push(filter.name)
for k, v of @filter_fields_ajax
  attrs.push(k)
for k, v of @filter_fields_values
  attrs.push(k)
@itemsUrl = '/miembros.json?f=' + attrs.join(',')
#@itemsUrl = '/miembros.json'