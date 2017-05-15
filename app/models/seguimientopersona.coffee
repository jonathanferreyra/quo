module.exports = (compound, Seguimientopersona) ->
  # define Seguimientopersona here

  Seguimientopersona.meta = () ->
    return meta =   
      model:'seguimientopersona'
      url:'seguimientopersonas'
      title: 'Seguimiento'
      cache: false
      pluralTitle: 'Seguimientos'      
      attrText: ''      
      attrs : {}
      references: {}        
      actions:
        exclude:[]
        include:[]
        ajax:[]
        ignore:[]