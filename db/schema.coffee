###############################################################
# SYSTEM
###############################################################

User = define 'User', ->
  property 'creation_date', String
  #
  property 'deleted', Boolean, default: false
  property 'displayName', String
  property 'email', String, default: ''
  property 'openId', String, default: ''
  property 'roles', String, default: ''
  # lisa de emails con los que
  # el usuario ingresara al sistema
  property 'account_emails', String, default: ''
  property 'avatar_url', String, default: ''
  property 'disabled_date', String, default: ''
  property 'lastActionDate', String, default: ''
  property 'lastActionId', String, default: ''
  # lista de ids iglesia al que
  # el usuario puede acceder
  property 'iglesias', String, default:''

Accountinfo = define 'Accountinfo', ->
  property 'creation_date', String
  # datos de la cuenta del usuario-cliente
  property 'nombre', String
  property 'apellido', String
  property 'telefonos', String, default: ''
  property 'emails', String, default: ''
  property 'pais', String, default: ''
  property 'fechaAlta', String, default: ''
  property 'user', String, default: ''
  # modalidad contratada
  property 'mode', Number, default: 1

Sharedinfo = define 'Sharedinfo', ->
  property 'creation_date', String
  # lista de ids iglesia que comparten la informacion
  property 'iglesias', String, default: ''

Timespan = describe 'Timespan', ->
  property 'i', String, default:''
  property 'id', String
  property 'v', String
  property 'creation_date', Date
  set 'restPath', pathTo.timespans

Role = describe 'Role', ->
  property 'i', String, default:''
  property 'creation_date', String
  property 'name', String
  property 'description', String, default: ''
  property 'raw_name', String, default: ''
  property 'permissions', String, default: ''
  set 'restPath', pathTo.roles

Useraccess = describe 'Useraccess', ->
  property 'i', String, default:''
  property 'user', String, default: ''
  property 'datetime', String, default: ''
  property 'action', String, default: ''
  property 'controller', String, default: ''
  property 'method', String, default: ''
  property 'isValues', String, default: ''
  property 'Browser', String, default: ''
  property 'Version', String, default: ''
  property 'OS', String, default: ''
  property 'Platform', String, default: ''
  property 'GeoIP', String, default: ''
  property 'docId', String, default: ''
  set 'restPath', pathTo.useraccesses

Setting = describe 'Setting', () ->
  property 'i', String, default:''
  property 'creation_date', String
  property 'familia_last_ide', Number, default: 1
  property 'miembro_last_ide', Number, default: 1
  property 'tarjeta_bienvenida_last_ide', Number, default: 1

Iglesia = describe 'Iglesia', ->
  property 'creation_date', String
  property 'nombre', String, default: ''
  property 'direccion', String, default:''
  property 'localidad', String, default:''
  property 'provincia', String, default:''
  property 'pais', String, default:'Argentina'
  property 'telefonos', String, default:''
  property 'nombre_pastor', String, default:''
  property 'emails', String, default:''
  property 'sitio_web', String, default:''
  property 'info_adicional', String, default:''
  property 'dia_servicio_semana', String, default:''
  property 'dia_servicio_principal', String, default:''
  # dict de usuarios permitidos para la iglesia
  # {idUser1:idRole1, idUser2:idRole2, ...}
  property 'users', String, default:''
  # lista de ids usuarios propietarios
  property 'owners', String, default:''
  # referencia a doc Sharedinfo
  property 'shared_info', String, default:''
  set 'restPath', pathTo.iglesias

Client = describe 'Client', ->
  property 'nombre', String

###############################################################
# GLOBAL INFORMATION
###############################################################

Pais = describe 'Pais', ->
  property 'name', String
  property 'locale', String
  property 'phonePrefix', String
  set 'restPath', pathTo.paises

Provincia = describe 'Provincia', ->
  property 'name', String
  property 'pais', String
  property 'lat', Number, default: 0
  property 'long', Number, default: 0
  set 'restPath', pathTo.provincias

