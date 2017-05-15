module.exports = (compound, Regsemanalgc) ->

  Regsemanalgc.validatesPresenceOf('fecha', {message: 'no puede ser un texto vacío'})
  Regsemanalgc.validatesPresenceOf('hora_inicio', {message: 'no puede ser un texto vacío'})
  Regsemanalgc.validatesPresenceOf('hora_cierre', {message: 'no puede ser un texto vacío'})
  Regsemanalgc.validatesPresenceOf('grupo', {message: 'no puede ser un texto vacío'})
  
  Regsemanalgc.meta = () ->
    return meta =
      model:'regsemanalgc'
      url:'regsemanalgcs'
      title: 'Registro asistencia'
      pluralTitle: 'Registro asistencias'
      attrText: 'fecha'
      exportable:false
      attrs :
        grupo:
          text:'Grupo'
          ref:'Grupocrecimiento'
        fecha:
          text:'Fecha'
          type:'date'
        hora_inicio:
          text:'Hora inicio'
        hora_cierre:
          text:'Hora cierre'
        tema_compartido:
          text:'Tema compartido'
        anfitriones:
          text:'Anfitriones'
        miembros_de_equipo:
          text:'Miembros de equipo'
        asistentes_frecuentes:
          text:'Asistentes frecuentes'
        personas_por_primera_vez:
          text:'Personas por primera vez'
        nuevos_iglesia:
          text:'Nuevos de esta iglesia'
        otras_iglesias:
          text:'De otras iglesias'
        ninios_menores:
          text:'Niños menores de 10 años'
        dirigio_el_devocional:
          text:'Quién dirigió el devocional'
        oro_por_las_necesidades:
          text:'Quién oró por las necesidades'
        recogio_la_ofrenda:
          text:'Quién recogio la ofrenda'
        oro_por_la_silla_vacia:
          text:'Quién oró por la silla vacía'
        ofrenda_habitual:
          text:'Ofrenda habitual'
        ofrenda_misionera:
          text:'Ofrenda misionera'
        otras_ofrendas:
          text:'Otras ofrendas'
        diezmos:
          text:'Diezmos'
        nro_sobres:
          text:'Nro sobres'
        actividad_semana:
          text:'Actividad realizada para ganar en la semana'
        comentario_resultado:
          text:'Comentario del resultado obtenido'
        decisiones_1era_vez:
          text:'Total de decisiones por primera vez'
        observaciones:
          text:'Observaciones'
        total_asistencias:
          text:'Total de asistencias'
        anfitrion:
          text:'Anfitrión'
        direccion:
          text:'Dirección'
        reunion_suspendida:
          text:'Reunión suspendida'
          type:'bool'
        motivo_reunion_suspendida:
          text:'Motivo suspensión de la reunión'
      typeRef:'hard'
      references:{}
      actions:
        exclude:[]
        include:[]
        ajax:[
          'asistentes'
          'getByGrupo'
          'asistencias_mensuales_gcs_total'
          'getTime'
        ]
        ignore:[
          'asistentes'
          'getByGrupo'
          'asistencias_mensuales_gcs_total'
          'getTime'
        ]

  parseDate = (stringDate) ->
    # viene en formato dd/mm/yyyy
    valores = stringDate.split('/')
    return new Date(valores[2], valores[1]-1, valores[0], 0, 0, 0, 0)

  getDataInterest = (doc) ->
    interest =
      id: doc.id
      gc: doc.gc
      fecha: doc.fecha
      hora_inicio: doc.hora_inicio
      hora_cierre: doc.hora_cierre
      total_asistencias: doc.total_asistencias
      tema_compartido: doc.tema_compartido
    interest

  Regsemanalgc.cantidadAsistencias = (doc) ->
    keys = ['anfitriones', 'miembros_de_equipo', 'asistentes_frecuentes',
      'personas_por_primera_vez', 'nuevos_iglesia', 'otras_iglesias'
    ]
    cantidad = 0
    nombres = []
    for key in keys
      if doc[key] != ''
        values = doc[key].split(',')
        cantidad += values.length
    return cantidad

  Regsemanalgc.splitKeys = (doc, cb) ->
    keys = ['anfitriones', 'miembros_de_equipo', 'asistentes_frecuentes',
    'personas_por_primera_vez', 'nuevos_iglesia', 'otras_iglesias'
    ]
    try
      doc = doc.toObject()
    catch e

    for key in keys
      if typeof doc[key] == 'string'
        if doc[key] != ''
          parts = doc[key].split(',')
          doc[key] = parts
    cb(doc)

  Regsemanalgc.asistenciasMensualesTotales = (params, cb) ->
    year = parseInt(params.year)
    month = parseInt(params.month)
    Regsemanalgc.all
      where:
        'i': params.i
    , (err, regsemanalgcs) =>
      compound.models.Grupocrecimiento.all
        where:
          'i': params.i
      , (err, all_gcs) =>
        # obtenemos los numeros de GCs existentes
        number_gcs = [parseInt(gc.nro) for gc in all_gcs][0]

        # generamos un dict donde cada key sera el num de GC
        results = {}
        promedios = {}
        for nro_gc in number_gcs
          results[nro_gc] = {
            total: 0
            cant : 0
          }

        # por cada reg_gc se realiza la sumatoria de asistencias
        for doc in regsemanalgcs
          # format: dd/mm/yyyy
          fecha = doc.fecha.split('/')
          if parseInt(fecha[1]) == month and parseInt(fecha[2]) == year
            results[parseInt(doc.gc)]['total'] += parseInt(doc.total_asistencias)
            results[parseInt(doc.gc)]['cant'] += 1

        # se parsea para enviar en formato compatible con Morris
        to_send = []
        for nro_gc in Object.keys(results)
          to_send.push {
            gc: nro_gc,
            promedio_asistencias: parseInt(results[nro_gc]['total'] / results[nro_gc]['cant'])
            total: results[nro_gc]['total']
          }
        cb(err, to_send)

  Regsemanalgc.obtener = (iglesiaId, lapso, callback) ->
    datejs = require('safe_datejs')
    today = new Date().AsDateJs()

    fInicio = 0
    fFinal = 0
    if lapso == 'esta_semana'
      date_options = { millisecond: 0, second: 0, minute: 0, hour: 0 }
      today = new Date().AsDateJs()
      if today.is().monday()
          fInicio = today.set(date_options)
      else
          fInicio = today.last().monday()
      today = new Date().AsDateJs()
      if today.is().sunday()
          fFinal = today.set(date_options)
      else
          fFinal = today.next().sunday()
    else if lapso == 'semana_pasada'
      date_options = { millisecond: 0, second: 0, minute: 0, hour: 0 }
      today = new Date().AsDateJs()
      if today.is().monday()
          fInicio = today.set(date_options)
      else
          fInicio = today.last().monday()
      today = new Date().AsDateJs()
      if today.is().sunday()
          fFinal = today.set(date_options)
      else
          fFinal = today.next().sunday()
      fInicio = fInicio.addDays(-7)
      fFinal = fFinal.addDays(-7)
    else if lapso == 'este_mes'
      fInicio = today.moveToFirstDayOfMonth()
      today = new Date().AsDateJs()
      fFinal = today.moveToLastDayOfMonth()
    else if lapso == 'mes_pasado'
      fInicio = today.moveToFirstDayOfMonth().addMonths(-1)
      today = new Date().AsDateJs()
      fFinal = today.moveToFirstDayOfMonth().addDays(-1)

    query =
      'model':'Regsemanalgc'
      'i': iglesiaId
    if lapso == 'pasado'
      compound.meg.cache.find query, (err, docs) ->
        callback(err, docs)
    else
      fInicio = fInicio.valueOf()
      fFinal = fFinal.valueOf()
      compound.meg.cache.find query, (err, docs) =>
        compound.async.filter docs, ((doc, cb) =>
          fecha = parseDate(doc.fecha).valueOf()
          condition = (fecha >= fInicio and fecha <= fFinal)
          cb(condition)
        ), (results) ->
          compound.async.map results, ((doc, mapCb) ->
            mapCb(null, getDataInterest(doc))
          ), (err, results) ->
            callback(null, results)