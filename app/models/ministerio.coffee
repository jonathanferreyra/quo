module.exports = (compound, Ministerio) ->

  Ministerio.validatesPresenceOf('nombre', {message: 'no puede ser un texto vacío'})

  Ministerio.meta = () ->
    return meta =
      model:'ministerio'
      url:'ministerios'
      title: 'Ministerio'
      pluralTitle: 'Ministerios'
      attrText: 'nombre'
      typeRef:'soft'
      attrs :
        nombre:
          text:'Nombre'
          required:true
        descripcion:
          text:'Descripción'
      references:
        linkBy:'json'
        attr:'ministerio'
        jsonType:'array_dict' # array | array_dict | dict
        models:[
          'Miembro'
        ]
      actions:
        exclude:[]
        include:[]
        ajax:['getMembers']
        ignore:['getMembers']

  Ministerio.getMembers = (iId, itemId, cb) ->
    compound.models.Miembro.all
      where:
        'i': iId
    , (err, items) ->
      result = []
      keys = ['id','ide','apellido','nombre']
      for item in items
        if typeof item['ministerio'] is 'string'
          if item.ministerio.indexOf(itemId) != -1
            row = {}
            row.funcion = ''
            for k in keys
              row[k] = item[k]
            ministerios = JSON.parse(item.ministerio)
            for m in ministerios
              if m.ministerio == itemId
                value = ''
                if m.hasOwnProperty('funcion')
                  value = m.funcion
                row['funcion'] = value
              break
            result.push(row)
      cb(err, result)
