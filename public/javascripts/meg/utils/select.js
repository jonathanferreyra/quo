
/**
@license MEG select vs 1.5
Informatica MEG - 2014 Todos los derechos reservados
 */

(function() {
  var select;

  select = {};


  /** @expose */

  select.onlyLoad = function(widgetname, data, id, showname, empty, cb) {
    var item, msg, options, postoptiontag, preoptiontag, _i, _len;
    if (JSON.stringify(data) !== "[]") {
      msg = "[Seleccionar]";
    } else {
      msg = "[Sin elementos]";
    }
    preoptiontag = "<option value=";
    postoptiontag = "</option>";
    options = '';
    if (empty) {
      options = "" + preoptiontag + "''>" + msg + postoptiontag;
    }
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      item = data[_i];
      options += "" + preoptiontag + item[id] + ">" + item[showname] + postoptiontag;
    }
    $(widgetname).empty().append(options);
    return cb(0);
  };

  select.makeSelect2 = function(widgetname, cb) {
    if (cb == null) {
      cb = (function() {});
    }
    if ($(widgetname)["select2"] != null) {
      $(widgetname)["select2"]();
      $('.select2-container')["removeClass"]('form-control')["css"]('width', '100%');
      return cb(0);
    } else {
      return cb(1);
    }
  };

  select.setID = function(widgetname, id, cb) {
    if (cb == null) {
      cb = (function() {});
    }
    $(widgetname)["val"](id);
    return cb(0);
  };


  /** @expose */

  select.load = function(widgetname, data, opts, cb) {
    var defaultsOptions;
    if (opts == null) {
      opts = {};
    }
    if (cb == null) {
      cb = (function() {});
    }
    defaultsOptions = {
      'id': 'id',
      'showname': 'nombre',
      'select2': typeof window.orientation !== "undefined" ? true : false,
      'empty': true
    };
    opts = $.extend(defaultsOptions, opts);
    return select.onlyLoad(widgetname, data, opts["id"], opts["showname"], opts.empty, function(err) {
      if (opts["default"] != null) {
        select.setID(widgetname, opts["default"]);
      }
      if (opts["select2"]) {
        select.makeSelect2(widgetname);
      }
      return cb(0);
    });
  };

  select.loadMultiple = function(selector, _data, callback) {
    if (typeof _ !== 'undefined') {
      _data = _.sortBy(_data, 'text');
    }
    $(selector).select2({
      formatNoMatches: function(term) {
        return "No se encontraron coincidencias";
      },
      createSearchChoice: function(term, data) {
        if ($(data).filter(function() {
          return this.text.localeCompare(term) === 0;
        }).length === 0) {
          return {
            id: term,
            text: term
          };
        }
      },
      data: _data,
      multiple: true
    });
    if (callback) {
      return callback();
    }
  };

  select.loadMultipleEdit = function(selector, preload_data, callback) {
    var item, _data, _i, _len;
    if (preload_data) {
      _data = {};
      for (_i = 0, _len = preload_data.length; _i < _len; _i++) {
        item = preload_data[_i];
        _data[item.id] = item.text;
      }
      $(selector).select2({
        data: preload_data,
        multiple: true,
        formatNoMatches: function(term) {
          return "No se encontraron coincidencias";
        },
        initSelection: (function(element, callback) {
          var current, data, elements, _j, _len1;
          data = [];
          if (element.val() !== "") {
            elements = element.val().split(",");
            for (_j = 0, _len1 = elements.length; _j < _len1; _j++) {
              current = elements[_j];
              data.push({
                id: current,
                text: _data[current]
              });
            }
          }
          return callback(data);
        })
      });
      $('.select2-container').removeClass('form-control');
      return $('.select2-container').css('width', '100%');
    }
  };

  if (this["meg"] == null) {
    this["meg"] = {};
  }

  this["meg"]["select"] = select;

}).call(this);
