#menu tour
###
  gruposRootMenu
    grupocrecimientosMenu
    regsemanalgcsMenu
  membresiaRootMenu
    miembrosMenu
    familiasMenu
    ministeriosMenu
    tarjetabienvenidasMenu
    eventosMenu
  configuracionesRootMenu
    tablasBasicasMenu
      clasificacionSocialSubMenu
      estadoMembresiasSubMenu
      estadosCivilesSubMenu
    datosregionalesMenu
      barriosSubMenu
      localidadesSubMenu
      provinciasSubMenu
    palabraDiariaMenu
    iglesiasMenu
  administracionRootMenu
    usersMenu
    rolesMenu
###
#console.log Tour

openMenu = (tour) ->
  actualElement = tour.getStep(tour.getCurrentStep()).element
  menu = $(actualElement).children(".treeview-menu").first()
  btn = $(actualElement).children("a").first()
  menu.slideDown()
  btn.children(".fa-angle-left").first().removeClass("fa-angle-left").addClass "fa-angle-down"
  btn.parent("li").addClass "active"

closeMenu = (tour) ->
  actualElement = tour.getStep(tour.getCurrentStep()).element
  btn = $(actualElement).parent().parent().children("a").first()
  menu = $(actualElement).parent().parent().children(".treeview-menu").first()
  menu.slideUp()
  btn.children(".fa-angle-down").first().removeClass("fa-angle-down").addClass "fa-angle-left"
  btn.parent("li").removeClass "active"

tour = new Tour(
  debug: true
  onEnd : closeMenu
  steps: [
    orphan: true
    title: "Welcome "
    content: "loren impum"
    backdrop: true
  ,
    element: "#gruposRootMenu"
    title: "Grupos "
    reflex: true
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#grupocrecimientosMenu"
    title: "Grupo de crecimiento"
    content: "loren impum"
  ,
    element: "#regsemanalgcsMenu"
    title: "Registro Semanal"
    content: "loren impum"
    onNext: closeMenu
  ,
    element: "#membresiaRootMenu"
    title: "Membresias "
    reflex: true
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#miembrosMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#familiasMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#ministeriosMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#tarjetabienvenidasMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#eventosMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: closeMenu
  ,
    element: "#configuracionesRootMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#tablasBasicasMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#clasificacionSocialSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#estadoMembresiasSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#estadosCivilesSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: closeMenu
  ,
    element: "#datosregionalesMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#barriosSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#localidadesSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#provinciasSubMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: closeMenu
  ,
    element: "#palabraDiariaMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#iglesiasMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: closeMenu
  ,
    element: "#administracionRootMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: openMenu
  ,
    element: "#usersMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
  ,
    element: "#rolesMenu"
    title: "Membresias "
    content: "loren impum Haga click en el elemento para continuar"
    onNext: closeMenu
  ]

)
tour.init()
tour.setCurrentStep 0
tour.start true
