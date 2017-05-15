module.exports = (compound, Miembro) ->

  Miembro.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})
  Miembro.validatesPresenceOf('apellido', {message: 'no puede ser un texto vacío'})

  Miembro.meta = () ->
    return meta =
      model:'miembro'
      url:'miembros'
      title: 'Miembro'
      pluralTitle: 'Miembros'
      attrText: ['ide', 'nombre', 'apellido']
      attrs :
        ide:
          text:'#'
          type:'number'
          unique:true
        nombre:
          text:'Nombre'
          required:true
        apellido:
          text:'Apellido'
          required:true
        sexo:
          text:'Sexo'
        clasificacion_social:
          text:'Clasificación social'
          ref: 'Clasificacionsocial'
        direccion:
          text:'Dirección'
        barrio:
          text:'Barrio'
          ref:'Barrio'
        localidad:
          text:'Localidad'
          ref:'Localidad'
        emails:
          text:'Emails'
        telefonos:
          text:'Teléfonos'
        familia:
          text:'Familia'
          ref:'Familia'
        relacion_familia:
          text:'Relación con la familia'
        ministerio:
          text:'Ministerios'
          ref:'Ministerio'
        fecha_nacimiento:
          text:'Fecha de nacimiento'
        lugar_nacimiento:
          text:'Lugar de nacimiento'
        estado_civil:
          text:'Estado civil'
          ref:'Estadocivil'
        fecha_matrimonio:
          text:'Fecha de matrimonio'
        nacionalidad:
          text:'Nacionalidad'
        nro_documento:
          text:'Nro documento'
        profesion_oficio:
          text:'Profesión u oficio'
        lugar_trabajo:
          text:'Lugar de trabajo'
        puesto:
          text:'Puesto que ocupa'
        tipo_sangre:
          text:'Tipo de sangre'
        alergias:
          text:'Alérgias o indicaciones médicas'
        capacidades_diferentes:
          text:'Capacidades diferentes o especiales'
        razon_alta:
          text:'Razón alta'
        pertenece_gc:
          text:'Grupo al que pertenece'
          ref: 'Grupocrecimiento'
        fecha_conversion:
          text:'Fecha de conversión'
        fecha_bautismo:
          text:'Fecha de bautismo'
        iglesia_bautismo:
          text:'Lugar e iglesia de bautismo'
        ministro_bautizo:
          text:'Ministro que lo/a bautizó'
        fecha_inicio_membresia:
          text:'Fecha inicio membresía aquí'
        asistia_otra_iglesia:
          text:'A que iglesia asistía'
        invitado_por:
          text:'Invitado por'
        forma_contactado:
          text:'Forma en que fue contactado'
        estado_membresia:
          text:'Estado de membresía'
          ref: 'Estadomembresia'
        bautizado_por_inmersion:
          text:'Bautizado por inmersión'
          type:'bool'
        bautizado_en_esta_iglesia:
          text:'Fue bautizado en esta iglesia'
          type:'bool'
        recibio_bautismo_es:
          text:'Recibió bautismo del Espíritu Santo'
          type:'bool'
        padres_miembros_esta_iglesia:
          text:'Padres son miembros de esta iglesia'
          type:'bool'
        conyuge_miembro_esta_iglesia:
          text:'Cónyuge miembro esta iglesia'
          type:'bool'
        nombre_conyuge:
          text:'Nombre del cónyuge'
        nro_hijos:
          text:'Nro de hijos'
          type:'number'
        observaciones:
          text:'Observaciones'
      typeRef:'soft'
      references:
        attr:'miembro'
        linkBy:'id'
        models:[
        ]
      actions:
        exclude:[]
        include:[
          {action:'stats', showName:'Ver estadísticas'}
        ]
        ajax:['empty_family']
        ignore:['goTo','empty_family','metaFields']

  # Retorna los miembros que no han sido
  # agregados a una familia todavia
  Miembro.getEmptyFamily = (iglesiaId, cb) ->
    Miembro.all
      where:
        'i': iglesiaId
    , (err, items) ->
      result = []
      for item in items
        _item = item.toObject()
        if _item.hasOwnProperty('familia')
          if _item.familia is undefined or _item.familia == ''
            result.push _item
        else
          result.push _item
      cb(err, result)
