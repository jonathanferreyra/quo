@countByField = (items, refItems, attrs) ->
  # items = lista de dicts con todos los items
  # refItems = dict con todos los items referencia
  # attrs = lista de attrs a contar

  allCounts = {}
  for attr in attrs
    # LODASH REQUIRED
    _refItems = _.indexBy(refItems[attr], 'id')

    # count items ocurrences
    _res = {}
    for item in items
      if item.hasOwnProperty(attr)
        if item[attr].length == 0
          if not _res.hasOwnProperty('empty')
            _res.empty = 0
          _res.empty += 1
        else
          if not _res.hasOwnProperty(item[attr])
            _res[item[attr]] = 0
          _res[item[attr]] += 1
      else
        _res.empty += 1
    
    # parse to morris format
    _data = []
    for k, v of _res
      if k == 'empty'
        _data.push({label:'Sin especificar', value:v})
      else
        attrText = 'nombre'
        if not _refItems[k][attrText]
          attrText = 'name'
        _label = if _refItems[k][attrText] then _refItems[k][attrText] else ''
        _data.push({
          label: _label
          value: v
        })
    allCounts[attr] = _.sortBy(_data, 'value')
  allCounts

@renderChart = (_div, _data, _type='Donut') ->
  opts = 
    element: _div
    data: _data
    hideHover:false
  $('#' + _div).empty()
  if _type in ['Bar', 'Line', 'Area']
    opts.xkey = 'label'
    opts.ykeys = ['value']
    opts.labels = ['Cantidad']
  gp = Morris[_type](opts)
  $(window).on 'resize', ->
    gp.redraw()