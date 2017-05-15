###*
@license MEG GUI vs 1.1
Informatica MEG - 2014 Todos los derechos reservados
###
#- DEPENDENCIES = JQUERY, MEG-SERVER

gui = {}

###* @expose ###
gui.showRefName = (url, showname, itemId, sel, href=false, cb=null) ->
  if typeof itemId isnt 'undefined' and itemId isnt null
    if itemId.length > 0
      _url = '/' + url + '/' + itemId + '.json?f=id,' + showname
      meg.server.ajax _url, {}, (err, item) ->
        if item
          a = '{text}'
          if href == true
            a = '<a href="#">{text}</a>'
            a = a.replace('#', '/'+url+'/'+item.id)
          if item.hasOwnProperty(showname)
            text = item[showname]
          else
            text = ''
          a = a.replace('{text}', text)
          $(sel).append(a)
        if cb
          cb(err, text)
    else
      cb(null, null) if cb
  else
    cb(null, null) if cb

###* @expose ###
gui.showFromValueName = (sel, values, def_value) ->
  if typeof def_value isnt 'undefined' and def_value isnt null
    if def_value.length > 0
      $(sel).text(values[def_value])

###* @expose ###
gui.loadSelect = (url, attr, def_value, opts = {}, cb=null) ->
  opts.select2 = false
  showname = 'nombre'
  showLoader = true
  if opts.showname
    showname = opts.showname
  if def_value.length > 0
    opts.default = def_value
  if opts.loader
    showLoader = opts.loader
  successCb = (err, items) ->
    if typeof(_) != 'undefined'
      items = _.sortBy(items, showname)
    meg.select.load attr, items, opts, () ->
      if cb
        cb()
  spinId = 'spin_' + attr.replace('#','').replace('.','')
  ajaxOpts =
    "dataType" : 'json'
    "async" : true
    beforeSend: () ->
      if showLoader
        t = attr.replace('#','').replace('.','')
        #$(attr).empty()
        $('label[for=' + t + ']').append(' <i class="fa fa-spinner fa-spin" id="' + spinId + '"></>')
    success: (data) ->
      if showLoader
        $('#' + spinId).remove()
      if data
        if data.code
          successCb(0, data.data)
        else
          successCb(0, data)
      else
        console.log "NOT DATA EXIST"
        successCb(1,null)
  $.ajax(url, ajaxOpts)

###* @expose ###
gui.loadChainedSelect = (opts, cb=null) ->
  def_opts =
    to_key_attr : 'id'
    to_chain_attr : opts.from_attr
    to_text_attr : 'nombre'
  opts = $.extend(def_opts, opts)
  meg.gui.loadSelect opts.from_url , opts.from_select, opts.from_def_value, () ->

  meg.server.ajax opts.to_url, {}, (err, items) ->
    # check if lodash is loaded
    if typeof(_) != 'undefined'
      items = _.sortBy(items, 'nombre')
    options = '<option value="">[Seleccionar]</option>'
    for item in items
      options += '<option value="' + item[opts.to_key_attr] + '" class="' + item[opts.to_chain_attr] + '">' + item[opts.to_text_attr] + '</option>'
    $(opts.to_select).empty().append(options)

    $(opts.to_select).chained(opts.from_select)

    if opts.to_def_value.length > 0
      $(opts.to_select).val(opts.to_def_value)

    if cb
      cb()

###* @expose ###
gui.loadSelectFromValues = (values, attr, def_value, empty=true, cb=null) ->
  opts =
    showname: 'text'
    select2: false
    empty: empty
  items = []
  for k, v of values
    items.push({id:k, text:v})
  if def_value.length > 0
    opts.default = def_value
  meg.select.load attr, items, opts, () ->
    if cb
      cb()

###* @expose ###
gui.loadSelectCustomText = (url, attr, def_value, customFn, cb=null) ->
  opts = {showname: 'text'}
  if def_value.length > 0
    opts.default = def_value
  meg.server.ajax url, {}, (err, items) ->
    for item in items
      item.text = customFn(item)
    meg.select.load attr, items, opts, () ->

###* @expose ###
gui.getURLParameters = () ->
  sPageURL = window.location.search.substring(1)
  sURLVariables = sPageURL.split('&')
  res = {}
  for urlVar in sURLVariables
    sParameter = urlVar.split('=')
    res[sParameter[0]] = sParameter[1]
  return res

###* @expose ###
gui.loadGeographicsSelects = (defValues, callback = null) ->
  # REQUIERE async.js
  # defValues : dict con formato {model_id:'#Namemodel_', provincia:'', localidad:'', barrio:''}
  provinciaSelector = '#provincia'
  if defValues.provinciaSelector
    provinciaSelector = defValues.provinciaSelector
  async.waterfall([
    (cb) ->
      if defValues.localidad.length > 0
        meg.server.ajax '/localidades/' + defValues.localidad + '.json', {}, (err, item) ->
          if item
            defValues.provincia = item.provincia
            cb(err, defValues)
          else
            cb(null, defValues)
      else
        cb(null, defValues)
    , (defValues, cb) ->
      $(provinciaSelector).on 'change', ->
        meg.gui.loadSelect(
          '/localidades.json?f=id,name&q=' + JSON.stringify({provincia:$(@).val()})
          , defValues.model_id + 'localidad'
          , defValues.localidad
          , {showname:'name'}
          , () ->
            $(defValues.model_id + 'localidad').on 'change', ->
              meg.gui.loadSelect(
                '/barrios.json?f=id,name&q=' + JSON.stringify({localidad:$(@).val()})
                , defValues.model_id + 'barrio'
                , defValues.barrio
                , {showname:'name'}
                , () ->
              )
            if defValues.localidad.length > 0
              $(defValues.model_id + 'localidad').trigger('change')
        )
      meg.gui.loadSelect '/provincias.json?f=id,name', provinciaSelector, defValues.provincia, {showname:'name'}, () ->
        if defValues.provincia.length > 0
          $(provinciaSelector).trigger('change')
        cb(null, null)
  ], () ->
    if callback
      callback()
  )

if not @["meg"]?
  @["meg"] = {}
@["meg"]["gui"] = gui