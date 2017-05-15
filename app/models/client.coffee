module.exports = (compound, Client) ->

  Client.meta = () ->
    return meta =
      model:'client'
      url:'clients'
      title: 'Cliente'
      pluralTitle: 'Clientes'
      attrText: 'displayName'
      typeRef:'hard'
      exportable:false
      attrs : {}
      references:{}
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]