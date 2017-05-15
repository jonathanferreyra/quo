module.exports = (compound, Clasificacionsocial) ->

  Clasificacionsocial.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})

  Clasificacionsocial.meta = () ->
    return meta =
      model:'clasificacionsocial'
      url: 'clasificacionsocials'
      title: 'Clasificación social'
      pluralTitle: 'Clasificaciones sociales'
      useIdentity:false
      attrText: 'nombre'
      typeRef:'soft'
      redirectToIndexBeforeCreate:true
      attrs :
        nombre:
          text:'Nombre'
          required:true
        caracteristicas:
          text:'Características'
      references:
        linkBy:'id'
        attr:'clasificacion_social'
        models:[
          'Tarjetabienvenida'
          'Miembro'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:['getMembers']
        ignore:['getMembers']

  Clasificacionsocial.getMembers = (iglesiaId, itemId, cb) ->
    compound.models.Miembro.all
      where :
        'i': iglesiaId
        'clasificacion_social' : itemId
      , cb
