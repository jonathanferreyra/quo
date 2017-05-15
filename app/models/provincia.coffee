module.exports = (compound, Provincia) ->

  Provincia.validatesPresenceOf('name', {message: 'no puede ser un texto vacío'})
  Provincia.validatesPresenceOf('pais', {message: 'no puede ser un texto vacío'})
  Provincia.validatesNumericalityOf('lat', {message:{number:'debe sr numérico'}})
  Provincia.validatesNumericalityOf('long', {message:{number:'debe sr numérico'}})

  Provincia.meta = () ->
    return meta =
      model:'provincia'
      url:'provincias'
      title: 'Provincia'
      pluralTitle: 'Provincias'
      attrText: 'name'
      typeRef:'hard'
      exportable:false
      useIdentity:false
      attrs : {}
      references:
        linkBy:'id'
        attr:'provincia'
        models:[
          'Localidad'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:['getLocalities']
        ignore:['getLocalities','show_json']

  Provincia.getLocalities = (itemId, cb) ->
    compound.meg.cache.find({model:'Localidad', provincia: itemId}, cb)