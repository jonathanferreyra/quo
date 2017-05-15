module.exports = (compound, Grupocrecimiento) ->
  # define Grupocrecimiento here
  Grupocrecimiento.validatesPresenceOf('nro', {message: 'no puede ser un texto vacío'})
  Grupocrecimiento.validatesPresenceOf('timonel', {message: 'no puede ser un texto vacío'})
  Grupocrecimiento.validatesPresenceOf('anfitrion', {message: 'no puede ser un texto vacío'})

  Grupocrecimiento.meta = () ->
    return meta =
      model:'grupocrecimiento'
      url:'grupocrecimientos'
      title: 'Grupo'
      pluralTitle: 'Grupos'
      attrText: 'nro'
      attrs :
        nro:
          text: 'Nro'
          type: 'number'
          required: true
        timonel:
          text: 'Líder/encargado'
          required: true
        anfitrion:
          text: 'Anfitrión'
          required: true
        direccion:
          text: 'Dirección'
        timoteo:
          text: 'Colaborador/ayudante'
        horario:
          text: 'Horario'
        dia_de_la_semana:
          text: 'Día de la semana'
        barrio:
          text:'Barrio'
          ref:'Barrio'
        localidad:
          text:'Localidad'
          ref:'Localidad'
      typeRef:'hard'
      references:
        attr:'gc'
        linkBy:'id'
        models:[
          'Miembro'
          'Regsemanalgc'
        ]
        excepts:
          Miembro:
            attr:'pertenece_gc'
      actions:
        exclude:[]
        include:[]
        ajax:['allgcs']
        ignore:['allgcs']