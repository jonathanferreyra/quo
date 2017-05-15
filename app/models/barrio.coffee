module.exports = (compound, Barrio) ->

  Barrio.validatesPresenceOf('name', {message: 'no puede ser un texto vacío'})
  Barrio.validatesPresenceOf('localidad', {message: 'no puede ser un texto vacío'})
  Barrio.validatesNumericalityOf('lat', {message:{number:'debe sr numérico'}})
  Barrio.validatesNumericalityOf('long', {message:{number:'debe sr numérico'}})

  #linkBy: id | json
  #hard : true | false
  # si hard es false reemplaza por '' las ocurrencias de dicho id
  # si hard es true borra el documento referencia
  Barrio.meta = () ->
    return meta =
      model:'barrio'
      url: 'barrios'
      title: 'Barrio'
      pluralTitle: 'Barrios'
      attrText: 'name'
      typeRef:'soft'
      exportable:false
      useIdentity:false
      attrs :
        name:
          text:'Nombre'
          required:true
        localidad:
          text:'Localidad'
          required:true
          ref: 'Localidad'
      references:
        linkBy:'id'
        attr:'barrio'
        models:[
          'Tarjetabienvenida'
          'Familia'
          'Miembro'
          'Grupocrecimiento'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:['getMembers']
        ignore:['getMembers','show_json']

  Barrio.getMembers = (iglesiaId, itemId, cb) ->
    compound.meg.cache.find({
      'i': iglesiaId
      'barrio': itemId
      'model':'Miembro'
    }, cb)