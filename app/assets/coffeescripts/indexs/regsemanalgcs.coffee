_data_gcs = {}
_listadatos = []

setActions = (id)->
    editAction = '<a href="/regsemanalgcs/'+id+'/edit" title="Editar" data-rel="tooltip"><i class="icon icon-color icon-edit"></i>       </a>'
    deleteAction = '<a href="/regsemanalgcs/'+id+'" title="Eliminar" data-rel="tooltip" data-remote="true" data-method="delete" data-jsonp="(function (u) {location.href = u;})"><i class="icon icon-color icon-trash"></i></a>'
    showAction = '<a href="/regsemanalgcs/'+id+'" title="Ver detalles" data-rel="tooltip"><i class="icon icon-color icon-search"></i>       </a>'
    showAction + editAction + deleteAction  

cargarComboGcs = (aSelect) ->
  $.ajax '/allgcs',
    dataType: "json"
    success: (data) ->
      if data
        #################################################
        # generate data object gcs
        for item in data
          _data_gcs[item.nro] = item
        #################################################
        nros = (parseInt(item.nro) for item in data)
        nros.sort (a, b) ->
          if a > b then 1 else -1
        option = "<option value=''></option>"
        $(aSelect).append option
        $.each nros, (index, value) ->
          option = undefined
          option = "<option value=\"" + value + "\">" + value + "</option>"
          $(aSelect).append option
        $(aSelect + ' option:eq(0)')

getByNroGC = (nro) ->
  _result = []
  for row in _listadatos
    if row.gc == nro
      _result.push(row)
  return _result

showGC = (nro) ->
  '<a href="#" class="info-gc" gc="'+nro+'"><i class="icon icon-color icon-info"></i>        </a>' + nro



sortByDateFunction = (a, b) ->
  # REQUIERE DE: date.js | http://www.datejs.com/
  dateA = Date.parseExact(a.f, "d/M/yyyy").valueOf()
  dateB = Date.parseExact(b.f, "d/M/yyyy").valueOf()
  (if dateA > dateB then -1 else 1)



$('#tab2, .grupos').parent('li').addClass('active')
metaAjaxWithLoader '/regsemanalgcs.json', '.allitems', (items) ->
  _listadatos = items
  items.sort(sortByDateFunction)
  generarTabla listaordenada, items, (table) ->
    table.fnAdjustColumnSizing()
  $('.allitems').fadeIn()
  cargarComboGcs('#gcs')

###############################################################################
###### STATS ZONE
###############################################################################

cargarTablaResumen = (data) ->
  columnas = [
    name: "gc"
    showname: "Nro GC"
    parser: showGC
    params: [ "gc" ]
  ,
    name: "promedio_asistencias"
    showname: "Promedio de asistencias"
  ,
    name: "total"
    showname: "Asistencias totales"  
  ]
  data.sort (a, b) ->
    if parseInt(a.gc) > parseInt(b.gc) then -1 else 1
  generarTabla columnas, data, ((table) -> table.fnAdjustColumnSizing()), '#resumen'

  $('.info-gc').popover 
    trigger: 'hover'
    title: () ->
      'GC N° ' + $(this).attr('gc')
    content: () ->
      data = _data_gcs[$(this).attr('gc')]
      '<b>Timonel: </b>' + data.timonel + '<br>' + 
      '<b>Anfitrion: </b>' + data.anfitrion + '<br>' + 
      '<b>Dirección: </b>' + data.direccion + '<br>' + 
      '<b>Horario reunión: </b>' + data.horario + '<br>' + 
      '<b>Día reunión: </b>' + data.dia_de_la_semana

cargarAsistenciasMensualesTotales = (month, year) ->
  url = '/regsemanalgcs/st_asistencias_mensuales_gcs_total/'+year+'/'+month
  showGraphic = (_data) ->
    cargarTablaResumen _data
    $('#gcs_mensual_totales').empty()
    $('.resumen').fadeIn()
    Morris.Bar({
      element: 'gcs_mensual_totales',
      data: _data,
      xkey: 'gc',
      ykeys: ['total'],
      labels: ['Asistencias']
    })    
  metaAjaxWithLoader url, '.resumen', showGraphic

$('#gcs').on 'change', ->
  generarTabla(listaordenada, getByNroGC($('#gcs').val()))
  $('#example').attr('style','')

$('#st_mensuales_mes').val(Date.today().toString("M/yyyy"))
$("#st_mensuales_mes").datepicker('setValue', new Date()).datepicker("update")
$("#st_mensuales_mes").datepicker().on "changeDate", (ev) ->
  month = ev.date.getMonth() + 1
  year = ev.date.getFullYear()
  cargarAsistenciasMensualesTotales(month, year)

# when the page is load
now = new Date()
year = now.getFullYear()
month = (now.getMonth() + 1)
cargarAsistenciasMensualesTotales(month, year)