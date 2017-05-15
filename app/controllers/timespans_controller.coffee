load 'application'

action 'get',->
  if params.id
    Timespan.find params.id+'TimeSpan', (err, timespan) =>
      if err || !timespan
        return send code: 404, error: 'Item Not found'
      else
        if timespan.v is req.query.t
          #enviar vacio
          send {code:304}
        else
          #enviar data
          u = compound.utils
          # console.log params.id
          # console.log use('singularizeSpa')(params.id)
          # console.log "modelsearch>>>>", use('singularizeSpa')(u.camelize(params.id,true))
          myModel = compound.models[u.singularize(u.camelize(params.id,true))]
          if myModel?
            myModel.all (err, AllItems) =>
              send code: 200, timespan: timespan.v, data: AllItems
          else
            send code: 404, error: 'Model Not found'
  else
    return send code: 404, error: 'ID Not found'