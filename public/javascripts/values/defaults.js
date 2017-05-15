(function() {
  this.defaults = {
    telefonos: {
      principal: 'Principal',
      movil: 'Móvil',
      casa: 'Casa',
      trabajo: 'Trabajo',
      fax: 'Fax',
      otro: 'Otro'
    },
    redes_sociales: {
      facebook: 'Facebook',
      gplus: 'Google +',
      twitter: 'Twitter',
      skype: 'Skype',
      pinterest: 'Pinterest',
      youtube: 'Youtube'
    },
    dias_semanales: {
      lun: 'Lunes',
      mar: 'Martes',
      mie: 'Miércoles',
      jue: 'Jueves',
      vie: 'Viernes',
      sab: 'Sábado',
      dom: 'Domingo'
    },
    sexo: {
      m: 'Masculino',
      f: 'Femenino'
    },
    days: {
      Mon: 'Lunes',
      Tue: 'Martes',
      Wed: 'Miércoles',
      Thu: 'Jueves',
      Fri: 'Viernes',
      Sat: 'Sábado',
      Sun: 'Domingo'
    },
    months: {
      Jan: 'Enero',
      Feb: 'Febrero',
      Mar: 'Marzo',
      Apr: 'Abril',
      May: 'Mayo',
      Jun: 'Junio',
      Jul: 'Julio',
      Aug: 'Agosto',
      Sep: 'Septiembre',
      Oct: 'Octubre',
      Nov: 'Noviembre',
      Dec: 'Diciembre'
    },
    get: function(attr, keyId, keyText) {
      var item, k, result, v, _ref;
      if (keyId == null) {
        keyId = 'id';
      }
      if (keyText == null) {
        keyText = 'text';
      }
      result = [];
      _ref = this[attr];
      for (k in _ref) {
        v = _ref[k];
        item = {};
        item[keyId] = k;
        item[keyText] = v;
        result.push(item);
      }
      return result;
    }
  };

}).call(this);
