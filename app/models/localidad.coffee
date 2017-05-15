module.exports = (compound, Localidad) ->

  Localidad.validatesPresenceOf('name', {message: 'no puede ser un texto vacío'})
  Localidad.validatesPresenceOf('provincia', {message: 'no puede ser un texto vacío'})
  Localidad.validatesNumericalityOf('lat', {message:{number:'debe sr numérico'}})
  Localidad.validatesNumericalityOf('long', {message:{number:'debe sr numérico'}})

  Localidad.meta = () ->
    return meta =
      model:'localidad'
      url:'localidades'
      title: 'Localidad'
      pluralTitle: 'Localidades'
      attrText: 'name'
      typeRef:'hard'
      exportable:false
      useIdentity:false
      attrs :
        name:
          text:'Nombre'
          required:true
        cp:
          text:'Código postal'
          type:'number'
        provincia:
          text: 'Provincia'
          ref: 'Provincia'
      typeRef:'hard'
      references:
        linkBy:'id'
        attr:'localidad'
        models:[
          'Barrio'
          'Familia'
          'Tarjetabienvenida'
          'Miembro'
          'Grupocrecimiento'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:['getBarrios']
        ignore:['getBarrios','show_json']

  Localidad.barrios = (itemId, cb) ->
    compound.meg.cache.find({model:'Localidad', 'localidad': itemId}, cb)