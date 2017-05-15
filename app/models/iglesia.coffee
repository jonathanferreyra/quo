module.exports = (compound, Iglesia) ->

  Iglesia.meta = () ->
    return meta =
      model:'iglesia'
      url:'iglesias'
      title: 'Iglesia'
      pluralTitle: 'Iglesias'
      attrText: 'nombre'
      typeRef:'hard'
      attrs :
        nombre:
          text:'Nombre'
        direccion:
          text:'Dirección'
        localidad:
          text:'Localidad'
          ref:'Localidad'
        provincia:
          text:'Provincia'
          ref:'Provincia'
        pais:
          text:'Pais'
        telefonos:
          text:'Teléfono'
        nombre_pastor:
          text:'Nombre pastor'
        emails:
          text:'Emails'
        sitio_web:
          text:'Sitio web'
        info_adicional:
          text:'Información adicional'
        dia_servicio_semana:
          text:'Día servicio semana'
        dia_servicio_principal:
          text:'Día servicio principal'
      references:
        linkBy:'id'
        attr:'iglesia'
        models:[]
      actions:
        exclude:["new", "create", "destroy", "show", "update", "index"]
        include:[{action:'update', showName:'Cambiar los datos de la iglesia'}]
        ajax:[]
        ignore:['index']