# Require `authorization` controller
load('authorization')

before 'protect from forgery', ->
  protectFromForgery 'c21c9cf299083a3d3596bc09b45db4e81f04a3dc'

# before 'set locale', ->
#   #locale = (if req.user then req.user.locale else "en")
#   keys = Object.keys(compound)
#   keys.sort()
#   console.log keys, compound.locales
#   #setLocale('en')
#   next()

before 'User access', (_req) ->
  ## USER ACCESS LOG
  if session.user and app.settings.saveUserAccess
    new_access =
      'i': session.user.i
      user : session.passport.user
      action : _req.actionName
      controller : _req.controllerName
      method: _req.context.req.method
      datetime : new Date().toISOString()
      docId: if req.params.hasOwnProperty('id') then req.params.id else ''

    to_ignore = compound.acomplish.permissions.to_ignore
    if to_ignore.hasOwnProperty(new_access.controller)
      if to_ignore[new_access.controller].indexOf(new_access.action) != -1
        return next()

    # check if is an ajax action
    if app.settings.saveAjaxAccess
      if compound.acomplish.permissions.ajax.hasOwnProperty(_req.controllerName)
        if compound.acomplish.permissions.ajax[_req.controllerName].indexOf(_req.actionName) != -1
          compound.models.Useraccess.createCustom new_access, req.useragent, (err, item) ->
    else
      format = 'html'
      if req.params.hasOwnProperty('format')
        _format = req.params.format
        if !_format?
          format = 'html'
        else
          format = _format
      if format is 'html'
        compound.models.Useraccess.createCustom new_access, req.useragent, (err, item) ->
  next()

before(use('loadUserPassport'))
# before(use('loadRoles'))
# before(use('loadAbilities'))