Localidad = describe 'Localidad', ->
    property 'name', String
    property 'provincia', String, default: ''
    property 'cp', String, default: ''
    property 'lat', Number, default: 0
    property 'long', Number, default: 0
    set 'restPath', pathTo.localidades

Barrio = describe 'Barrio', ->
    property 'name', String
    property 'localidad', String, default: ''
    property 'lat', Number, default: 0
    property 'long', Number, default: 0
    set 'restPath', pathTo.barrios

###############################################################
# GRUPOS
###############################################################

Grupocrecimiento = describe 'Grupocrecimiento', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'nro', Number
    property 'timonel', String, default: ''
    property 'anfitrion', String, default: ''
    property 'direccion', String, default: ''
    property 'timoteo', String, default: ''
    property 'horario', String, default: ''
    property 'dia_de_la_semana', String, default: ''
    property 'barrio', String, default: ''
    property 'localidad', String, default: ''
    set 'restPath', pathTo.grupocrecimientos

Regsemanalgc = describe 'Regsemanalgc', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'grupo', String, default: ''
    property 'anfitrion', String, default: ''
    property 'direccion', String, default: ''
    property 'fecha', String, default: ''
    property 'hora_inicio', String, default: ''
    property 'hora_cierre', String, default: ''
    property 'tema_compartido', String, default: ''
    property 'reunion_suspendida', Boolean, default: false
    property 'motivo_reunion_suspendida', String, default: ''
    property 'anfitriones', String, default: ''
    property 'miembros_de_equipo', String, default: ''
    property 'asistentes_frecuentes', String, default: ''
    property 'personas_por_primera_vez', String, default: ''
    property 'nuevos_iglesia', String, default: ''
    property 'otras_iglesias', String, default: ''
    property 'ninios_menores', Number, default: 0
    property 'dirigio_el_devocional', String, default: ''
    property 'oro_por_las_necesidades', String, default: ''
    property 'recogio_la_ofrenda', String, default: ''
    property 'oro_por_la_silla_vacia', String, default: ''
    property 'ofrenda_habitual', Number, default: 0
    property 'ofrenda_misionera', Number, default: 0
    property 'otras_ofrendas', Number, default: 0
    property 'diezmos', Number, default: 0
    property 'nro_sobres', Number, default: 0
    property 'actividad_semana', String, default: ''
    property 'comentario_resultado', String, default: ''
    property 'decisiones_1era_vez', Number, default: 0
    property 'observaciones', String, default: ''
    property 'total_asistencias', Number, default: 0
    set 'restPath', pathTo.regsemanalgcs

###############################################################
# MEMBRESIA
###############################################################

Miembro = describe 'Miembro', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'ide', Number
    property 'apellido', String, default: ''
    property 'nombre', String, default: ''
    property 'sexo', String, default: ''
    property 'direccion', String, default: ''
    property 'barrio', String, default: ''
    property 'localidad', String, default: ''
    property 'familia', String, default: ''
    property 'relacion_familia', String, default: ''
    property 'telefonos', String, default: ''
    property 'redes_sociales', String, default: ''
    property 'emails', String, default: ''
    property 'ministerio', String, default: ''
    property 'fecha_nacimiento', String, default: ''
    property 'lugar_nacimiento', String, default: ''
    property 'estado_civil', String, default: ''
    property 'fecha_matrimonio', String, default: ''
    property 'nacionalidad', String, default: ''
    property 'nro_documento', String, default: ''
    property 'profesion_oficio', String, default: ''
    property 'lugar_trabajo', String, default: ''
    property 'puesto', String, default: ''
    property 'tipo_sangre', String, default: ''
    property 'alergias', String, default: ''
    property 'capacidades_diferentes', String, default: ''
    property 'razon_alta', String, default: ''
    property 'pertenece_gc', String, default: ''
    property 'clasificacion_social', String, default: ''
    property 'fecha_conversion', String, default: ''
    property 'fecha_bautismo', String, default: ''
    property 'iglesia_bautismo', String, default: ''
    property 'ministro_bautizo', String, default: ''
    property 'fecha_inicio_membresia', String, default: ''
    property 'asistia_otra_iglesia', String, default: ''
    property 'invitado_por', String, default: ''
    property 'forma_contactado', String, default: ''
    property 'estado_membresia', String, default: ''
    property 'bautizado_en_esta_iglesia', Boolean, default: false
    property 'bautizado_por_inmersion', Boolean, default: false
    property 'recibio_bautismo_es', Boolean, default: false
    property 'padres_miembros_esta_iglesia', Boolean, default: false
    property 'conyuge_miembro_esta_iglesia', Boolean, default: false
    property 'nombre_conyuge', String, default: ''
    property 'nro_hijos', String, default: ''
    property 'observaciones', String, default: ''
    property 'tarjeta_bienvenida', String, default:''
    set 'restPath', pathTo.miembros

