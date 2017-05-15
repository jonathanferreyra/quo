module.exports = (compound, Useraccess) ->

  Useraccess.meta = () ->
    return meta =
      model:'useraccess'
      url: 'useraccesses'
      title: 'Acceso de usuario'
      pluralTitle: 'Accesos de usuarios'
      cache:false
      attrText: ''
      typeRef:'soft'
      attrs : {}
      references: {}
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]

  Useraccess.createCustom = (new_data, useragent, cb) ->
    toSave = new_data
    toSave['isValues'] = []
    useragent['GeoIP'] = JSON.stringify(useragent['GeoIP'])
    for attrname, attrvalue of useragent
      if attrname.indexOf('is') == -1
        toSave[attrname] = attrvalue
      else
        if attrvalue
          toSave['isValues'].push(attrname)
    toSave['isValues'] = if toSave['isValues'].length > 0 then toSave['isValues'].toString() else ''

    Useraccess.create toSave, (err, useraccess) ->
      if !err
        # save in user last action executed
        compound.models.User.find toSave.user, (err, user) ->
          if !err
            attrs =
              lastActionDate: toSave.datetime
              lastActionId: useraccess.id
            user.updateAttributes attrs, cb
          else
            cb(err, null)
      else
        cb(err, null)

