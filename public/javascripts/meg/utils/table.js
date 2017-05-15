(function() {
  var table;

  if (this.meg == null) {
    this.meg = {};
  }

  this.meg.table = {};

  table = this.meg.table;

  table.makeParams = function(filaraw, params) {
    var i, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = params.length; _i < _len; _i++) {
      i = params[_i];
      if (filaraw[i] != null) {
        _results.push(filaraw[i]);
      } else {
        _results.push(i);
      }
    }
    return _results;
  };

  table.makeCabecera = function(listaordenada) {
    var _elemento, _i, _len, _shownameslist;
    _shownameslist = [];
    for (_i = 0, _len = listaordenada.length; _i < _len; _i++) {
      _elemento = listaordenada[_i];
      if (_elemento.showname) {
        _shownameslist.push(_elemento.showname);
      } else {
        _shownameslist.push(_elemento.name);
      }
    }
    return _shownameslist;
  };

  table.generarDataTables = function(listaordenada, listadatos, cb) {
    var filaraw, lista, _fila, _filaAParsear, _i, _j, _len, _len1, _params;
    lista = [];
    lista.push(table.makeCabecera(listaordenada));
    for (_i = 0, _len = listadatos.length; _i < _len; _i++) {
      filaraw = listadatos[_i];
      _fila = [];
      for (_j = 0, _len1 = listaordenada.length; _j < _len1; _j++) {
        _filaAParsear = listaordenada[_j];
        if (_filaAParsear.parser != null) {
          if (_filaAParsear.params != null) {
            _params = table.makeParams(filaraw, _filaAParsear.params);
            _fila.push(_filaAParsear.parser.apply(this, _params));
          } else {
            _fila.push(_filaAParsear.parser());
          }
        } else if (_filaAParsear.parsercb != null) {
          if (_filaAParsear.params != null) {
            _params = table.makeParams(filaraw, _filaAParsear.params);
            _params.push(function(value) {_fila.push(value)});
            _filaAParsear.parsercb.apply(this, _params);
          } else {
            _filaAParsear.parsercb(function(value) {_fila.push(value)});
          }
        } else {
          _fila.push(filaraw[_filaAParsear.name]);
        }
      }
      lista.push(_fila);
    }
    return cb(null, lista);
  };

  table.create = function(div, listaordenada, listadatos, cb) {
    if (cb == null) {
      cb = function() {};
    }
    return table.generarDataTables(listaordenada, listadatos, function(err, listafinal) {
      var data;
      data = table.createDataForDataTablesFromArraysArray(listafinal);
      return table.createDataTables(div, data, function(err, _table) {
        return cb(null, _table);
      });
    });
  };

  table.createDataForDataTablesFromArraysArray = function(arraysArray) {
    var aoColumns, firstRow, i;
    firstRow = arraysArray[0];
    aoColumns = [];
    for (i in firstRow) {
      aoColumns.push({
        sTitle: firstRow[i]
      });
    }
    arraysArray.splice(0, 1);
    return [arraysArray, aoColumns];
  };

  table.createDataTables = function(div, data, cb) {
    var aoColumns, dataArray, _table;
    if (cb == null) {
      cb = (function() {});
    }
    $(div).hide();
    dataArray = data[0];
    aoColumns = data[1];
    _table = $(div).dataTable({
      aoColumns: aoColumns,
      aaData: dataArray,
      bStateSave: true,
      aLengthMenu: [[10, 25, 50, -1], [10, 25, 50, "Todo"]],
      bDestroy: true,
      oLanguage: {
        sLengthMenu: "_MENU_ entradas por página",
        sInfo: "Mostrando _START_ a _END_ de _TOTAL_ entradas",
        oPaginate: {
          sNext: "Siguiente",
          sPrevious: "Anterior"
        },
        sZeroRecords: "No se han encontrado resultados"
      }
    });
    $(div).each(function() {
      var datatable, length_sel, search_input;
      datatable = $(this);
      search_input = datatable.closest(".dataTables_wrapper").find("div[id$=_filter] input");
      search_input.attr("placeholder", "Buscar...");
      search_input.addClass("form-control input-sm");
      length_sel = datatable.closest(".dataTables_wrapper").find("div[id$=_length] select");
      return length_sel.addClass("form-control input-sm");
    });
    $(div).show();
    return cb(null, _table);
  };

}).call(this);
