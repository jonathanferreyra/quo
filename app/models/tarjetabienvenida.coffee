module.exports = (compound, Tarjetabienvenida) ->

  Tarjetabienvenida.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})
  Tarjetabienvenida.validatesPresenceOf('fecha', {message: 'no puede ser un texto vacío'})

  Tarjetabienvenida.meta = () ->
    return meta =
      model:'tarjetabienvenida'
      url:'tarjetabienvenidas'
      title: 'Tarjeta de bienvenida'
      pluralTitle: 'Tarjetas de bienvenida'
      attrText: ['ide', 'nombre', 'apellido']
      typeRef:'full'
      references:
        linkBy:'id'
        attr:'tarjeta_bienvenida'
        models:[
          'Seguimientopersona'
        ]
      actions:
        exclude:[]
        include:[
          {action:'stats', showName:'Ver estadísticas'}
        ]
        ajax:[
          'getby'
          'getTracing'
          'storeTracing'
          'lastTracing'
          'createMember'
          'getUserName'
          'metaFields'
        ]
        ignore:[
          'getby'
          'lastTracing'
          'getTracing'
          'getUserName'
          'goTo'
          'metaFields'
        ]
      attrs :
        ide:
          text:'#'
          type:'number'
        fecha:
          text:'Fecha'
          type:'date'
        apellido:
          text:'Apellido'
        nombre:
          text:'Nombre'
        motivo_oracion:
          text:'Motivo de oración'
        edad:
          text:'Edad'
          type:'number'
        sexo:
          text:'Sexo'
        clasificacion_social:
          text:'Clasificación social'
          ref:'Clasificacionsocial'
        estado_civil:
          text:'Estado civil'
          ref:'Estadocivil'
        direccion:
          text:'Dirección'
        barrio:
          text:'Barrio'
          ref:'Barrio'
        localidad:
          text:'Localidad'
          ref:'Localidad'
        telefonos:
          text:'Teléfonos'
        email:
          text:'Email'
          type:'email'
        religion:
          text:'Religión'
        religion_otro:
          text:'Religión otro'
        tipo_desicion:
          text:'Tipo desición'
        tipo_desicion_otro:
          text:'Tipo desición otro'
        amigo_que_trajo:
          text:'Amigo que lo trajo'
        telefono_amigo:
          text:'Teléfono del amigo'
        horario_para_llamar:
          text:'Mejor horario para llamar'
        observaciones:
          text:'Observaciones'
        nombre_que_lleno_tarjeta:
          text:'Nombre del que llenó la tarjeta'
        lugar_lleno_tarjeta:
          text:'Lugar donde se llenó la tarjeta'
        evento:
          text:'Evento'
          ref:'Evento'

  Tarjetabienvenida.getBy = (iglesiaId, field, value, cb) ->
    params = {}
    params[field] = value
    params.i = iglesiaId
    Tarjetabienvenida.all where: params, cb

  # obtener seguimientos
  Tarjetabienvenida.getTracing = (iglesiaId, itemId, cb) ->
    compound.models.Seguimientopersona.all
      where:
        'tarjeta_bienvenida': itemId
        'i': iglesiaId
    , cb

  Tarjetabienvenida.storeTracing = (iglesiaId, values, userId, cb) ->
    delete values['authenticity_token']
    values['creation_date'] = new Date().toISOString()
    values['user'] = userId
    values['i'] = iglesiaId
    compound.models.Seguimientopersona.create values, (err, nuevo_seg) ->
      if !err
        Tarjetabienvenida.find nuevo_seg.tarjeta_bienvenida, (err, tarjeta) ->
          nuevo_seg = JSON.parse(JSON.stringify(nuevo_seg))
          delete nuevo_seg['user']
          delete nuevo_seg['i']
          delete nuevo_seg['_rev']
          attrs =
            ultimo_seguimiento: JSON.stringify(nuevo_seg)
          tarjeta.updateAttributes attrs, () ->
            compound.models.Timespan.refreshCacheAfterCreate(
              'tarjetabienvenidas', 'Tarjetabienvenida', tarjeta)
            compound.models.Timespan.refreshCacheBeforeCreate(
              'seguimientospersonas', 'Seguimientopersona', nuevo_seg)
            cb()
      else
        cb()

  Tarjetabienvenida.getLastTracing = (itemId, cb) ->
    Tarjetabienvenida.find itemId, (err, doc_tarjeta) ->
      if doc_tarjeta.ultimo_seguimiento
        doc_ultimo_seguimiento = JSON.parse(ultimo_seguimiento)
        compound.models.Seguimientopersona.find doc_ultimo_seguimiento.id, cb
      else
        cb(null, {})

  Tarjetabienvenida.createMember = (iglesiaId, userId, itemId, callback) ->
    Tarjetabienvenida.find itemId, (err, docItem) ->
      if err or docItem.miembro
        theError = err
        if docItem.miembro.length > 0
          theError = new Error("Esta tarjeta ya se ha convertido en miembro anteriormente")
        callback(theError, null)
      else
        iId = iglesiaId
        compound.models.Setting.getValue iId, 'miembro_last_ide', (err, ide) ->
          keys = ['apellido','nombre','direccion',
            'estado_civil','clasificacion_social','barrio',
            'localidad','email','telefonos', 'sexo']
          data = {}
          for k in keys
            data[k] = docItem[k]
          data.ide = ide
          data.tarjeta_bienvenida = docItem['id']
          data.user = userId
          data.creation_date = new Date().toISOString()
          data.i = iId
          compound.async.waterfall([
            (cb) ->
              compound.models.Miembro.create data, (err, miembro) ->
                console.log 'miembro creado...', miembro
                compound.models.Timespan.refreshCacheBeforeCreate(
                  'miembros', 'Miembro', miembro)
                cb(err, miembro)
            (miembro, cb) ->
              compound.models.Setting.incrementKey iId, 'miembro_last_ide', (err) ->
                cb(err, miembro)
            (miembro, cb) ->
              docItem.updateAttribute 'miembro', miembro.id, (err) ->
                console.log 'tb updated...', docItem
                compound.models.Timespan.refreshCacheAfterCreate(
                  'tarjetabienvenidas', 'Tarjetabienvenida', docItem)
                cb(err, miembro)
          ], callback )

  Tarjetabienvenida.getUserName = (itemId, cb) ->
    Tarjetabienvenida.find itemId, (err, tarjeta) ->
      if !err
        compound.models.User.find tarjeta.user, (err, user) ->
          name = ''
          if user
            name = user.displayName
          cb(err, {nombre:name})
      else
        cb(err, {nombre:''})


