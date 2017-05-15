
/**
@license MEG EXPORT vs 1.0
Informatica MEG - 2014 Todos los derechos reservados
 */

(function() {
  var arrayToTable, downloadableByType, xport;

  xport = {};


  /** @expose */

  xport.exportData = function(type, data, opts) {
    var attr, defaults, f, field, fields, fn, isArray, isDict, item, lines, newData, newRow, papaparserCfg, results, row, rowHeader, _i, _j, _k, _l, _len, _len1, _len2, _len3, _opts, _ref, _ref1;
    if (opts == null) {
      opts = {};
    }
    data = JSON.parse(JSON.stringify(data));
    defaults = {
      delimiter: ',',
      header: false,
      headerLabels: {},
      nameFile: 'download',
      downloadable: true,
      fields: [],
      fnParsers: {},
      orderBy: null
    };
    defaults = _.merge(defaults, opts);
    papaparserCfg = {
      delimiter: defaults.delimiter,
      header: defaults.header
    };
    isArray = false;
    isDict = false;
    if (type !== 'csv' && type !== 'txt' && type !== 'json' && type !== 'xls') {
      throw 'Type [' + type + '] is not supported';
    }
    if (data == null) {
      throw 'Data is a empty object';
    }
    if (typeof data === 'object') {
      item = data.length > 0 ? data[0] : {};
      if (!_.isArray(item)) {
        if (_.isEmpty(item)) {
          throw 'Data is empty';
        } else {
          isDict = true;
        }
      } else {
        isArray = true;
      }
    } else {
      throw 'Data is not array or dict';
    }
    if (isDict && !_.isEmpty(defaults.fnParsers)) {
      _ref = defaults.fnParsers;
      for (field in _ref) {
        fn = _ref[field];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          if (item[field]) {
            item[field] = fn(item[field]);
          } else {
            item[field] = '';
          }
        }
      }
    }
    if (defaults.orderBy !== null) {
      data = _.sortBy(data, defaults.orderBy);
    }
    results = null;
    if (type === 'csv') {
      if (isArray) {
        results = Papa.unparse({
          data: data
        }, papaparserCfg);
      }
      if (isDict) {
        _opts = {
          data: data
        };
        if (defaults.fields.length > 0) {
          _opts.fields = defaults.fields;
        }
        results = Papa.unparse(_opts, papaparserCfg);
      }
      lines = results.split('\n');
      lines.splice(0, 1);
      results = lines.join('\n');
    } else if (type === 'xls') {
      newData = [];
      fields = defaults.fields;
      for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
        row = data[_j];
        newRow = [];
        for (_k = 0, _len2 = fields.length; _k < _len2; _k++) {
          f = fields[_k];
          newRow.push(row[f]);
        }
        newData.push(newRow);
      }
      results = newData;
    }
    if (defaults.header) {
      rowHeader = [];
      if (!_.isEmpty(defaults.headerLabels)) {
        _ref1 = defaults.fields;
        for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
          attr = _ref1[_l];
          if (defaults.headerLabels.hasOwnProperty(attr)) {
            rowHeader.push(defaults.headerLabels[attr]);
          } else {
            rowHeader.push(attr);
          }
        }
      }
      if (type === 'csv') {
        results = rowHeader.join(defaults.delimiter) + '\n' + results;
      } else if (type === 'xls') {
        results = [rowHeader].concat(results);
      }
    }
    if (defaults.downloadable) {
      return downloadableByType(type, results);
    } else {
      return results;
    }
  };

  arrayToTable = function(rows) {
    var row, tb, trs, _i, _len;
    trs = '';
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      row = rows[_i];
      trs += '<tr><td>' + row.join('</td><td>') + '</td></tr>';
    }
    tb = '<table><thead></thead><tbody>' + trs + '</tbody></table>';
    return tb;
  };

  downloadableByType = function(type, data) {
    var base64data, excelFile, link, url;
    if (type === 'csv' || type === 'txt') {
      base64data = "base64," + $.base64.encode(data);
      url = 'data:application/' + type + ';charset=utf-8;' + base64data;
    } else if (type === 'json') {
      base64data = "base64," + $.base64.encode(JSON.stringify(data));
      url = 'data:application/json;charset=utf-8;' + base64data;
    } else if (type === 'xls') {
      excelFile = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>";
      excelFile += "<head>";
      excelFile += "<!--[if gte mso 9]>";
      excelFile += "<xml>";
      excelFile += "<x:ExcelWorkbook>";
      excelFile += "<x:ExcelWorksheets>";
      excelFile += "<x:ExcelWorksheet>";
      excelFile += "<x:Name>";
      excelFile += "{worksheet}";
      excelFile += "</x:Name>";
      excelFile += "<x:WorksheetOptions>";
      excelFile += "<x:DisplayGridlines/>";
      excelFile += "</x:WorksheetOptions>";
      excelFile += "</x:ExcelWorksheet>";
      excelFile += "</x:ExcelWorksheets>";
      excelFile += "</x:ExcelWorkbook>";
      excelFile += "</xml>";
      excelFile += "<![endif]-->";
      excelFile += "</head>";
      excelFile += "<body>";
      excelFile += arrayToTable(data);
      excelFile += "</body>";
      excelFile += "</html>";
      base64data = "base64," + $.base64.encode(excelFile);
      url = 'data:application/vnd.ms-excel;charset=utf-8;' + base64data;
    }
    link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute('download', 'descarga.' + type);
    return link.click();
  };

  if (this["meg"] == null) {
    this["meg"] = {};
  }

  this["meg"]["export"] = xport;

}).call(this);
