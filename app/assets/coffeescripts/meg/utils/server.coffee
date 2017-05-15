###*
@license MEG server vs 1.5
Informatica MEG - 2014 Todos los derechos reservados
###
#- DEPENDENCIES = JQUERY

server = {}

###* @expose ###
server.ajax = (aUrl, opts = {},cb) ->
  successFunction = (data) ->
    if data
      if data.code
        cb(0, data.data)
      else
        cb(0, data)
    else
      console.log "NOT DATA EXIST"
      cb(1,null)

  errorFunction = ->
    cb( 1 , "ERROR RETRIEVE DATA in " + aUrl)

  defaultsOptions = 
    "dataType" : 'json'
    "async" : true
    "success": successFunction
    "error": errorFunction

  $.ajax aUrl, $.extend(defaultsOptions, opts);

###* @expose ###
server.ajaxPost = (aUrl, data, cb) ->
  if not data.hasOwnProperty('authenticity_token')
    data.authenticity_token = $("meta[name=csrf-token]").attr("content")
  $.ajax({
    type: "POST",
    url: aUrl,
    data: data,
    success: cb,
    error:cb,
    dataType: 'json'
  })

if not @["meg"]?
  @["meg"] = {}
@["meg"]["server"] = server