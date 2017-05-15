module.exports = (compound, Familia) ->

  Familia.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})

  Familia.meta = () ->
    return meta =
      model:'familia'
      url:'familias'
      title: 'Familia'
      pluralTitle: 'Familias'
      attrText: 'nombre'
      exportable:false
      typeRef:'soft'
      attrs :
        nombre:
          text: 'Nombre'
          required:true
        direccion:
          text: 'Dirección'
        barrio:
          text: 'Barrio'
          ref: 'Barrio'
        localidad:
          text:'Localidad'
          ref: 'Localidad'
        telefonos:
          text:'Teléfonos'
      typeRef:'soft'
      references:
        linkBy:'id'
        attr:'familia'
        models:[
          'Miembro'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:[
          'addMember'
          'getMembers'
          'delMember'
        ]
        ignore:['getMembers']

  Familia.getMembers = (iglesiaId, itemId, cb) ->
    compound.meg.cache.find({
      'i': iglesiaId
      'familia': itemId
    }, cb)
    #compound.models.Miembro.all
    #  where:

  Familia.addMember = (familiaId, miembroId, cb) ->
    compound.models.Miembro.find miembroId, (err, miembro) ->
      miembro.updateAttribute 'familia', familiaId, () ->
        compound.models.Timespan.refreshCacheAfterUpdate 'miembros', 'Miembro', miembro
        compound.models.Timespan.updateTS 'familias', new Date().valueOf(), cb

  Familia.delMember = (miembroId, cb) ->
    compound.models.Miembro.find miembroId, (err, miembro) ->
      miembro.updateAttribute 'familia', '', () ->
        compound.models.Timespan.refreshCacheAfterUpdate 'miembros', 'Miembro', miembro
        compound.models.Timespan.updateTS 'familias', new Date().valueOf(), cb
