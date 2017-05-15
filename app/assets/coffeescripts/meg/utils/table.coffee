#- DEPENDENCIES = dinamictable.min.css,dinamictable1.9.all.min.css
@.meg = {} unless @.meg?
@meg.table = {}
table = @meg.table

# @parserDate =(datelist) ->
#   return "una fecha"
  
table.makeParams = (filaraw,params) ->
  _results = []
  for i in params
    if filaraw[i]?
      _results.push filaraw[i]
    else
      _results.push i
  _results
  
table.makeCabecera = (listaordenada) ->
  _shownameslist = []
  for _elemento in listaordenada#cada uno de los dics
    if _elemento.showname#hay un key showname
      _shownameslist.push _elemento.showname        
    else
      _shownameslist.push _elemento.name
  _shownameslist

table.generarDataTables = (listaordenada, listadatos,cb) ->
  lista = []
  lista.push table.makeCabecera(listaordenada)
  
  for filaraw in listadatos#- cada uno de los datos
    _fila = []
    for _filaAParsear in listaordenada#- cada uno de los dics
      if _filaAParsear.parser?#- hay un key parser
        if _filaAParsear.params?#hay un key params
          _params = table.makeParams(filaraw,_filaAParsear.params)
          _fila.push _filaAParsear.parser.apply(@, _params)
        else#no hay un key params parser normal
          _fila.push _filaAParsear.parser()#pushe el valor del _filaAParsear
      else if _filaAParsear.parsercb?#- hay un key parsercb
        if _filaAParsear.params?
          _params = table.makeParams(filaraw,_filaAParsear.params)
          _params.push(`function(value) {_fila.push(value)}`)
          _filaAParsear.parsercb.apply(@, _params)
        else#- no hay un key params parsercb
          _filaAParsear.parsercb(`function(value) {_fila.push(value)}`)
      else#- no hay un key parser ni parsercb
        _fila.push filaraw[_filaAParsear.name]#- pushe el valor del _filaAParsear
    lista.push _fila#- push fila completa
  cb(null,lista)

table.create = (div,listaordenada, listadatos, cb=->)->
  #for datatables now
  table.generarDataTables(listaordenada, listadatos, (err, listafinal) ->
    data = table.createDataForDataTablesFromArraysArray(listafinal)
    #- #######debug data
    #- console.log listafinal
    #- console.log data
    #- ################
    table.createDataTables(div,data, (err,_table)->
      cb(null,_table)
    )
  )

table.createDataForDataTablesFromArraysArray = (arraysArray) ->
  firstRow = arraysArray[0]
  aoColumns = []
  for i of firstRow
    aoColumns.push sTitle: firstRow[i]
  arraysArray.splice 0, 1
  
  [ arraysArray, aoColumns ]

table.createDataTables = (div, data, cb = (->) ) ->
  $(div).hide()
  dataArray = data[0]
  aoColumns = data[1]
  _table = $(div).dataTable(
    aoColumns: aoColumns
    aaData: dataArray
    bStateSave: true
    aLengthMenu: [ [ 10, 25, 50, -1 ], [ 10, 25, 50, "Todo" ] ]
    bDestroy: true
    oLanguage:
      sLengthMenu: "_MENU_ entradas por página"
      sInfo: "Mostrando _START_ a _END_ de _TOTAL_ entradas"
      oPaginate:
        sNext: "Siguiente"
        sPrevious: "Anterior"
      sZeroRecords: "No se han encontrado resultados"
  )
  $(div).each ->
    datatable = $(@)
    search_input = datatable.closest(".dataTables_wrapper").find("div[id$=_filter] input")
    #TODO: hacer que la busqueda sea central en responsive
    search_input.attr "placeholder", "Buscar..."
    search_input.addClass "form-control input-sm"
    length_sel = datatable.closest(".dataTables_wrapper").find("div[id$=_length] select")
    length_sel.addClass "form-control input-sm"
  $(div).show()
  cb(null,_table)