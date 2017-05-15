module.exports = (compound, Estadomembresia) ->

  Estadomembresia.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})

  Estadomembresia.meta = () ->
    return meta =
      model:'estadomembresia'
      url:'estadomembresias'
      title: 'Estado de membresía'
      pluralTitle: 'Estados de membresía'
      useIdentity:false
      attrText: 'nombre'
      typeRef:'soft'
      redirectToIndexBeforeCreate:true
      attrs :
        nombre:
          text:'Nombre'
          required:true
      references:
        attr:'estado_membresia'
        linkBy:'id'
        models:[
          'Miembro'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]
