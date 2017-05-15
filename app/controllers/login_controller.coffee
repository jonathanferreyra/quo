@enviroment = app.get 'env' 

before 'load variables', =>
  @user = if req.user != undefined then req.user else {}
  next()
  
action 'index', () -> 
  render
    title: "Ingresar"

action 'logout', ->
  req.logOut()
  session.user = false
  # flash('info', 'You are now logged out.')
  redirect path_to.root()

action 'email_not_valid', ->
  @title = 'Email no valido'
  render()