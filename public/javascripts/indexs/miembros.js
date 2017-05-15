(function() {
  var attrs, filter, k, showName, v, _i, _len, _ref, _ref1, _ref2;

  showName = function(ide, nom, ap) {
    var value;
    value = '';
    if (nom.length > 0) {
      value = nom;
    }
    if (ap.length > 0) {
      value = nom + ' ' + ap;
    }
    return '<a href="/miembros/' + ide + '">' + value + '</a>';
  };

  this.listaordenada = function() {
    return [
      {
        name: "ide",
        showname: "#"
      }, {
        name: "nombre",
        showname: "Nombre y Apellido",
        params: ["id", "nombre", "apellido"],
        parser: showName,
        parser: function(id, n, ap) {
          var name;
          name = '';
          if (n.length > 0) {
            name += ' ' + n;
          }
          if (ap.length > 0) {
            name += ' ' + ap;
          }
          return '<a class="tname" href="/miembros/' + id + '">' + name + '</a>';
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
    familia: function(value) {
      return meg.data.references['idx']['familia'][value]['nombre'];
    },
    estado_civil: function(value) {
      return meg.data.references['idx']['estado_civil'][value]['nombre'];
    },
    pertenece_gc: function(value) {
      return meg.data.references['idx']['pertenece_gc'][value]['nro'];
    },
    clasificacion_social: function(value) {
      return meg.data.references['idx']['clasificacion_social'][value]['nombre'];
    },
    estado_membresia: function(value) {
      return meg.data.references['idx']['estado_membresia'][value]['nombre'];
    },
    relacion_familia: function(value) {
      if (value) {
        return values.relacion_familia[value];
      } else {
        return '';
      }
    },
    razon_alta: function(value) {
      if (value) {
        return values.razon_alta[value];
      } else {
        return '';
      }
    },
    emails: function(value) {
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
                _results.push(item['email']);
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
    ministerio: function(value) {
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
                _results.push(meg.data.references['idx']['ministerio'][item['ministerio']]['nombre']);
              }
              return _results;
            })()
          ];
          _value = _value.length > 0 ? _value[0] : [];
          _value = _value.join(', ');
          return _value;
        }
      }
      return '';
    }
  };

  attrs = '?f=id,nombre';

  this.filter_fields = [
    {
      name: 'bautizado_por_inmersion',
      text: 'Bautizado por inmersión',
      type: 'bool'
    }, {
      name: 'bautizado_en_esta_iglesia',
      text: 'Bautizado en esta iglesia',
      type: 'bool'
    }
  ];

  this.filter_fields_ajax = {
    'familia': {
      t: 'Familia',
      u: '/familias.json' + attrs
    },
    'clasificacion_social': {
      t: 'Clasificación social',
      u: '/clasificacionsocials.json' + attrs
    },
    'estado_civil': {
      t: 'Estado civil',
      u: '/estadosciviles.json' + attrs
    },
    'estado_membresia': {
      t: 'Estado membresía',
      u: '/estadomembresias.json' + attrs
    },
    'barrio': {
      t: 'Barrio',
      u: '/barrios.json?f=id,name',
      ktext: 'name' + '&force=true'
    },
    'localidad': {
      t: 'Localidad',
      u: '/localidades.json?f=id,name&force=true',
      ktext: 'name' + '&force=true'
    },
    'pertenece_gc': {
      t: 'Grupo al que pertenece',
      u: '/grupocrecimientos.json?f=id,nro',
      ktext: 'nro'
    },
    'ministerio': {
      t: 'Ministerio',
      u: '/ministerios.json' + attrs,
      json: true
    }
  };

  this.filter_fields_values = {
    'tipo_sangre': 'Tipo de sangre',
    'razon_alta': 'Razón alta',
    'sexo': 'Sexo'
  };

  this.load_filter_fields_ajax();

  this.load_filter_fields_values();

  this.filter_fields = _.sortBy(this.filter_fields, 'text');

  $("#filters").MEGFilter({
    fields: this.filter_fields
  });

  attrs = ['id', 'ide', 'nombre', 'apellido'];

  _ref = this.filter_fields;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    filter = _ref[_i];
    attrs.push(filter.name);
  }

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

  this.itemsUrl = '/miembros.json?f=' + attrs.join(',');

}).call(this);
