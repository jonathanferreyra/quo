(function() {
  var calcularDuracion, cargarAsistenciasMensualesTotales, cargarComboGcs, cargarTablaResumen, getByNroGC, listaordenada, month, now, setActions, showGC, sortByDateFunction, year, _data_gcs, _listadatos;

  _data_gcs = {};

  _listadatos = [];

  setActions = function(id) {
    var deleteAction, editAction, showAction;
    editAction = '<a href="/regsemanalgcs/' + id + '/edit" title="Editar" data-rel="tooltip"><i class="icon icon-color icon-edit"></i>       </a>';
    deleteAction = '<a href="/regsemanalgcs/' + id + '" title="Eliminar" data-rel="tooltip" data-remote="true" data-method="delete" data-jsonp="(function (u) {location.href = u;})"><i class="icon icon-color icon-trash"></i></a>';
    showAction = '<a href="/regsemanalgcs/' + id + '" title="Ver detalles" data-rel="tooltip"><i class="icon icon-color icon-search"></i>       </a>';
    return showAction + editAction + deleteAction;
  };

  cargarComboGcs = function(aSelect) {
    return $.ajax('/allgcs', {
      dataType: "json",
      success: function(data) {
        var item, nros, option, _i, _len;
        if (data) {
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            _data_gcs[item.nro] = item;
          }
          nros = (function() {
            var _j, _len1, _results;
            _results = [];
            for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
              item = data[_j];
              _results.push(parseInt(item.nro));
            }
            return _results;
          })();
          nros.sort(function(a, b) {
            if (a > b) {
              return 1;
            } else {
              return -1;
            }
          });
          option = "<option value=''></option>";
          $(aSelect).append(option);
          $.each(nros, function(index, value) {
            option = void 0;
            option = "<option value=\"" + value + "\">" + value + "</option>";
            return $(aSelect).append(option);
          });
          return $(aSelect + ' option:eq(0)');
        }
      }
    });
  };

  getByNroGC = function(nro) {
    var row, _i, _len, _result;
    _result = [];
    for (_i = 0, _len = _listadatos.length; _i < _len; _i++) {
      row = _listadatos[_i];
      if (row.gc === nro) {
        _result.push(row);
      }
    }
    return _result;
  };

  showGC = function(nro) {
    return '<a href="#" class="info-gc" gc="' + nro + '"><i class="icon icon-color icon-info"></i>        </a>' + nro;
  };

  calcularDuracion = function(inicio, cierre) {
    var padNmb, resultado, secondsToTime, stringToSeconds, substractTimes;
    padNmb = function(nStr, nLen) {
      var sCeros, sRes;
      sRes = String(nStr);
      sCeros = "0000000000";
      return sCeros.substr(0, nLen - sRes.length) + sRes;
    };
    stringToSeconds = function(tiempo) {
      var hor, min, sec, sep1, sep2;
      sep1 = tiempo.indexOf(":");
      sep2 = tiempo.lastIndexOf(":");
      hor = tiempo.substr(0, sep1);
      min = tiempo.substr(sep1 + 1, sep2 - sep1 - 1);
      sec = tiempo.substr(sep2 + 1);
      return Number(sec) + (Number(min) * 60) + (Number(hor) * 3600);
    };
    secondsToTime = function(secs) {
      var hor, min, sec;
      hor = Math.floor(secs / 3600);
      min = Math.floor((secs - (hor * 3600)) / 60);
      sec = secs - (hor * 3600) - (min * 60);
      return padNmb(hor, 2) + ":" + padNmb(min, 2) + ":" + padNmb(sec, 2);
    };
    substractTimes = function(t1, t2) {
      var secs1, secs2, secsDif;
      secs1 = stringToSeconds(t1);
      secs2 = stringToSeconds(t2);
      secsDif = secs1 - secs2;
      return secondsToTime(secsDif);
    };
    inicio = inicio.substring(0, 5) + ":00";
    cierre = cierre.substring(0, 5) + ":00";
    resultado = substractTimes(cierre, inicio);
    return resultado.substring(0, 5);
  };

  sortByDateFunction = function(a, b) {
    var dateA, dateB;
    dateA = Date.parseExact(a.f, "d/M/yyyy").valueOf();
    dateB = Date.parseExact(b.f, "d/M/yyyy").valueOf();
    if (dateA > dateB) {
      return -1;
    } else {
      return 1;
    }
  };

  listaordenada = [
    {
      name: "gc",
      showname: "GC N°"
    }, {
      name: "f",
      showname: "Fecha"
    }, {
      name: "hi",
      showname: "Hora inicio"
    }, {
      name: "hc",
      showname: "Hora cierre"
    }, {
      name: "duracion",
      parser: calcularDuracion,
      params: ["hi", "hc"],
      showname: "Duración"
    }, {
      name: "cant",
      showname: "Cantidad asistencias"
    }, {
      name: "tc",
      showname: "Tema compartido"
    }, {
      name: "accciones",
      parser: setActions,
      params: ["id"],
      showname: "Acciones"
    }
  ];

  $('#tab2, .grupos').parent('li').addClass('active');

  metaAjaxWithLoader('/regsemanalgcs.json', '.allitems', function(items) {
    _listadatos = items;
    items.sort(sortByDateFunction);
    generarTabla(listaordenada, items, function(table) {
      return table.fnAdjustColumnSizing();
    });
    $('.allitems').fadeIn();
    return cargarComboGcs('#gcs');
  });

  cargarTablaResumen = function(data) {
    var columnas;
    columnas = [
      {
        name: "gc",
        showname: "Nro GC",
        parser: showGC,
        params: ["gc"]
      }, {
        name: "promedio_asistencias",
        showname: "Promedio de asistencias"
      }, {
        name: "total",
        showname: "Asistencias totales"
      }
    ];
    data.sort(function(a, b) {
      if (parseInt(a.gc) > parseInt(b.gc)) {
        return -1;
      } else {
        return 1;
      }
    });
    generarTabla(columnas, data, (function(table) {
      return table.fnAdjustColumnSizing();
    }), '#resumen');
    return $('.info-gc').popover({
      trigger: 'hover',
      title: function() {
        return 'GC N° ' + $(this).attr('gc');
      },
      content: function() {
        data = _data_gcs[$(this).attr('gc')];
        return '<b>Timonel: </b>' + data.timonel + '<br>' + '<b>Anfitrion: </b>' + data.anfitrion + '<br>' + '<b>Dirección: </b>' + data.direccion + '<br>' + '<b>Horario reunión: </b>' + data.horario + '<br>' + '<b>Día reunión: </b>' + data.dia_de_la_semana;
      }
    });
  };

  cargarAsistenciasMensualesTotales = function(month, year) {
    var showGraphic, url;
    url = '/regsemanalgcs/st_asistencias_mensuales_gcs_total/' + year + '/' + month;
    showGraphic = function(_data) {
      cargarTablaResumen(_data);
      $('#gcs_mensual_totales').empty();
      $('.resumen').fadeIn();
      return Morris.Bar({
        element: 'gcs_mensual_totales',
        data: _data,
        xkey: 'gc',
        ykeys: ['total'],
        labels: ['Asistencias']
      });
    };
    return metaAjaxWithLoader(url, '.resumen', showGraphic);
  };

  $('#gcs').on('change', function() {
    generarTabla(listaordenada, getByNroGC($('#gcs').val()));
    return $('#example').attr('style', '');
  });

  $('#st_mensuales_mes').val(Date.today().toString("M/yyyy"));

  $("#st_mensuales_mes").datepicker('setValue', new Date()).datepicker("update");

  $("#st_mensuales_mes").datepicker().on("changeDate", function(ev) {
    var month, year;
    month = ev.date.getMonth() + 1;
    year = ev.date.getFullYear();
    return cargarAsistenciasMensualesTotales(month, year);
  });

  now = new Date();

  year = now.getFullYear();

  month = now.getMonth() + 1;

  cargarAsistenciasMensualesTotales(month, year);

}).call(this);
