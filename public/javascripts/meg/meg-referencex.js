(function() {
  (function($) {
    var methods, _defaultInitOptions, _genFields, _store, _utilVars, _validateFieldsGUI;
    _defaultInitOptions = {
      title: 'Nuevo',
      fields: [],
      postUrl: '',
      selectRefSelector: '',
      selectRefFn: function() {},
      execOnShown: null
    };
    _utilVars = {
      modalTemplate: '<div id="{id}" class="modal" aria-hidden="true" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"> <div class="modal-dialog"> <div class="modal-content"> <div class="modal-header"> <button type="button" data-dismiss="modal" aria-hidden="true" class="close">×</button> <h3 class="modal-title" id="myModalLabel">{title}</h3> </div> <div class="modal-body"> <form id="{form-id}"> {fields} </form> </div> <div class="modal-footer"> <button type="button" data-dismiss="modal" class="btn btn-default">Cancelar</button> <button type="button" id="MEGRef-btn-{btn-save}" class="btn btn-primary btn-lg">Guardar</button> </div> </div> </div> </div>',
      formGroupTmpl: '<div class="form-group"><label for="{id}" class="control-label">{text}</label>{widget}</div>',
      inputTemplate: '<input name="{name}" id="{id}" class="form-control" type="text">',
      textareaTemplate: '<textarea name="{name}" id="{id}" class="form-control" type="text", rows="4"></textarea>',
      selectTemplate: '<select name="{name}" id="{id}" class="form-control"></select>'
    };
    methods = {
      init: function(options) {
        var mdTemplate, settings;
        settings = $.extend({}, _defaultInitOptions, _utilVars, options);
        settings.modalId = $(this).selector.replace('#', '').replace('.', '');
        settings.modalName = 'MEGRef-md-' + settings.modalId;
        mdTemplate = settings.modalTemplate;
        $(this).on('click', function() {
          $(this).attr({
            'href': '#',
            'data-toggle': "modal",
            'data-target': "#" + settings.modalName
          });
          mdTemplate = mdTemplate.replace('{title}', settings.title).replace('{id}', settings.modalName).replace('{btn-save}', settings.modalId).replace('{form-id}', 'MEGRef-form-' + settings.modalId).replace('{fields}', _genFields(settings));
          $('form').append(mdTemplate);
          $('#' + settings.modalName).on('shown.bs.modal', function() {
            var f, opts, selId, _i, _len, _ref, _results;
            _ref = settings.fields;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              f = _ref[_i];
              if (f.field === 'select') {
                selId = '#' + settings.modalName + '_' + f.name;
                opts = {
                  id: f.attrs.keyId,
                  showname: f.attrs.keyText
                };
                _results.push(meg.server.ajax(f.attrs.url, {}, function(err, items) {
                  if (typeof _ !== 'undefined') {
                    items = _.sortBy(items, opts.showname);
                  }
                  return meg.select.load(selId, items, opts, function() {
                    if (settings.execOnShown !== null) {
                      if (typeof settings.execOnShown === 'function') {
                        return settings.execOnShown();
                      }
                    }
                  });
                }));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
          $('#' + settings.modalName).modal('show');
          $('#MEGRef-btn-' + settings.modalId).on('click', function() {
            return _validateFieldsGUI(settings, function(ok) {
              if (ok) {
                return _store(settings);
              }
            });
          });
          return $('#' + settings.modalName).on('hidden.bs.modal', function() {
            return $('#' + settings.modalName).off('shown.bs.modal').remove();
          });
        });
        return $(this).data('settings', settings);
      }
    };
    _genFields = function(settings) {
      var field, iid, result, row, types, w, _i, _len, _ref;
      result = '';
      _ref = settings.fields;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        iid = settings.modalName + '_' + field.name;
        row = settings.formGroupTmpl;
        row = row.replace('{text}', field.text).replace('{id}', iid);
        types = {
          'input': settings.inputTemplate,
          'select': settings.selectTemplate,
          'textarea': settings.textareaTemplate
        };
        w = types[field.field];
        if (field.attrs) {
          w = $(w).attr(field.attrs);
          w = $(w)[0].outerHTML;
        }
        w = w.replace('{id}', iid).replace('{name}', field.name);
        row = row.replace('{widget}', $(w)[0].outerHTML);
        result += row;
      }
      return result;
    };
    _store = function(settings) {
      var data, f, fields, _i, _len;
      fields = $('form#MEGRef-form-' + settings.modalId).serializeArray();
      data = {};
      for (_i = 0, _len = fields.length; _i < _len; _i++) {
        f = fields[_i];
        data[f.name] = f.value;
      }
      data.authenticity_token = $("meta[name=csrf-token]").attr("content");
      return $.post(settings.postUrl, data).done(function(data, textStatus, jqXHR) {
        $("#" + settings.modalName).modal('hide');
        return settings.selectRefFn(data['data']['id']);
      }).fail(function(jqXHR, textStatus, errorThrown) {
        console.log('MEGReferencex ERROR: ', jqXHR, textStatus, errorThrown);
        alert('Se produjo un error al intentar crear el elemento.');
        return $("#" + settings.modalName).modal('hide');
      });
    };
    _validateFieldsGUI = function(settings, cb) {
      var f, fields_gui, idxFieldsGUI, valid, _i, _j, _len, _len1, _ref;
      valid = true;
      fields_gui = $('form#MEGRef-form-' + settings.modalId).serializeArray();
      idxFieldsGUI = {};
      for (_i = 0, _len = fields_gui.length; _i < _len; _i++) {
        f = fields_gui[_i];
        idxFieldsGUI[f.name] = f.value;
      }
      _ref = settings.fields;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        f = _ref[_j];
        if (f.hasOwnProperty('attrs')) {
          if (f.attrs.hasOwnProperty('required')) {
            if (idxFieldsGUI[f.name].length === 0) {
              $('#' + settings.modalName + '_' + f.name).parent().addClass('has-error');
              valid = false;
            }
          }
        }
      }
      return cb(valid);
    };
    return $.fn.MEGReferencex = function(methodOrOptions) {
      if (methods[methodOrOptions]) {
        return methods[methodOrOptions].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof methodOrOptions === "object" || !methodOrOptions) {
        return methods.init.apply(this, arguments);
      } else {
        return $.error("Method " + methodOrOptions + " does not exist");
      }
    };
  })(jQuery);

}).call(this);
