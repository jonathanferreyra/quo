(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var insertRow, methods, removeRow, _defaultInitOptions, _genRowSelectNewMode, _generateByRowsData, _generateNewRow, _loadValuesInInputs, _utilVars;
    _defaultInitOptions = {
      columns: [],
      mode: 'edit',
      data: [],
      btAddText: 'Agregar fila',
      btRemoveIcon: 'fa fa-trash-o',
      btAddIcon: 'fa fa-plus',
      btAddClass: 'btn btn-success',
      tableClasses: 'table table-responsive',
      fillAllRow: false
    };
    _utilVars = {
      currentIndex: 1,
      supportedTypes: ['text', 'date', 'time', 'email', 'tel', 'number'],
      sampleInput: '<input type="{type}" name="{field}">',
      sampleTd: '<td>{value}</td>',
      sampleBtRemove: '<a data-index="{index}" class="btn btn-danger" title="Eliminar esta fila"><i class="{icon-remove}"></i></a>',
      sampleBtAdd: '<buttton class="{bt-class}" type="button" title="Agregar nueva fila"><i class="{icon-add}"></i> </button>'
    };
    methods = {
      init: function(options) {
        var addbt, btadd, col, columns, optColumns, rows, settings, target, tbBody, tbFoot, tbHead, tbMain, tbWhole, _i, _len;
        settings = $.extend({}, _defaultInitOptions, _utilVars, options);
        target = this;
        if (target.length > 0) {
          tbWhole = target[0];
          tbHead = document.createElement('thead');
          tbBody = document.createElement('tbody');
          tbFoot = document.createElement('tfoot');
          tbMain = $('<table>').addClass(settings.tableClasses).append(tbHead, tbBody, tbFoot);
          $(tbWhole).empty().append(tbMain);
          $(tbWhole).data('settings', settings);
          optColumns = settings.columns;
          if (optColumns.length > 0) {
            columns = '<tr>';
            for (_i = 0, _len = optColumns.length; _i < _len; _i++) {
              col = optColumns[_i];
              columns += '<th name="' + col.name + '">' + col.display + '</th>';
            }
            if (settings.mode === 'edit') {
              columns += '<th></th>';
            }
            columns += '</tr>';
            $(tbHead).append(columns);
          }
          if (settings.mode === 'edit') {
            if (settings.data.length === 0) {
              $(tbBody).append(_generateNewRow(tbWhole));
            } else {
              $(tbBody).append(_generateByRowsData(tbWhole));
              _loadValuesInInputs(settings.data);
            }
            btadd = settings.sampleBtAdd;
            btadd = btadd.replace('{icon-add}', settings.btAddIcon);
            btadd = btadd.replace('{bt-class}', settings.btAddClass);
            addbt = $(btadd).attr('title', settings.btAddText).append(settings.btAddText);
            addbt.click(function(ev) {
              return insertRow(tbWhole, tbBody, ev);
            });
            return $(tbFoot).append($('<td>').append(addbt));
          } else if (settings.mode === 'show') {
            if (settings.data.length === 0) {
              return new Error("No data found.");
            } else {
              rows = _generateByRowsData(tbWhole);
              return $(tbBody).append(rows);
            }
          }
        }
      },
      getData: function() {
        var allFields, dataRow, filledFields, isEmptyRow, k, name, resultData, settings, td, tds, tr, trs, v, value, widget, _i, _j, _len, _len1;
        settings = $(this).data('settings');
        if (settings.mode === 'edit') {
          trs = $(this).find('tr.data');
          resultData = [];
          for (_i = 0, _len = trs.length; _i < _len; _i++) {
            tr = trs[_i];
            tds = $(tr).find('td');
            dataRow = {};
            isEmptyRow = true;
            for (_j = 0, _len1 = tds.length; _j < _len1; _j++) {
              td = tds[_j];
              widget = $(td).context.childNodes;
              name = $(widget).attr('name');
              value = $(widget).val();
              if (name !== void 0) {
                dataRow[name] = value;
              }
              if ((value !== null) && (typeof value !== 'undefined')) {
                if (value.length > 0) {
                  isEmptyRow = false;
                }
              }
            }
            if (!isEmptyRow) {
              if (settings.fillAllRow) {
                allFields = Object.keys(dataRow).length;
                filledFields = 0;
                for (k in dataRow) {
                  v = dataRow[k];
                  if (v !== null && typeof v !== 'undefined') {
                    if (v.length > 0) {
                      filledFields += 1;
                    }
                  }
                }
                if (allFields === filledFields) {
                  resultData.push(dataRow);
                }
              } else {
                resultData.push(dataRow);
              }
            }
          }
          return resultData;
        } else {
          return void 0;
        }
      }
    };
    _generateNewRow = function(tbWhole) {
      var attrs, btn, field, index, optColumns, resultRow, settings, _i, _len, _ref, _row, _td;
      settings = $(tbWhole).data('settings');
      index = settings.currentIndex.toString();
      optColumns = settings.columns;
      resultRow = '<tr id="' + index + '" class="data">';
      for (_i = 0, _len = optColumns.length; _i < _len; _i++) {
        field = optColumns[_i];
        attrs = field;
        delete attrs['display'];
        attrs["class"] = 'form-control';
        if (_ref = attrs.type, __indexOf.call(settings.supportedTypes, _ref) >= 0) {
          _row = $(document.createElement("input")).attr(attrs);
        } else if (attrs.type === 'select') {
          _row = _genRowSelectNewMode(attrs);
        }
        _td = $($('<td>').append(_row))[0].outerHTML;
        resultRow += _td;
      }
      btn = settings.sampleBtRemove;
      btn = btn.replace('{icon-remove}', settings.btRemoveIcon);
      btn = btn.replace('{index}', index);
      btn = $(btn).click(function(ev) {
        return removeRow(ev);
      });
      resultRow = $(resultRow).append($('<td>').append(btn));
      settings.currentIndex += 1;
      $(tbWhole).data('settings', settings);
      return resultRow;
    };
    _generateByRowsData = function(tbWhole) {
      var allRows, btn, col, field, idxColumns, index, items, mode, opt, optColumns, resultRow, rowData, rowsData, settings, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _row;
      settings = $(tbWhole).data('settings');
      rowsData = settings.data;
      mode = settings.mode;
      optColumns = settings.columns;
      idxColumns = {};
      for (_i = 0, _len = optColumns.length; _i < _len; _i++) {
        col = optColumns[_i];
        if (col.type === 'select') {
          idxColumns[col.name] = {};
          _ref = col.options;
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            opt = _ref[_j];
            idxColumns[col.name][opt[col.keyId]] = opt[col.keyText];
          }
        }
      }
      allRows = [];
      for (_k = 0, _len2 = rowsData.length; _k < _len2; _k++) {
        rowData = rowsData[_k];
        index = settings.currentIndex.toString();
        resultRow = $('<tr>').addClass('data').attr('id', index);
        for (_l = 0, _len3 = optColumns.length; _l < _len3; _l++) {
          field = optColumns[_l];
          if (mode === 'edit') {
            if (_ref1 = field.type, __indexOf.call(settings.supportedTypes, _ref1) >= 0) {
              _row = $(document.createElement("input")).attr('id', field.name + index).attr('name', field.name).attr('type', field.type).attr('class', 'form-control');
              _row = $(_row)[0].outerHTML;
            } else if (field.type === 'select') {
              _row = _genRowSelectNewMode(field);
              _row.val(rowData[field.name]);
            }
            _row = $('<td>').append(_row);
          }
          if (mode === 'show') {
            if (field.type !== 'select') {
              _row = $('<td>').append(rowData[field.name]);
            } else {
              items = idxColumns[field.name];
              _row = $('<td>').append(items[rowData[field.name]]);
            }
          }
          resultRow.append(_row);
        }
        settings.currentIndex += 1;
        if (mode === 'edit') {
          btn = settings.sampleBtRemove;
          btn = btn.replace('{icon-remove}', settings.btRemoveIcon);
          btn = $(btn);
          btn = btn.attr('data-index', index).click(function(ev) {
            return removeRow(ev);
          });
          resultRow.append($('<td>').append(btn));
        }
        allRows.push(resultRow);
      }
      $(tbWhole).data('settings', settings);
      return allRows;
    };
    _loadValuesInInputs = function(rowsData) {
      var index, key, keys, row, _i, _j, _len, _len1, _results;
      index = 1;
      _results = [];
      for (_i = 0, _len = rowsData.length; _i < _len; _i++) {
        row = rowsData[_i];
        keys = Object.keys(row);
        for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
          key = keys[_j];
          $('#' + key + index.toString()).val(row[key]);
        }
        _results.push(index += 1);
      }
      return _results;
    };
    _genRowSelectNewMode = function(attrs) {
      var k, o, opts, v, _row;
      _row = $('<select class="form-control">').attr('name', attrs.name);
      if (attrs.options.length > 0) {
        k = attrs.keyId;
        v = attrs.keyText;
        opts = [
          (function() {
            var _i, _len, _ref, _results;
            _ref = attrs.options;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              o = _ref[_i];
              _results.push('<option value="' + o[k] + '">' + o[v] + '</option>');
            }
            return _results;
          })()
        ][0];
        opts = opts.join('');
        _row.append(opts);
      } else {
        _row.append('<option value="">[Sin elementos]</option>');
      }
      return _row;
    };
    insertRow = function(tbWhole, tbBody, ev) {
      var newRow, target;
      target = this;
      newRow = _generateNewRow(tbWhole);
      return $(tbBody).append(newRow);
    };
    removeRow = function(ev) {
      var index, target, tbody;
      target = $(ev.currentTarget);
      tbody = target.parent().parent().parent();
      index = target.context.dataset.index;
      return $(tbody).find('tr#' + index).remove();
    };
    return $.fn.MEGSimpleTable = function(methodOrOptions) {
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
