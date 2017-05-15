load 'application'

before 'load clients', ->
  #if app.get('env') == 'development'
  if not res.locals.hasOwnProperty('clients')
    compound.models.User.getUsersAccountOwner (err, items) ->
      res.locals['clients'] = items
      next()
  else
    next()
  # else
  #     next()

before 'load iglesia', ->
  compound.models.Iglesia.find session.user.i , (err, iglesia) ->
    try
      iglesia = iglesia.toObject()
    catch e

    compound.meg.utils.fillReferenceFields iglesia, ['localidad', 'provincia'], false, (err, filledIglesia) ->
      @iglesia = filledIglesia
      next()

action 'miembro', ->
  @title = 'Miembro'
  @reportName = 'Reporte de miembro'
  @itemUrl = '/miembros/' + params.id
  compound.meg.cache.get params.id, (err, raw_item) ->
    compound.meg.utils.getReferenceAttrsOfModel 'Miembro', (err, attrs) ->
      compound.meg.utils.fillReferenceFields raw_item, attrs, false, (err, filled_item) ->
        @item = filled_item
        render 'miembros/one'

action 'print', ->
  @item =
    fecha:'11/22/3333 Lunes'
    horario: '99:99'
    origen:'Posadas (MIS)'
    destino:'Ter Eldorado'
    asiento:'*99*'
    fecha_emision:'11/22/3333 00:00'
    base_tarifa:'$ 999.99'
    imp_neto:'$ 999.99'
    nro_boleto:'12345678'
    pasajero:'JUAN PEREZ D 98765432'
    pasajero_name:'JUAN PEREZ'
    pasajero_doc:'D 98765432 01/01/1990'
    caja:'USER'
    porcentaje:'0.0'
    partida:'PART1'
    viaja_por:'Viaja por: RIO RIO URUGUAY'
    row1:'Calidad de la unidad: SEMICAMA'
    row2:'Nac: Argentina - Llega: 11/22/3333 00:00'
    row3:'JUAN PEREZ D 98765432 01/01/1990'
    row4:'Se anuncia a: XXX'
    row5:''

  console.log @item
  render({layout:false})