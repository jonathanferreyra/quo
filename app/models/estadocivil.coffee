module.exports = (compound, Estadocivil) ->

  Estadocivil.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})

  Estadocivil.meta = () ->
    return meta =
      model:'estadocivil'
      url:'estadosciviles'
      title: 'Estado civil'
      pluralTitle: 'Estados civiles'
      attrText: 'nombre'
      typeRef:'soft'
      useIdentity:false
      redirectToIndexBeforeCreate:true
      attrs :
        nombre:
          text:'Nombre'
          required:true
      references:
        attr:'estado_civil'
        linkBy:'id'
        models:[
          'Tarjetabienvenida'
          'Miembro'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]