# VERSION 1.5.0
(($) ->
  _defaultInitOptions = 
    # Array of column options.
    columns: []
    # Mode visualize table [edit|show]
    mode: 'edit'
    # Data to load by default
    data : []
    # Text showed in add button
    btAddText : 'Agregar fila'
    # icon displayed in button remove row
    btRemoveIcon : 'fa fa-trash-o'
    # icon displayed in button add row
    btAddIcon : 'fa fa-plus'
    #
    btAddClass: 'btn btn-success'
    # class to add to table
    tableClasses : 'table table-responsive'
    # si es true, todos los campos de la fila deben
    # haber sido completados para que se agrege
    # al set de datos resultante, sino se ignora
    # si es false, con que un campo haya sido rellenado
    # ya se cuenta como una fila valida
    fillAllRow:false

  _utilVars = 
    currentIndex : 1
    supportedTypes:['text','date','time','email','tel','number']
    sampleInput : '<input type="{type}" name="{field}">'
    sampleTd : '<td>{value}</td>'
    sampleBtRemove : '<a data-index="{index}" class="btn btn-danger" title="Eliminar esta fila"><i class="{icon-remove}"></i></a>'
    sampleBtAdd : '<buttton class="{bt-class}" type="button" title="Agregar nueva fila"><i class="{icon-add}"></i> </button>'

  methods =
    init: (options) ->
      settings = $.extend({}, _defaultInitOptions, _utilVars, options)
      target = @
      if target.length > 0
        tbWhole = target[0]

        # Create thead and tbody
        tbHead = document.createElement('thead')
        tbBody = document.createElement('tbody')
        tbFoot = document.createElement('tfoot')
        tbMain = $('<table>')
          .addClass(settings.tableClasses)
          .append(tbHead, tbBody, tbFoot)
        # Remove existing content and append new thead and tbody
        $(tbWhole).empty().append(tbMain)
        # Save options 
        $(tbWhole).data('settings', settings)

        optColumns = settings.columns
        # Generate head
        if optColumns.length > 0
          columns = '<tr>'
          for col in optColumns
            columns += '<th name="' + col.name + '">' + col.display + '</th>'
          if settings.mode == 'edit'
            columns += '<th></th>'
          columns += '</tr>'
          $(tbHead).append(columns)

        # Generate body
        if settings.mode == 'edit'
          if settings.data.length == 0
            $(tbBody).append(_generateNewRow(tbWhole))
          else
            $(tbBody).append(
              _generateByRowsData(tbWhole)
            )
            _loadValuesInInputs(settings.data)

          # Add row button
          btadd = settings.sampleBtAdd
          btadd = btadd.replace('{icon-add}',settings.btAddIcon)
          btadd = btadd.replace('{bt-class}',settings.btAddClass)
          addbt = $(btadd)
            .attr('title',settings.btAddText)
            .append(settings.btAddText)
          addbt.click (ev) ->
            insertRow tbWhole, tbBody, ev
          $(tbFoot).append($('<td>').append(addbt))
        else if settings.mode == 'show'
          if settings.data.length == 0
            new Error("No data found.")
          else
            rows = _generateByRowsData(tbWhole)
            $(tbBody).append(rows)

    getData: () ->
      settings = $(@).data('settings')
      if settings.mode == 'edit'
        trs = $(@).find('tr.data')
        resultData = []
        for tr in trs
          tds = $(tr).find('td')
          dataRow = {}
          isEmptyRow = true
          for td in tds
            widget = $(td).context.childNodes
            name = $(widget).attr('name')
            value = $(widget).val()
            if name isnt undefined
              dataRow[name] = value
            if (value != null) and (typeof value != 'undefined')
              if value.length > 0
                isEmptyRow = false
          if not isEmptyRow
            # check fillAllRow
            if settings.fillAllRow
              allFields = Object.keys(dataRow).length
              filledFields = 0
              for k, v of dataRow
                if v != null and typeof v != 'undefined'
                  if v.length > 0
                    filledFields += 1
              if allFields == filledFields
                resultData.push(dataRow)
            else
              resultData.push(dataRow)
        resultData
      else
        undefined

  _generateNewRow = (tbWhole) ->
    settings = $(tbWhole).data('settings')
    index = settings.currentIndex.toString()
    optColumns = settings.columns
    resultRow = '<tr id="' + index + '" class="data">'
    # generate fields
    for field in optColumns
      attrs = field
      delete attrs['display']
      attrs.class = 'form-control'
      # type input
      if attrs.type in settings.supportedTypes
        _row = $(document.createElement("input")).attr(attrs)
      # type select
      else if attrs.type == 'select'
        _row = _genRowSelectNewMode(attrs)
      _td = $($('<td>').append(_row))[0].outerHTML
      resultRow += _td
    # generate remove button
    btn = settings.sampleBtRemove
    btn = btn.replace('{icon-remove}',settings.btRemoveIcon)
    btn = btn.replace('{index}',index)
    btn = $(btn).click (ev) ->
      removeRow ev
    resultRow = $(resultRow).append($('<td>').append(btn))

    settings.currentIndex += 1
    $(tbWhole).data('settings', settings)
    return resultRow

  _generateByRowsData = (tbWhole) ->
    settings = $(tbWhole).data('settings')
    rowsData = settings.data
    mode = settings.mode
    optColumns = settings.columns
    
    # generate index of select columns
    idxColumns = {}    
    for col in optColumns
      if col.type == 'select'
        idxColumns[col.name] = {}
        for opt in col.options
          idxColumns[col.name][opt[col.keyId]] = opt[col.keyText]

    allRows = []
    for rowData in rowsData
      index = settings.currentIndex.toString()
      resultRow = $('<tr>').addClass('data').attr('id',index)
      # generate fields
      for field in optColumns
        if mode == 'edit'
          if field.type in settings.supportedTypes
            _row = $(document.createElement("input"))
              .attr('id',field.name + index)
              .attr('name',field.name)
              .attr('type',field.type)
              .attr('class','form-control')
            _row = $(_row)[0].outerHTML
          else if field.type == 'select'
            _row = _genRowSelectNewMode(field)
            _row.val(rowData[field.name])
          _row = $('<td>').append(_row)
        if mode == 'show'
          if field.type != 'select'
            _row = $('<td>').append(rowData[field.name])
          else
            items = idxColumns[field.name]
            _row = $('<td>').append(items[rowData[field.name]])
        resultRow.append(_row)
      settings.currentIndex += 1
      # generate remove button
      if mode == 'edit'
        btn = settings.sampleBtRemove
        btn = btn.replace('{icon-remove}',settings.btRemoveIcon)
        btn = $(btn)
        btn = btn
          .attr('data-index',index)
          .click (ev) ->
            removeRow ev
        resultRow.append($('<td>').append(btn))
      allRows.push(resultRow)
    $(tbWhole).data('settings', settings)
    allRows

  _loadValuesInInputs = (rowsData) ->
    index = 1
    for row in rowsData
      keys = Object.keys(row)
      for key in keys
        $('#' + key + index.toString()).val(row[key])
      index += 1

  _genRowSelectNewMode = (attrs) ->
    _row = $('<select class="form-control">').attr('name', attrs.name)
    if attrs.options.length > 0
      k = attrs.keyId
      v = attrs.keyText
      opts = ['<option value="' + o[k] + '">' + o[v] + '</option>' for o in attrs.options][0]
      opts = opts.join('')
      _row.append(opts)
    else
      _row.append('<option value="">[Sin elementos]</option>')
    _row

  insertRow = (tbWhole, tbBody, ev) ->
    target = @
    newRow = _generateNewRow(tbWhole)
    $(tbBody).append(newRow)

  removeRow = (ev) ->
    target = $(ev.currentTarget)
    tbody = target.parent().parent().parent()
    index = target.context.dataset.index
    $(tbody).find('tr#' + index).remove()

  $.fn.MEGSimpleTable = (methodOrOptions) ->
    if methods[methodOrOptions]
      methods[methodOrOptions].apply this, Array::slice.call(arguments, 1)
    else if typeof methodOrOptions is "object" or not methodOrOptions
      methods.init.apply this, arguments
    else
      $.error "Method " + methodOrOptions + " does not exist"
) jQuery

# v1.1
# - added support bootstrap 3
# - customizable icon buttons
# - initialize table only selector name
# v1.2
# - select support