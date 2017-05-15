###*
@license MEG EXPORT vs 1.0
Informatica MEG - 2014 Todos los derechos reservados
###

xport = {}

# REQUIRE: lodash.js, jquery.base64.js, papaparser.js

# {string} type = csv | txt | json | xls
# {array|dict} data = data to export
# {dict} opts =
###* @expose ###
xport.exportData = (type, data, opts = {}) ->
  data = JSON.parse(JSON.stringify(data))
  defaults =
    delimiter : ','
    header : false
    headerLabels:{}
    nameFile : 'download'
    downloadable : true
    fields:[] # attrs to export
    fnParsers: {} # fns to apply custom fields format
    orderBy:null

  defaults = _.merge(defaults, opts)

  papaparserCfg =
    delimiter : defaults.delimiter
    header: defaults.header

  isArray = false
  isDict = false
  # validate params
  if type not in ['csv','txt','json','xls']
    throw 'Type [' + type + '] is not supported'
  if not data?
    throw 'Data is a empty object'
  if typeof data is 'object'
    item = if data.length > 0 then data[0] else {}
    if not _.isArray(item)
      if _.isEmpty(item)
        throw 'Data is empty'
      else
        isDict = true
    else
      isArray = true
  else
    throw 'Data is not array or dict'

  # apply parser fns
  if isDict and not _.isEmpty(defaults.fnParsers)
    for field, fn of defaults.fnParsers
      for item in data
        if item[field]
          item[field] = fn(item[field])
        else
          item[field] = ''
  # order items
  if defaults.orderBy isnt null
    data = _.sortBy(data, defaults.orderBy)

  results = null # the result var
  if type == 'csv'
    if isArray
      results = Papa.unparse({data:data}, papaparserCfg)
    if isDict
      _opts =
        data: data
      if defaults.fields.length > 0
        _opts.fields = defaults.fields
      results = Papa.unparse(_opts, papaparserCfg)

    # remove first line
    lines = results.split('\n')
    lines.splice(0,1)
    results = lines.join('\n')
  else if type == 'xls'
    newData = []
    fields = defaults.fields
    for row in data
      newRow = []
      for f in fields
        newRow.push(row[f])
      newData.push(newRow)
    results = newData

  # add header
  if defaults.header
    rowHeader = []
    if not _.isEmpty(defaults.headerLabels)
      for attr in defaults.fields
        if defaults.headerLabels.hasOwnProperty(attr)
          rowHeader.push(defaults.headerLabels[attr])
        else
          rowHeader.push(attr)

    if type == 'csv'
      results = rowHeader.join(defaults.delimiter) + '\n' + results
    else if type == 'xls'
      results = [rowHeader].concat(results)
  if defaults.downloadable
    downloadableByType(type, results)
  else
    return results

arrayToTable = (rows) ->
  trs = ''
  for row in rows
    trs += '<tr><td>' + row.join('</td><td>') + '</td></tr>'
  tb = '<table><thead></thead><tbody>' + trs + '</tbody></table>'
  tb

downloadableByType = (type, data) ->
  if type == 'csv' or type == 'txt'
    base64data = "base64," + $.base64.encode(data)
    url = 'data:application/' + type + ';charset=utf-8;' + base64data
  else if type == 'json'
    base64data = "base64," + $.base64.encode(JSON.stringify(data))
    url = 'data:application/json;charset=utf-8;' + base64data
  else if type == 'xls'
    excelFile = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>"
    excelFile += "<head>"
    excelFile += "<!--[if gte mso 9]>"
    excelFile += "<xml>"
    excelFile += "<x:ExcelWorkbook>"
    excelFile += "<x:ExcelWorksheets>"
    excelFile += "<x:ExcelWorksheet>"
    excelFile += "<x:Name>"
    excelFile += "{worksheet}"
    excelFile += "</x:Name>"
    excelFile += "<x:WorksheetOptions>"
    excelFile += "<x:DisplayGridlines/>"
    excelFile += "</x:WorksheetOptions>"
    excelFile += "</x:ExcelWorksheet>"
    excelFile += "</x:ExcelWorksheets>"
    excelFile += "</x:ExcelWorkbook>"
    excelFile += "</xml>"
    excelFile += "<![endif]-->"
    excelFile += "</head>"
    excelFile += "<body>"
    excelFile += arrayToTable(data)
    excelFile += "</body>"
    excelFile += "</html>"
    base64data = "base64," + $.base64.encode(excelFile)
    url = 'data:application/vnd.ms-excel;charset=utf-8;' + base64data

  link = document.createElement("a")
  link.setAttribute("href", url)
  link.setAttribute('download','descarga.' + type)
  link.click()

if not @["meg"]?
  @["meg"] = {}
@["meg"]["export"] = xport