(function() {
  var attrs, generateRow, k, opts_estados_llamada, refs_urls, v, _ref, _ref1, _ref2;

  this.tableVars = {};

  this.tableVars.actions = '<div class="btn-group"> <a class="btn " href="/{{=it.url}}/{{=it.id}}" data-rel="tooltip" item="{{=it.id}}" data-original-title="Ver detalles"><i class="glyphicon glyphicon-color fa fa-search"></i></a> <a class="btn " href="/{{=it.url}}/{{=it.id}}/edit" data-rel="tooltip" data-original-title="Editar"><i class="glyphicon glyphicon-color fa fa-edit"></i></a> <a class="btn item-del" href="#" data-rel="tooltip" item="{{=it.id}}" data-original-title="Eliminar"><i class="glyphicon glyphicon-color fa fa-trash-o"></i></a> </div>';

  this.tableVars.row = '<div class="row col-md-12"> <div class="row"> <div class="col-md-10"> <a class="tname" href="{{=it.url}}">#{{=it.ide}} {{=it.name}}</a> </div> </div> <div class="row"> <div class="col-md-6"> <p class="tdet nmb">{{=it.details1}}</p> </div> </div> </div>';

  generateRow = function(id, ide, name, lastname, telefonos, dir, fecha, evento) {
    var det1, det2, row, vars, _actions;
    vars = {
      url: 'tarjetabienvenidas',
      id: id
    };
    _actions = doT.template(tableVars.actions)(vars);
    det1 = [];
    det2 = [];
    vars = {
      ide: ide.toString(),
      url: '/tarjetabienvenidas/' + id,
      name: name + ' ' + lastname,
      details1: det1.join(' | '),
      details2: det2.join(' | '),
      actions: _actions
    };
    row = doT.template(tableVars.row)(vars);
    return row;
  };

  this.listaordenada = function() {
    return [
      {
        name: '',
        showname: 'Nombre y apellido',
        parser: generateRow,
        params: ['id', 'ide', 'nombre', 'apellido', 'telefonos', 'direccion', 'fecha', 'evento_text']
      }, {
        name: 'fecha',
        showname: 'Fecha'
      }, {
        name: "ultimo_seguimiento",
        showname: "Último seguimiento",
        params: ["ultimo_seguimiento"],
        parser: function(value) {
          var st_seguimiento;
          st_seguimiento = '';
          return st_seguimiento;
        }
      }, {
        name: "ultimo_seguimiento",
        showname: "Estado",
        params: ["ultimo_seguimiento"],
        parser: function(value) {
          var text;
          text = '';
          return text;
        }
      }, {
        name: "accciones",
        showname: "Acciones",
        parser: setActions,
        params: ["id"]
      }
    ];
  };

  this.fnFormatField = {
    sexo: function(value) {
      var sexos;
      if (value == null) {
        return 'Masculino';
      }
      sexos = {
        m: 'Masculino',
        f: 'Femenino'
      };
      return sexos[value];
    },
    barrio: function(value) {
      return meg.data.references['idx']['barrio'][value]['name'];
    },
    localidad: function(value) {
      return meg.data.references['idx']['localidad'][value]['name'];
    },
    estado_civil: function(value) {
      return meg.data.references['idx']['estado_civil'][value]['nombre'];
    },
    clasificacion_social: function(value) {
      return meg.data.references['idx']['clasificacion_social'][value]['nombre'];
    },
    evento: function(value) {
      var item;
      item = meg.data.references['idx']['evento'][value];
      return item['nombre'] + ' (' + item['fecha'] + ')';
    },
    telefonos: function(value) {
      var item, _value;
      if (value != null) {
        if (value.length > 0) {
          _value = JSON.parse(value);
          _value = [
            (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = _value.length; _i < _len; _i++) {
                item = _value[_i];
                _results.push(item['num']);
              }
              return _results;
            })()
          ];
          _value = _value.length > 0 ? _value[0] : [];
          _value = _value.join(',');
          return _value;
        }
      }
      return '';
    },
    religion: function(value) {
      if (value) {
        return values.religion[value];
      } else {
        return '';
      }
    },
    tipo_desicion: function(value) {
      if (value) {
        return values.tipo_desicion[value];
      } else {
        return '';
      }
    },
    lugar_lleno_tarjeta: function(value) {
      if (value) {
        return values.lugar_lleno_tarjeta[value];
      } else {
        return '';
      }
    }
  };

  attrs = '?f=id,nombre';

  refs_urls = [
    {
      url: 'eventos.json' + attrs,
      name: 'evento',
      attr: 'nombre'
    }
  ];

  opts_estados_llamada = [
    {
      id: '',
      text: 'Nunca se llamó'
    }
  ];

  _ref = this.values.estados_llamada;
  for (k in _ref) {
    v = _ref[k];
    opts_estados_llamada.push({
      id: k,
      text: v
    });
  }

  this.filter_fields = [
    {
      name: 'fecha',
      text: 'Fecha',
      type: 'date'
    }, {
      name: 'estado_seguimiento',
      text: 'Estado de llamada',
      type: 'opts',
      options: opts_estados_llamada
    }
  ];

  this.filter_fields_ajax = {
    'evento': {
      t: 'Evento',
      u: '/eventos.json' + attrs + ',fecha'
    },
    'clasificacion_social': {
      t: 'Clasificación social',
      u: '/clasificacionsocials.json' + attrs
    },
    'estado_civil': {
      t: 'Estado civil',
      u: '/estadosciviles.json' + attrs
    },
    'barrio': {
      t: 'Barrio',
      u: '/barrios.json?f=id,name',
      ktext: 'name'
    },
    'localidad': {
      t: 'Localidad',
      u: '/localidades.json?f=id,name&force=true',
      ktext: 'name'
    }
  };

  this.filter_fields_values = {
    'religion': 'Religión',
    'lugar_lleno_tarjeta': 'Lugar llenó tarjeta',
    'tipo_desicion': 'Tipo desición',
    'sexo': 'Sexo'
  };

  this.load_filter_fields_ajax();

  this.load_filter_fields_values();

  this.filter_fields = _.sortBy(this.filter_fields, 'text');

  $("#filters").MEGFilter({
    fields: this.filter_fields
  });

  attrs = ['id', 'ide', 'nombre', 'apellido', 'telefonos', 'direccion', 'fecha', 'evento', 'ultimo_seguimiento', 'estado_seguimiento'];

  _ref1 = this.filter_fields_ajax;
  for (k in _ref1) {
    v = _ref1[k];
    attrs.push(k);
  }

  _ref2 = this.filter_fields_values;
  for (k in _ref2) {
    v = _ref2[k];
    attrs.push(k);
  }

  this.itemsUrl = '/tarjetabienvenidas.json?f=' + attrs.join(',');

  this.beforeLoadTable = (function(_this) {
    return function(listadatos) {
      console.time('tabla');
      return _this.reloadTable(listadatos, function() {
        console.timeEnd('tabla');
        return this.bindEvents();
      });
    };
  })(this);

  this.documentReady = function(cb) {
    if (cb == null) {
      cb = null;
    }
    $('.loader').show();
    return meg.server.ajax(this.itemsUrl, {}, function(err, listadatos) {
      if (listadatos.length > 0) {
        if (meg.data == null) {
          meg.data = {};
        }
        meg.data.currentItems = listadatos;
        return async.map(refs_urls, function(ref, cb) {
          return meg.server.ajax(ref.url, {}, function(err, items) {
            var e, item, _i, _len;
            this.references[ref.name] = _.indexBy(items, 'id');
            for (_i = 0, _len = listadatos.length; _i < _len; _i++) {
              item = listadatos[_i];
              item[ref.name + '_text'] = '';
              if (item.hasOwnProperty(ref.name)) {
                try {
                  if (item[ref.name].length > 0) {
                    item[ref.name + '_text'] = this.references[ref.name][item[ref.name]][ref.attr];
                  }
                } catch (_error) {
                  e = _error;
                  item[ref.name + '_text'] = '-';
                }
              }
            }
            return cb();
          });
        }, function(err, res) {
          this.items = listadatos;
          return this.beforeLoadTable(listadatos);
        });
      } else {
        this.items = listadatos;
        return this.reloadTable(listadatos, cb);
      }
    });
  };

  $('#btn-filtrar-ult-seg').on('click', (function(_this) {
    return function() {
      var condicional, dtInit, periodo, value;
      condicional = $('#sel-flt-op').val();
      value = $('#sel-flt-value').val();
      periodo = $('#sel-flt-periodo').val();
      dtInit = Date.today();
      value = parseInt(value);
      if (periodo === 'd') {
        dtInit.addDays(-value);
      } else if (periodo === 's') {
        dtInit.addWeeks(-value);
      } else if (periodo === 'm') {
        dtInit.addMonths(-value);
      }
      $('#loader-filter').show();
      return new Parallel([meg.data.currentItems, condicional, dtInit], {
        evalPath: '/vendor/parallel/eval.js'
      }).require('/javascripts/date.js').spawn(function(params) {
        var condiciones, dtFechaSeguimiento, item, items, obj, result, _i, _len;
        items = params[0];
        condicional = params[1];
        dtInit = params[2];
        result = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if (item['ultimo_seguimiento']) {
            if (item['ultimo_seguimiento'].length > 0) {
              obj = JSON.parse(item['ultimo_seguimiento']);
              dtFechaSeguimiento = Date.parseExact(obj['fecha'], "yyyy-MM-dd");
              condiciones = {
                may: dtInit > dtFechaSeguimiento,
                men: dtInit < dtFechaSeguimiento
              };
              if (condiciones[condicional]) {
                result.push(item);
              }
            }
          }
        }
        return result;
      }).then(function(res, err) {
        meg.data.currentFiltered = res;
        _this.beforeLoadTable(res);
        return $('#loader-filter').hide();
      });
    };
  })(this));

}).call(this);
