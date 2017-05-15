@values =
  sexo:
    m : 'Masculino'
    f : 'Femenino'
  razon_alta :
    bautismo: 'Bautismo '
    captura_inicial: 'Captura inicial'
    carta_traslado: 'Carta traslado'
    carta_recomendacion: 'Carta recomendación'
    incorporacion: 'Incorporación'
    otro: 'Otro'
  relacion_familia:
    padre: 'Padre'
    madre: 'Madre'
    hijo: 'Hijo/a'
    abuelo: 'Abuelo/a'
    tio: 'Tío/a'
  tipo_sangre: {}

for t in ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
  @values.tipo_sangre[t] = t