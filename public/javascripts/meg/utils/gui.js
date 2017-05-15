
/**
@license MEG GUI vs 1.1
Informatica MEG - 2014 Todos los derechos reservados
 */

(function() {
  var gui;

  gui = {};


  /** @expose */

  gui.showRefName = function(url, showname, itemId, sel, href, cb) {
    var _url;
    if (href == null) {
      href = false;
    }
    if (cb == null) {
      cb = null;
    }
    if (typeof itemId !== 'undefined' && itemId !== null) {
      if (itemId.length > 0) {
        _url = '/' + url + '/' + itemId + '.json?f=id,' + showname;
        return meg.server.ajax(_url, {}, function(err, item) {
          var a, text;
          if (item) {
            a = '{text}';
            if (href === true) {
              a = '<a href="#">{text}</a>';
              a = a.replace('#', '/' + url + '/' + item.id);
            }
            if (item.hasOwnProperty(showname)) {
              text = item[showname];
            } else {
              text = '';
            }
            a = a.replace('{text}', text);
            $(sel).append(a);
          }
          if (cb) {
            return cb(err, text);
          }
        });
      } else {
        if (cb) {
          return cb(null, null);
        }
      }
    } else {
      if (cb) {
        return cb(null, null);
      }
    }
  };


  /** @expose */

  gui.showFromValueName = function(sel, values, def_value) {
    if (typeof def_value !== 'undefined' && def_value !== null) {
      if (def_value.length > 0) {
        return $(sel).text(values[def_value]);
      }
    }
  };


  /** @expose */

  gui.loadSelect = function(url, attr, def_value, opts, cb) {
    var ajaxOpts, showLoader, showname, spinId, successCb;
    if (opts == null) {
      opts = {};
    }
    if (cb == null) {
      cb = null;
    }
    opts.select2 = false;
    showname = 'nombre';
    showLoader = true;
    if (opts.showname) {
      showname = opts.showname;
    }
    if (def_value.length > 0) {
      opts["default"] = def_value;
    }
    if (opts.loader) {
      showLoader = opts.loader;
    }
    successCb = function(err, items) {
      if (typeof _ !== 'undefined') {
        items = _.sortBy(items, showname);
      }
      return meg.select.load(attr, items, opts, function() {
        if (cb) {
          return cb();
        }
      });
    };
    spinId = 'spin_' + attr.replace('#', '').replace('.', '');
    ajaxOpts = {
      "dataType": 'json',
      "async": true,
      beforeSend: function() {
        var t;
        if (showLoader) {
          t = attr.replace('#', '').replace('.', '');
          return $('label[for=' + t + ']').append(' <i class="fa fa-spinner fa-spin" id="' + spinId + '"></>');
        }
      },
      success: function(data) {
        if (showLoader) {
          $('#' + spinId).remove();
        }
        if (data) {
          if (data.code) {
            return successCb(0, data.data);
          } else {
            return successCb(0, data);
          }
        } else {
          console.log("NOT DATA EXIST");
          return successCb(1, null);
        }
      }
    };
    return $.ajax(url, ajaxOpts);
  };


  /** @expose */

  gui.loadChainedSelect = function(opts, cb) {
    var def_opts;
    if (cb == null) {
      cb = null;
    }
    def_opts = {
      to_key_attr: 'id',
      to_chain_attr: opts.from_attr,
      to_text_attr: 'nombre'
    };
    opts = $.extend(def_opts, opts);
    meg.gui.loadSelect(opts.from_url, opts.from_select, opts.from_def_value, function() {});
    return meg.server.ajax(opts.to_url, {}, function(err, items) {
      var item, options, _i, _len;
      if (typeof _ !== 'undefined') {
        items = _.sortBy(items, 'nombre');
      }
      options = '<option value="">[Seleccionar]</option>';
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        options += '<option value="' + item[opts.to_key_attr] + '" class="' + item[opts.to_chain_attr] + '">' + item[opts.to_text_attr] + '</option>';
      }
      $(opts.to_select).empty().append(options);
      $(opts.to_select).chained(opts.from_select);
      if (opts.to_def_value.length > 0) {
        $(opts.to_select).val(opts.to_def_value);
      }
      if (cb) {
        return cb();
      }
    });
  };


  /** @expose */

  gui.loadSelectFromValues = function(values, attr, def_value, empty, cb) {
    var items, k, opts, v;
    if (empty == null) {
      empty = true;
    }
    if (cb == null) {
      cb = null;
    }
    opts = {
      showname: 'text',
      select2: false,
      empty: empty
    };
    items = [];
    for (k in values) {
      v = values[k];
      items.push({
        id: k,
        text: v
      });
    }
    if (def_value.length > 0) {
      opts["default"] = def_value;
    }
    return meg.select.load(attr, items, opts, function() {
      if (cb) {
        return cb();
      }
    });
  };


  /** @expose */

  gui.loadSelectCustomText = function(url, attr, def_value, customFn, cb) {
    var opts;
    if (cb == null) {
      cb = null;
    }
    opts = {
      showname: 'text'
    };
    if (def_value.length > 0) {
      opts["default"] = def_value;
    }
    return meg.server.ajax(url, {}, function(err, items) {
      var item, _i, _len;
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        item.text = customFn(item);
      }
      return meg.select.load(attr, items, opts, function() {});
    });
  };


  /** @expose */

  gui.getURLParameters = function() {
    var res, sPageURL, sParameter, sURLVariables, urlVar, _i, _len;
    sPageURL = window.location.search.substring(1);
    sURLVariables = sPageURL.split('&');
    res = {};
    for (_i = 0, _len = sURLVariables.length; _i < _len; _i++) {
      urlVar = sURLVariables[_i];
      sParameter = urlVar.split('=');
      res[sParameter[0]] = sParameter[1];
    }
    return res;
  };


  /** @expose */

  gui.loadGeographicsSelects = function(defValues, callback) {
    var provinciaSelector;
    if (callback == null) {
      callback = null;
    }
    provinciaSelector = '#provincia';
    if (defValues.provinciaSelector) {
      provinciaSelector = defValues.provinciaSelector;
    }
    return async.waterfall([
      function(cb) {
        if (defValues.localidad.length > 0) {
          return meg.server.ajax('/localidades/' + defValues.localidad + '.json', {}, function(err, item) {
            if (item) {
              defValues.provincia = item.provincia;
              return cb(err, defValues);
            } else {
              return cb(null, defValues);
            }
          });
        } else {
          return cb(null, defValues);
        }
      }, function(defValues, cb) {
        $(provinciaSelector).on('change', function() {
          return meg.gui.loadSelect('/localidades.json?f=id,name&q=' + JSON.stringify({
            provincia: $(this).val()
          }), defValues.model_id + 'localidad', defValues.localidad, {
            showname: 'name'
          }, function() {
            $(defValues.model_id + 'localidad').on('change', function() {
              return meg.gui.loadSelect('/barrios.json?f=id,name&q=' + JSON.stringify({
                localidad: $(this).val()
              }), defValues.model_id + 'barrio', defValues.barrio, {
                showname: 'name'
              }, function() {});
            });
            if (defValues.localidad.length > 0) {
              return $(defValues.model_id + 'localidad').trigger('change');
            }
          });
        });
        return meg.gui.loadSelect('/provincias.json?f=id,name', provinciaSelector, defValues.provincia, {
          showname: 'name'
        }, function() {
          if (defValues.provincia.length > 0) {
            $(provinciaSelector).trigger('change');
          }
          return cb(null, null);
        });
      }
    ], function() {
      if (callback) {
        return callback();
      }
    });
  };

  if (this["meg"] == null) {
    this["meg"] = {};
  }

  this["meg"]["gui"] = gui;

}).call(this);
