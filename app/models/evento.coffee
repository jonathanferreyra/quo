module.exports = (compound, Evento) ->

  Evento.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})
  Evento.validatesPresenceOf('fecha', {message: 'no puede ser un texto vacío'})

  Evento.meta = () ->
    return meta =
      model:'evento'
      url:'eventos'
      title: 'Evento'
      pluralTitle: 'Eventos'
      attrText: 'nombre'
      typeRef:'soft'
      attrs :
        fecha:
          text: 'Fecha'
          type: 'date'
        nombre:
          text:'Nombre'
          required:true
        descripcion:
          text:'Descripción'
      references:
        linkBy:'id'
        attr:'evento'
        models:[
          'Tarjetabienvenida'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]