Ministerio = describe 'Ministerio', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'nombre', String
    property 'descripcion', String, default: ''
    set 'restPath', pathTo.ministerios

Familia = describe 'Familia', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'ide', Number
    property 'nombre', String
    property 'direccion', String, default: ''
    property 'barrio', String, default: ''
    property 'localidad', String, default: ''
    property 'telefonos', String, default: ''
    set 'restPath', pathTo.familias

Tarjetabienvenida = describe 'Tarjetabienvenida', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'ide', Number
    property 'motivo_oracion', String, default: ''
    property 'apellido', String, default: ''
    property 'nombre', String, default: ''
    property 'estado_civil', String, default: ''
    property 'edad', String, default: ''
    property 'clasificacion_social', String, default: ''
    property 'direccion', String, default: ''
    property 'barrio', String, default: ''
    property 'localidad', String, default: ''
    property 'telefonos', String, default: ''
    property 'email', String, default: ''
    property 'religion', String, default: ''
    property 'religion_otro', String, default: ''
    property 'tipo_desicion', String, default: ''
    property 'tipo_desicion_otro', String, default: ''
    property 'amigo_que_trajo', String, default: ''
    property 'telefono_amigo', String, default: ''
    property 'horario_para_llamar', String, default: ''
    property 'observaciones', String, default: ''
    property 'nombre_que_lleno_tarjeta', String, default: ''
    property 'lugar_lleno_tarjeta', String, default: ''
    property 'evento', String, default: ''
    property 'fecha', String, default: ''
    property 'miembro', String, default: ''
    property 'ultimo_seguimiento', String, default:''
    property 'sexo', String, default: ''
    set 'restPath', pathTo.tarjetabienvenidas

Evento = describe 'Evento', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'nombre', String
    property 'descripcion', String, default: ''
    property 'fecha', String, default: ''
    set 'restPath', pathTo.eventos

Seguimientopersona = describe 'Seguimientopersona', ->
    property 'i', String, default:''
    property 'creation_date', String
    property 'user', String, default: ''
    property 'fecha', String, default: ''
    property 'comentarios', String, default: ''
    property 'tarjeta_bienvenida', String, default: ''
    property 'estado', String, default: ''
    set 'restPath', pathTo.seguimientopersonas

###############################################################
# TABLAS BASICAS
###############################################################

Clasificacionsocial = describe 'Clasificacionsocial', ->
    property 'sharedId', String, default:''
    property 'creation_date', String
    property 'nombre', String
    property 'caracteristicas', String, default: ''
    set 'restPath', pathTo.clasificacionsocials

Estadomembresia = describe 'Estadomembresia', ->
    property 'sharedId', String, default:''
    property 'creation_date', String
    property 'nombre', String
    set 'restPath', pathTo.estadomembresias

Estadocivil = describe 'Estadocivil', ->
    property 'sharedId', String, default:''
    property 'creation_date', String
    property 'nombre', String
    set 'restPath', pathTo.estadosciviles