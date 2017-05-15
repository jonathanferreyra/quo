(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  this.filter_fields = [];

  this.filter_fields_ajax = {};

  this.filter_fields_values = {};

  this.references = {};

  this.load_filter_fields_ajax = function() {
    var opts, _attrs, _id, _name, _ref, _results, _text;
    if (this.filter_fields_ajax) {
      _ref = this.filter_fields_ajax;
      _results = [];
      for (_name in _ref) {
        _attrs = _ref[_name];
        _id = _attrs.kid ? _attrs.kid : "id";
        _text = _attrs.ktext ? _attrs.ktext : "nombre";
        opts = {
          name: _name,
          text: _attrs.t,
          type: "ajax",
          empty: _attrs.hasOwnProperty('e') ? _attrs.e : true,
          ajaxSettings: {
            url: _attrs.u,
            doneFn: function(res, cb) {
              return cb(res.data);
            }
          },
          keyId: _id,
          keyText: _text
        };
        if (_attrs.hasOwnProperty('json')) {
          opts.json = _attrs.json;
        }
        _results.push(this.filter_fields.push(opts));
      }
      return _results;
    }
  };

  this.load_filter_fields_values = function() {
    var k, opts, v, _name, _ref, _results, _text, _values;
    if (this.filter_fields_values) {
      _ref = this.filter_fields_values;
      _results = [];
      for (_name in _ref) {
        _text = _ref[_name];
        _values = values[_name];
        opts = [];
        for (k in _values) {
          v = _values[k];
          opts.push({
            id: k,
            text: v.replace('...', '')
          });
        }
        _results.push(this.filter_fields.push({
          name: _name,
          text: _text,
          type: 'opts',
          options: opts
        }));
      }
      return _results;
    }
  };

  this.fnFilterData = function(rows, filters, fields) {
    var equals, field, fn_is_type, not_equals, op_is, results, value, _f, _i, _j, _len, _len1, _ref, _type, _types;
    if (filters == null) {
      filters = null;
    }
    if (fields == null) {
      fields = null;
    }
    if (!fields) {
      fields = $('#filters').MEGFilter('getValue', 'fields');
    }
    if (!filters) {
      filters = $('#filters').MEGFilter('getFilters');
    }
    equals = {};
    not_equals = {};
    op_is = {
      json: {},
      bool: {}
    };
    fn_is_type = {
      json: function(obj, field, value) {
        if (obj.hasOwnProperty(field)) {
          if (obj[field].indexOf(value) !== -1) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      },
      bool: function(obj, field, value) {
        var _false, _ref, _ref1, _ref2, _ref3, _true;
        _true = [1, true, 'true', '1'];
        _false = [0, false, 'false', '0'];
        if (obj.hasOwnProperty(field)) {
          if (value.v.toString() === '1') {
            if (value.op === '=') {
              return _ref = obj[field], __indexOf.call(_true, _ref) >= 0;
            } else {
              return _ref1 = obj[field], __indexOf.call(_true, _ref1) < 0;
            }
          } else {
            if (value.op === '=') {
              return _ref2 = obj[field], __indexOf.call(_false, _ref2) >= 0;
            } else {
              return _ref3 = obj[field], __indexOf.call(_false, _ref3) < 0;
            }
          }
        } else {
          return false;
        }
      }
    };
    results = rows;
    for (_i = 0, _len = filters.length; _i < _len; _i++) {
      _f = filters[_i];
      if (!fields[_f.field].hasOwnProperty('json')) {
        if (fields[_f.field].type === 'bool') {
          op_is.bool[_f.field] = {
            v: _f.value,
            op: _f.operator
          };
        } else {
          if (_f.operator === '=') {
            equals[_f.field] = _f.value;
          } else if (_f.operator === '!') {
            not_equals[_f.field] = _f.value;
          }
        }
      } else {
        op_is.json[_f.field] = _f.value;
      }
    }
    if (Object.keys(equals).length > 0) {
      results = _.where(results, equals);
    }
    _types = Object.keys(op_is);
    for (_j = 0, _len1 = _types.length; _j < _len1; _j++) {
      _type = _types[_j];
      if (Object.keys(op_is[_type]).length > 0) {
        _ref = op_is[_type];
        for (field in _ref) {
          value = _ref[field];
          results = _.filter(results, function(obj) {
            return fn_is_type[_type](obj, field, value);
          });
        }
      }
    }
    if (Object.keys(not_equals).length > 0) {
      results = _.reject(results, not_equals);
    }
    return results;
  };

  this.fn_btn_reload = (function(_this) {
    return function() {
      meg.data.currentItems = _this.items;
      return _this.reloadTable(_this.items);
    };
  })(this);

  this.fn_btn_filter = (function(_this) {
    return function() {
      var resFilter;
      resFilter = $('#filters').MEGFilter('filterData', _this.items);
      meg.data.currentItems = resFilter;
      return _this.reloadTable(resFilter);
    };
  })(this);

  $('.btn-reload').on('click', (function(_this) {
    return function() {
      return _this.fn_btn_reload();
    };
  })(this));

  $('.btn-filter').on('click', (function(_this) {
    return function() {
      return _this.fn_btn_filter();
    };
  })(this));

  $(document).on('ready', function() {
    $('#btn-filter-minus').on('click', function() {
      var item;
      item = $(this).find('i');
      if (item.hasClass('fa-plus')) {
        return item.removeClass('fa-plus').addClass('fa-minus');
      } else {
        return item.removeClass('fa-minus').addClass('fa-plus');
      }
    });
    return $("#btn-filter-minus").trigger('click');
  });

}).call(this);
