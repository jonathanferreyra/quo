(function() {
  var gui_things;

  +(gui_things = {});


  /** @expose */

  gui_things.instanceTelefonosSimpleTable = function(model_id, data) {
    var options, sel_telefonos, _mode;
    if (data == null) {
      data = null;
    }
    _mode = 'edit';
    if (typeof data === 'string') {
      _mode = 'show';
    }
    options = {
      mode: _mode,
      btAddClass: 'btn btn-default btn-sm',
      fillAllRow: true,
      columns: [
        {
          name: 'tipo',
          display: 'Tipo',
          type: 'select',
          keyId: 'id',
          keyText: 'text',
          options: defaults.get('telefonos')
        }, {
          name: 'num',
          display: 'Número',
          type: 'tel'
        }
      ]
    };
    if (_mode === 'edit') {
      sel_telefonos = model_id + 'telefonos';
      if ($(sel_telefonos).val().length > 0) {
        options.data = JSON.parse($(sel_telefonos).val());
      }
      return $('#div-telefonos').MEGSimpleTable(options);
    } else if (_mode === 'show') {
      if ((data.length > 0) && (data !== '[]')) {
        options.data = JSON.parse(data);
        return $('#div-telefonos').MEGSimpleTable(options);
      } else {
        return $('#div-telefonos').append('<div class="callout callout-info">No hay datos para mostrar.</div>');
      }
    }
  };


  /** @expose */

  gui_things.instanceEmailsSimpleTable = function(model_id, data) {
    var options, sel, _mode;
    if (data == null) {
      data = null;
    }
    _mode = 'edit';
    if (typeof data === 'string') {
      _mode = 'show';
    }
    options = {
      mode: _mode,
      btAddClass: 'btn btn-default btn-sm',
      columns: [
        {
          name: 'email',
          display: 'Email',
          type: 'text',
          placeholder: 'nombreusuario@dominio.com'
        }
      ]
    };
    if (_mode === 'edit') {
      sel = model_id + 'emails';
      if ($(sel).val().length > 0) {
        options.data = JSON.parse($(sel).val());
      }
      return $('#div-emails').MEGSimpleTable(options);
    } else if (_mode === 'show') {
      if ((data.length > 0) && (data !== '[]')) {
        options.data = JSON.parse(data);
        return $('#div-emails').MEGSimpleTable(options);
      } else {
        return $('#div-emails').append('<div class="callout callout-info">No hay datos para mostrar.</div>');
      }
    }
  };

  gui_things.calculateAge = function(dateString) {
    var birthday;
    birthday = +new Date(dateString);
    return ~~((Date.now() - birthday) / 31557600000.);
  };

  this["gui_things"] = gui_things;

}).call(this);
