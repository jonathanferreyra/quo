@defaults =
  telefonos:
    principal : 'Principal'
    movil : 'Móvil'
    casa : 'Casa'
    trabajo : 'Trabajo'
    fax : 'Fax'
    otro : 'Otro'
  redes_sociales:
    facebook:'Facebook'
    gplus:'Google +'
    twitter:'Twitter'
    skype:'Skype'
    pinterest:'Pinterest'
    youtube:'Youtube'
  dias_semanales:
    lun:'Lunes'
    mar:'Martes'
    mie:'Miércoles'
    jue:'Jueves'
    vie:'Viernes'
    sab:'Sábado'
    dom:'Domingo'
  sexo:
    m : 'Masculino'
    f : 'Femenino'
  days:
    Mon:'Lunes'
    Tue:'Martes'
    Wed:'Miércoles'
    Thu:'Jueves'
    Fri:'Viernes'
    Sat:'Sábado'
    Sun:'Domingo'
  months:
    Jan:'Enero'
    Feb:'Febrero'
    Mar:'Marzo'
    Apr:'Abril'
    May:'Mayo'
    Jun:'Junio'
    Jul:'Julio'
    Aug:'Agosto'
    Sep:'Septiembre'
    Oct:'Octubre'
    Nov:'Noviembre'
    Dec:'Diciembre'

  get:(attr, keyId='id', keyText='text') ->
    # retorna una lista en formato
    # [{id:'', text:''}] sobre un attributo
    # uso:
    #   defaults.get('telefonos')
    #   defaults.get('telefonos', 'someNameId', 'someNameText')
    result = []
    for k, v of @[attr]
      item = {}
      item[keyId] = k
      item[keyText] = v
      result.push(item)
    result
