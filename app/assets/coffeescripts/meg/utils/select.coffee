###*
@license MEG select vs 1.5
Informatica MEG - 2014 Todos los derechos reservados
###
#- DEPENDENCIES = JQUERY, SELECT2
select = {}
###* @expose ###
select.onlyLoad = (widgetname, data, id, showname, empty, cb) ->
  #- depends Jquery
  if JSON.stringify(data) isnt "[]"
    msg = "[Seleccionar]"
  else
    msg = "[Sin elementos]"

  preoptiontag = "<option value="
  postoptiontag= "</option>"
  options = ''
  if empty
    options = "#{preoptiontag}''>#{msg}#{postoptiontag}"
  
  for item in data
    options += "#{preoptiontag}#{item[id]}>#{item[showname]}#{postoptiontag}"
  
  $(widgetname).empty().append options
  cb(0)

select.makeSelect2 = (widgetname, cb =(->)) ->
  #- depends Jquery, Select2
  if $(widgetname)["select2"]?
    $(widgetname)["select2"]()
    $('.select2-container')["removeClass"]('form-control')["css"]('width','100%')
    cb(0)
  else
    cb(1)

select.setID = (widgetname, id, cb =(->)) ->
  #- depends Jquery
  $(widgetname)["val"](id);
  cb(0)

###* @expose ###
select.load = (widgetname, data, opts = {}, cb =(->) ) ->
  #- data is a JSON
  #- widgetname is a namestring(not a jquery object)

  #- the optionss
  #- opts.default  (representa el id que queres que se muestre por defecto)
  defaultsOptions = 
    'id': 'id'
    'showname': 'nombre'
    'select2': if typeof window.orientation isnt "undefined" then true else false 
    'empty':true
  #- fin options
  opts = $.extend(defaultsOptions, opts);

  select.onlyLoad(widgetname, data, opts["id"], opts["showname"], opts.empty, (err)->
    if opts["default"]?
      select.setID(widgetname,opts.default)
    if opts["select2"]
      select.makeSelect2(widgetname)
    cb(0)
  )
select.loadMultiple = (selector, _data, callback) ->
  if typeof(_) != 'undefined'
    _data = _.sortBy(_data, 'text')
  $(selector).select2
    formatNoMatches : (term) -> 
      "No se encontraron coincidencias"
    createSearchChoice: (term, data) ->
      if $(data).filter(->
        @text.localeCompare(term) is 0
      ).length is 0
        id: term
        text: term
    data: _data
    multiple: true
  if callback
    callback()

select.loadMultipleEdit = (selector, preload_data, callback) ->
  if preload_data
    _data = {}
    for item in preload_data
      _data[item.id] = item.text
    $(selector).select2
      data: preload_data
      multiple: true
      formatNoMatches : (term) -> 
        "No se encontraron coincidencias"
      initSelection: (
        (element, callback) ->
          data = []
          if element.val() isnt ""
            elements = element.val().split(",")
            for current in elements
              data.push 
                id: current
                text: _data[current]
          callback(data);
      )
    $('.select2-container').removeClass('form-control')
    $('.select2-container').css('width','100%')

if not @["meg"]?
  @["meg"] = {}
@["meg"]["select"] = select