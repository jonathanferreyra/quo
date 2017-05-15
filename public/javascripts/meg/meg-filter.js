(function() {
  (function($) {
    var methods, _base_operators, _defaultInitOptions, _genFilterOptions, _genOptValues, _genOptions, _genRowfilter, _getFilters, _getOperators, _utilVars;
    _base_operators = {
      es: {
        igual: [
          {
            op: '=',
            text: 'igual'
          }, {
            op: '!',
            text: 'no igual'
          }
        ],
        entre: [
          {
            op: '=',
            text: 'igual'
          }, {
            op: '>=',
            text: 'mayor o igual'
          }, {
            op: '<=',
            text: 'menor o igual'
          }
        ]
      },
      en: {
        igual: [
          {
            op: '=',
            text: 'equal'
          }, {
            op: '!',
            text: 'not equal'
          }
        ],
        entre: [
          {
            op: '=',
            text: 'equal'
          }, {
            op: '>=',
            text: 'major or equal'
          }, {
            op: '<=',
            text: 'minor or equal'
          }
        ]
      }
    };
    _defaultInitOptions = {
      fields: [],
      lang: 'es',
      filter_caption: {
        es: 'Añadir filtro',
        en: 'Add filter'
      },
      operators: {
        es: {
          ajax: _base_operators['es']['igual'],
          opts: _base_operators['es']['igual'],
          bool: _base_operators['es']['igual'],
          number: _base_operators['es']['entre'],
          date: _base_operators['es']['entre'],
          time: _base_operators['es']['entre']
        },
        en: {
          ajax: _base_operators['en']['igual'],
          opts: _base_operators['en']['igual'],
          bool: _base_operators['en']['igual'],
          number: _base_operators['en']['entre'],
          date: _base_operators['en']['entre'],
          time: _base_operators['en']['entre']
        }
      }
    };
    _utilVars = {
      main_template: '<div class="row"> <div class="col-md-12"> <div class="col-md-8 list-filters"></div> <div class="col-md-4 add-filter"> <form class="form-inline"> <label for="add_filter_select">{filter_caption}</label> <select id="add_filter_select" class="form-control"> <option></option> {filters} </select> </form> </div> </div> </div>',
      sample_filter: '<div id="{filter_id}" class="row filter"> <div class="col-md-4 field"> <div class="checkbox"> <label for="{filter_id}"> <input id="{filter_id}" name="{filter_id}" type="checkbox" checked="checked">{filter_name} </label> </div> </div> <div class="col-md-4 operator"> {operator} </div> <div class="col-md-4 values"> {values} </div> </div>',
      select_operator: '<select id="op_{filter_id}" class="form-control">{opts}</select>',
      select_values: '<select id="val_{filter_id}" class="form-control">{opts}</select>',
      input_values: '<input id="val_{filter_id}" class="form-control" type="{type}">'
    };
    methods = {
      init: function(options) {
        var f, filters, settings, target, tbWhole, template, _i, _len, _ref;
        settings = $.extend({}, _defaultInitOptions, _utilVars, options);
        settings.fieldsByName = {};
        _ref = settings.fields;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          f = _ref[_i];
          settings.fieldsByName[f.name] = f;
        }
        target = this;
        if (target.length > 0) {
          tbWhole = target[0];
          $(tbWhole).data('settings', settings);
          template = settings.main_template;
          $('.filter-loader').addClass('hide');
          filters = _genFilterOptions(tbWhole);
          template = template.replace('{filter_caption}', settings.filter_caption[settings.lang]);
          template = template.replace('{filters}', filters);
          $(tbWhole).empty().append(template);
          return $('#add_filter_select').on('click', function() {
            var field;
            field = $(this).val();
            if (field.length > 0) {
              $('#add_filter_select option:selected').attr('disabled', true);
              $(this).val('');
              return _genRowfilter(tbWhole, field, function(html) {
                $('.list-filters').append(html);
                return $('.checkbox').on('change', function() {
                  var _element, _name;
                  _element = $(this).find('input');
                  _name = _element.attr('name');
                  if (_element.is(':checked')) {
                    return $('#op_' + _name + ', #val_' + _name).show();
                  } else {
                    return $('#op_' + _name + ', #val_' + _name).hide();
                  }
                });
              });
            }
          });
        }
      },
      getFilters: function() {
        return _getFilters();
      },
      getValue: function(key) {
        var settings;
        settings = $(this).data('settings');
        if (settings[key]) {
          return settings[key];
        } else {
          return null;
        }
      },
      filterData: function(rows) {
        var condition, fields, filters, operator, results, settings, taffyQuery, values, _f, _false, _i, _len, _true;
        if (typeof TAFFY === 'undefined') {
          throw new Error('taffy not found');
        } else {
          settings = $(this).data('settings');
          fields = _.indexBy(settings.fields, 'name');
          filters = _getFilters();
          results = rows;
          taffyQuery = {};
          for (_i = 0, _len = filters.length; _i < _len; _i++) {
            _f = filters[_i];
            if (!fields[_f.field].hasOwnProperty('json')) {
              if (fields[_f.field].type === 'bool') {
                _true = [1, true, 'true', '1'];
                _false = [0, false, 'false', '0'];
                values = _f.value === '1' ? _true : _false;
                operator = _f.operator === '=' ? 'is' : '!is';
                condition = {};
                condition[operator] = values;
                taffyQuery[_f.field] = condition;
              } else {
                if (_f.operator === '=') {
                  taffyQuery[_f.field] = {
                    'is': _f.value
                  };
                } else if (_f.operator === '!') {
                  taffyQuery[_f.field] = {
                    '!is': _f.value
                  };
                }
              }
            } else {
              operator = _f.operator === '=' ? 'like' : '!like';
              condition = {};
              condition[operator] = _f.value;
              taffyQuery[_f.field] = condition;
            }
          }
          return results = TAFFY(rows)().filter(taffyQuery).get();
        }
      }
    };
    _getFilters = function() {
      var checked, dom, f, filters, row, settings, value, _i, _len;
      settings = $(this).data('settings');
      dom = $('.list-filters .filter');
      filters = [];
      if ($(dom).length > 0) {
        for (_i = 0, _len = dom.length; _i < _len; _i++) {
          f = dom[_i];
          checked = $(f).find('.field .checkbox input').is(':checked');
          if (checked) {
            row = {};
            row.field = $(f).attr('id');
            row.operator = $(f).find('.operator select').val();
            value = $(f).find('.values select').val();
            if (value === void 0) {
              value = $(f).find('.values input').val();
            }
            row.value = value;
            filters.push(row);
          }
        }
      }
      return filters;
    };
    _genFilterOptions = function(tbWhole) {
      var f, fields, result, settings, _i, _len;
      settings = $(tbWhole).data('settings');
      fields = settings.fields;
      result = '';
      for (_i = 0, _len = fields.length; _i < _len; _i++) {
        f = fields[_i];
        result += '<option value="' + f.name + '">' + f.text + '</option>';
      }
      return result;
    };
    _genRowfilter = function(tbWhole, field, cb) {
      var filter, html, html_op, options, settings;
      settings = $(tbWhole).data('settings');
      filter = settings.fieldsByName[field];
      html = settings.sample_filter;
      while (html.indexOf('{filter_id}') !== -1) {
        html = html.replace('{filter_id}', filter.name);
      }
      html = html.replace('{filter_name}', filter.text);
      html_op = settings.select_operator;
      html_op = html_op.replace('{filter_id}', filter.name);
      options = _genOptions(_getOperators(tbWhole, filter.type));
      html_op = html_op.replace('{opts}', options);
      html = html.replace('{operator}', html_op);
      return _genOptValues(tbWhole, filter, function(values) {
        var html_values, _ref, _ref1;
        if (filter.empty) {
          values += '<option value="">[Sin especificar]</option>';
        }
        if ((_ref = filter.type) === 'ajax' || _ref === 'opts' || _ref === 'bool') {
          html_values = settings.select_values;
          html_values = html_values.replace('{opts}', values);
        } else if ((_ref1 = filter.type) === 'number' || _ref1 === 'date' || _ref1 === 'time') {
          html_values = settings.input_values;
          html_values = html_values.replace('{type}', filter.type);
        }
        html_values = html_values.replace('{filter_id}', filter.name);
        html = html.replace('{values}', html_values);
        return cb(html);
      });
    };
    _getOperators = function(tbWhole, type) {
      var settings;
      settings = $(tbWhole).data('settings');
      return settings.operators[settings.lang][type];
    };
    _genOptions = function(options, keyId, keyText, sort) {
      var opt, result, _i, _len;
      if (keyId == null) {
        keyId = 'op';
      }
      if (keyText == null) {
        keyText = 'text';
      }
      if (sort == null) {
        sort = true;
      }
      result = '';
      if (sort) {
        if (typeof _ !== 'undefined') {
          options = _.sortBy(options, keyText);
        }
      }
      for (_i = 0, _len = options.length; _i < _len; _i++) {
        opt = options[_i];
        result += '<option value="' + opt[keyId] + '">' + opt[keyText] + '</option>';
      }
      return result;
    };
    _genOptValues = function(tbWhole, filter, cb) {
      var defOpts, opts, settings, sortItems, _ref;
      settings = $(tbWhole).data('settings');
      if (filter.type === 'opts') {
        sortItems = filter.hasOwnProperty('sort') ? filter.sort : true;
        cb(_genOptions(filter.options, 'id', 'text', sortItems));
      } else if (filter.type === 'ajax') {
        defOpts = {
          dataType: 'json',
          async: true
        };
        $.ajax($.extend(defOpts, filter.ajaxSettings)).done(function(res) {
          if (filter.ajaxSettings.doneFn) {
            return filter.ajaxSettings.doneFn(res, function(_res) {
              return cb(_genOptions(_res, filter.keyId, filter.keyText));
            });
          } else {
            return cb(_genOptions(res, filter.keyId, filter.keyText));
          }
        });
      } else if ((_ref = filter.type) === 'number' || _ref === 'date' || _ref === 'time') {
        cb(null);
      }
      if (filter.type === 'bool') {
        opts = [
          {
            op: 1,
            text: 'SI'
          }, {
            op: 0,
            text: 'NO'
          }
        ];
        return cb(_genOptions(opts, 'op', 'text', false));
      }
    };
    return $.fn.MEGFilter = function(methodOrOptions) {
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
