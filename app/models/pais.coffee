module.exports = (compound, Pais) ->

  Pais.validatesPresenceOf('name', {message: 'no puede ser un texto vacío'})
  Pais.validatesUniquenessOf('name', {message: 'debe ser único'})

  Pais.meta = () ->
    return meta =
      model:'pais'
      url:'paises'
      title: 'País'
      pluralTitle: 'Paises'
      attrText: 'name'
      typeRef:'hard'
      exportable:false
      useIdentity:false
      attrs : {}
      references:
        linkBy:'id'
        attr:'pais'
        models:['Provincia']
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:['show_json']

  Pais.getProvinces = (itemId, cb) ->
    compound.meg.cache.find({model:'Provincia', 'pais': itemId}, cb)