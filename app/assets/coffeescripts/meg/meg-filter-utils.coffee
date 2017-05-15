#DEPENDENCES:
# meg/server
# meg/table
# lodash

# valores de filtros normales, atributos del doc
# uso:
#   [{name:'edad',text:'Edad',type'number'}, ...]
#   type = number|date
@filter_fields = []

# valores de filtro cargados desde ajax
# uso:
#   {'estado_civil':{t:'Estado civil',u:'/estadosciviles.json'}, ...}
#   donde t = text, u = url
@filter_fields_ajax = {}

# valores cargados manualmente, values/pluralmodel.js
# uso:
#   {'lugar_lleno_tarjeta':'Lugar llenó tarjeta', ...}
#   donde "lugar_lleno_tarjeta" debe ser la key del dict
#   "values" definido en el archivo values/pluralmodel.js
@filter_fields_values = {}
@references = {}

# agrega los filtros ajax
@load_filter_fields_ajax = () ->
  if @filter_fields_ajax
    for _name, _attrs of @filter_fields_ajax
      _id = if _attrs.kid then _attrs.kid else "id"
      _text = if _attrs.ktext then _attrs.ktext else "nombre"
      opts =
        name: _name
        text: _attrs.t
        type: "ajax"
        empty: if _attrs.hasOwnProperty('e') then _attrs.e else true
        ajaxSettings:
          url: _attrs.u
          doneFn: (res, cb) ->
            cb res.data
        keyId: _id
        keyText: _text

      # json type data
      if _attrs.hasOwnProperty('json')
        opts.json = _attrs.json

      @filter_fields.push(opts)

# agrega los values a los filtros
@load_filter_fields_values = () ->
  if @filter_fields_values
    for _name, _text of @filter_fields_values
      _values = values[_name]
      opts = []
      for k, v of _values
        opts.push({id:k, text:v.replace('...','')})
      @filter_fields.push({
        name: _name
        text: _text
        type: 'opts'
        options: opts
      })

@fnFilterData = (rows, filters=null, fields=null) ->
  if not fields
    fields = $('#filters').MEGFilter('getValue', 'fields')
  if not filters
    filters = $('#filters').MEGFilter('getFilters')

  equals = {}
  not_equals = {}
  op_is =
    json : {}
    bool : {}
  fn_is_type =
    json : (obj, field, value) ->
      if obj.hasOwnProperty(field)
        if obj[field].indexOf(value) != -1 then true else false
      else
        return false
    bool : (obj, field, value) ->
      _true = [1, true, 'true', '1']
      _false = [0, false, 'false', '0']
      if obj.hasOwnProperty(field)
        if value.v.toString() == '1' #true
          if value.op == '='
            return obj[field] in _true
          else
            return obj[field] not in _true
        else #false
          if value.op == '='
            return obj[field] in _false
          else
            return obj[field] not in _false
      else
        return false
  results = rows
  for _f in filters
    if not fields[_f.field].hasOwnProperty('json')
      if fields[_f.field].type == 'bool'
        op_is.bool[_f.field] =
          v: _f.value
          op: _f.operator
      else
        if _f.operator == '='
          equals[_f.field] = _f.value
        else if _f.operator == '!'
          not_equals[_f.field] = _f.value
    else
      op_is.json[_f.field] = _f.value
  # equals
  if Object.keys(equals).length > 0
    results = _.where(results, equals)

  # json, bool data type
  _types = Object.keys(op_is)
  # console.log op_is
  for _type in _types
    if Object.keys(op_is[_type]).length > 0
      for field, value of op_is[_type]
        results = _.filter results, (obj) ->
          fn_is_type[_type](obj, field, value)

  # not equals
  if Object.keys(not_equals).length > 0
    results = _.reject(results, not_equals)
  results

@fn_btn_reload = () =>
  meg.data.currentItems = @items
  @reloadTable(@items)

# @fn_btn_filter = () =>
#   #$('#filtering-state').show()
#   _reloadTable = @reloadTable
#   _filterData = @fnFilterData
#   #resFilter = $('#filters').MEGFilter('filterData', @items)
#   params = [
#     @items
#     $('#filters').MEGFilter('getFilters')
#     $('#filters').MEGFilter('getValue', 'fields')
#   ]
#   new Parallel(params, { evalPath: '/vendor/parallel/eval.js' })
#     .require('/javascripts/lodash.min.js')
#     .require(fn:_filterData, name:'filterData')
#     .spawn (params) ->
#       return filterData(params[0], params[1], params[2])
#     .then (resFilter, err) ->
#       #$('#filtering-state').hide()
#       meg.data.currentItems = resFilter
#       _reloadTable(resFilter)

@fn_btn_filter = () =>
  resFilter = $('#filters').MEGFilter('filterData', @items)
  meg.data.currentItems = resFilter
  @reloadTable(resFilter)

$('.btn-reload').on 'click', =>
  @fn_btn_reload()

$('.btn-filter').on 'click', =>
  @fn_btn_filter()

$(document).on 'ready', ->

  $('#btn-filter-minus').on 'click', ->
    item = $(@).find('i')
    if item.hasClass('fa-plus')
      item.removeClass('fa-plus').addClass('fa-minus')
    else
      item.removeClass('fa-minus').addClass('fa-plus')

  $("#btn-filter-minus").trigger('click')