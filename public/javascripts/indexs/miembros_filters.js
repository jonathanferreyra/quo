(function() {
  var attrs;

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
      ktext: 'name'
    },
    'localidad': {
      t: 'Localidad',
      u: '/localidades.json?f=id,name',
      ktext: 'name'
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

}).call(this);
