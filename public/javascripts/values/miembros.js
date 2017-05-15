(function() {
  var t, _i, _len, _ref;

  this.values = {
    sexo: {
      m: 'Masculino',
      f: 'Femenino'
    },
    razon_alta: {
      bautismo: 'Bautismo ',
      captura_inicial: 'Captura inicial',
      carta_traslado: 'Carta traslado',
      carta_recomendacion: 'Carta recomendación',
      incorporacion: 'Incorporación',
      otro: 'Otro'
    },
    relacion_familia: {
      padre: 'Padre',
      madre: 'Madre',
      hijo: 'Hijo/a',
      abuelo: 'Abuelo/a',
      tio: 'Tío/a'
    },
    tipo_sangre: {}
  };

  _ref = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    t = _ref[_i];
    this.values.tipo_sangre[t] = t;
  }

}).call(this);
