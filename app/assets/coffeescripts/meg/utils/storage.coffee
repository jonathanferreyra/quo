#MEG STORAGE vs 1.08
#Informatica MEG - Emiliano Fernandez 2013 Todos los derechos reservados
#- dependences : jx
#-               lawchair 
#-               aes (http://crypto-js.googlecode.com )
#-               JSON Mask (https://raw.github.com/nemtsov/json-mask/master/build/jsonMask.min.js)

#TODO:"soportar *.json para otras rutas que no sean modelos"


#- extra deps : modernizr(for localstorage detect)
@.meg = {} unless @.meg?
@meg.storage = {}
storage = @meg.storage

#model es el modelo en plural ex: productos

storage.checkDependencies = (model,cb)->
  if Modernizr.localstorage
    if Lawnchair?
      if jx?
        if CryptoJS.AES?
          if jsonMask?
            return true
  return false

storage.load = (model, opts, cb) ->
  opts.fields = null if !opts.fields?
  opts.remoteOnly = false if !opts.remoteOnly?
  opts.localOnly = false if !opts.localOnly?
  opts.reset = false if !opts.reset?

  storage.getTimeSpan model, (err,timespanlocal) ->
    #get remote timespan
    storage.getRemoteTimeSpan model, (err,timespanremote) ->
      if ((timespanlocal is timespanremote) and !opts.reset and !opts.remoteOnly) or opts.localOnly
        #return the local data
        return storage.getAllWithFilter(model,opts.fields,cb)
      else #tengo que buscar del server
        #get remote data
        storage.getRemoteAll model, (err,allData) ->
          #return the data
          storage.filterByKeys(allData,opts.fields,cb)
          #cargar remote data into local
          if !opts.remoteOnly
            storage.saveAll(model, allData)
            #make new index
            storage.saveIndex(model, allData, "id")
            #cargar nuevo timespan
            storage.saveTimeSpan(model, timespanremote)
            console.info "Sincronizando Datos"

storage.getTimeSpan = (model, cb) ->
  storage.getByKey(model, 'TimeSpan', (err,timespan) ->
    if err
        console.log "timespan local of #{ model } failed or not used, skipping..."
    cb(err,timespan)
  )

storage.getAll = (model, cb) ->
  console.log "Cargando datos locales."
  storage.getByKey(model, 'all', (err,allData) ->
    cb(err,allData)
  )

storage.getAllWithFilter = (model, query, cb) ->
  storage.getAll model, (err, allData) ->
    if err
      console.log "err getAllWithFilter",err, allData
    else
      storage.filterByKeys(allData,query,cb)

storage.clear = (model,cb) ->
  #TODO

storage.clearAll = (model,cb) ->
  #TODO

#-#########REMOTE###############
storage.getRemoteTimeSpan = (model, cb) ->
  storage.getRemoteData '/timespans/get/'+model+'TimeSpan', (timespan) ->
    cb(null,timespan)

storage.getRemoteAll = (model, cb) ->
  storage.getRemoteData('/' + model + '.json', (allData) ->
   _data = if allData.hasOwnProperty('data') then allData.data else allData
   cb(null,_data)
  )

storage.getRemoteData = (route, cb) ->
  jx.load(route, cb, "json")

  

#-##################BASE########################
storage.saveByKey = (model, key, data, cb=->) ->
  obj =
    key : key
    data: data
  store = new Lawnchair(
    adapter: "dom",
    name: model
  , (store) ->
    obj.data = storage.encrypt(obj.data)
    store.save obj, (returnobj) ->
      if !returnobj?
        return cb(1, "no se pudo guardar")
      cb(null,returnobj)
  )

storage.getByKey = (model, key, cb) ->
  store = new Lawnchair(
    adapter: "dom",
    name: model
  , (store) ->
    store.get key, (value) ->
      if !value?
        return cb(1,"cannot read #{ model }, #{ key }")
      data = storage.decrypt(value.data)
      return cb(null,data)
  )

#-##################SAVE #######################
storage.saveTimeSpan = (model, timespan) ->
  storage.saveByKey(model, 'TimeSpan',timespan)

storage.saveAll = (model, alldata) ->
  storage.saveByKey(model, 'all', alldata)

#-##########EXTRA#############

  #-#########SHOW########### --DEBE IRSE A OTRO JS--
storage.saveIndex = (model, allData, key) ->
  index = allData.map (aKey) -> aKey[key]
  storage.saveByKey(model, 'index_' + key,index)

storage.getPositionToIndex = (model, id, cb) ->
  storage.getByKey(model, 'index_id', (err, index) ->
    cb(err,index.indexOf(id))
  )

storage.saveToShow = (model, key,cb=->) ->
  storage.getPositionToIndex(model, key, (err, indexposition) ->
    storage.saveByKey(model, '_toShow',indexposition,(err,obj) ->
      cb(err)
    )
  )

storage.getToShow = (model,cb) ->
  storage.load model, {}, () ->
    storage.getByKey(model, '_toShow', (err, i) ->
      if err
        return cb(err,"error en getToShow")
      storage.getAll(model,(err,allData) ->
        cb(err,allData[i])
      )
    )

storage.getItem = (model, id, cb) ->
  storage.getPositionToIndex(model, id, (err, indexposition) ->
    storage.getAll(model, (err, allitems) ->
      cb(err, allitems[indexposition])
    )
  )

#- depende jquery
storage.bindEventShow = (selector,model) ->
  #- debe haber un attr item en el selector
  $(document).on "click", selector, (e)->
    e.preventDefault()
    meg.storage.saveToShow model, $(e.currentTarget).attr('item'), (err)->
      document.location = "/#{model}/show/"

#-#######ENCRYPT#################### --DEBE IRSE A UTILS--
storage.encrypt = (data, secret = 'A secret') ->
  CryptoJS.AES.encrypt(JSON.stringify(data), secret).toString()

storage.decrypt = (data, secret = 'A secret')->
  JSON.parse(CryptoJS.AES.decrypt(data, secret).toString(CryptoJS.enc.Utf8))

#-######FILTER#################### --DEBE IRSE A UTILS--
storage.filterByKeys = (rows, query, cb) ->
  if query?
    console.log "query",query
    results = []
    for row in rows
      results.push jsonMask(row, query)
    console.log results
    cb(false,results)
  else
    cb(false,rows)

#verificaciones
if !storage.checkDependencies() #checks dependencies
  alert("Dependencias no satisfechas para storage")