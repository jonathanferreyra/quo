before 'global vars', ->
  @correo_contacto = 'contacto@informaticameg.com'
  next()

action 'inicio', ->
  @title = 'QUO'
  render()

action 'planes', ->
  @title = 'Planes'
  render()

action 'contactar', ->
  @title = 'Contactar'
  render()

action 'contrato', ->
  @title = 'Contrato de servicio'
  render()

action 'faq', ->
  @title = 'Preguntas frecuentes'
  render()