if @urlGetUserItem is undefined
  @urlGetUserItem = '/users/getItem/id'
if @urlGetRoles is undefined
  @urlGetRoles = '/roles.json?f=id,raw_name,name'
if @urlCheckExistEmail is undefined
  @urlCheckExistEmail = '/users/existEmail/'

typingTimer = null
doneTypingInterval = 1000

$("#newEmail").keyup ->
  clearTimeout(typingTimer)
  typingTimer = setTimeout(doneTyping, doneTypingInterval)

$("#newEmail").keydown ->
  clearTimeout(typingTimer)

$("#domainEmail").on 'change', ->
  doneTyping()

doneTyping = () ->
  value = $("#newEmail").val().toLowerCase() + '@' + $("#domainEmail").val()
  emails = false
  #for e in ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'live.com']
  for e in ['gmail.com', 'yahoo.com']
    emails = value.indexOf(e) != -1
    if emails
      break
  if (value.length > 0) and emails
    meg.server.ajax @urlCheckExistEmail + value, {}, (err, res) ->
      $("#newEmail").parent().parent()
        .removeClass('has-error').removeClass('has-success')
      if not res.exist
        $('.btn-add-email').removeAttr('disabled')
        $("#newEmail").parent().parent().addClass('has-success')
        $('label#info-msg').text('Cuenta de correo disponible')
      else
        $('.btn-add-email').attr('disabled', 'disabled')
        $("#newEmail").parent().parent().addClass('has-error')
        $('label#info-msg').text('Cuenta de correo en uso en otra cuenta')

_items = []

$('form#User_form').submit (e) ->
  e.preventDefault()
  emails = JSON.stringify(_items)
  if _items.length > 0
    $('#User_account_emails').val(emails)
    @submit()
  else
    bootbox.alert('Debes indicar al menos una cuenta de correo para este usuario.')
    return false

meg.server.ajax @urlGetUserItem, {}, (err, doc_item) ->
  model_id = '#User_'
  attr = model_id + 'roles'
  url = @urlGetRoles
  def_value = ''
  if doc_item.hasOwnProperty('roles')
    def_value = doc_item.roles

  if doc_item.email
    _items.push(doc_item.email)
  opts =
    select2:false
    id: 'id'
    showname:'name'
    empty:false
  if def_value.length > 0
    opts.default = def_value
  meg.server.ajax url, {}, (err, items) ->
    # check if lodash is loaded
    if typeof(_) != 'undefined'
      items = _.sortBy(items, 'nombre')
    meg.select.load attr, items, opts, () ->

  ############
  if $('#User_account_emails').val().length > 0
    value = JSON.parse($('#User_account_emails').val())
    if value.length > 0
      _items = value
  bootbox.setDefaults({locale:'es'})

  loadTableEmails = (cb) ->
    trs = ''
    tr = '<tr>
      <td>{email}</td>
      <td><a href="#" name="{email}" class="del-user-email">Eliminar</a></td>
    </tr>'
    for email in _items
      trs += tr.replace('{email}', email)
        .replace('{email}', email)
    $('.user-emails > tbody').empty().append(trs)
    cb()

  bindDelEmail = () ->
    $('.del-user-email').on 'click', ->
      item = $(@).attr('name')
      if $('.del-user-email').length > 1
        bootbox.confirm "Confirmar eliminación...", (res) ->
          if res
            index = _items.indexOf(item)
            if index > -1
              _items.splice(index, 1)
            loadTableEmails () ->
      else
          bootbox.alert "Este correo no puede ser eliminado.\nDebes tener una cuenta de correo como mínimo."

  loadTableEmails () ->
    bindDelEmail()

  $('.btn-add-email').on 'click', ->
    value = $('#newEmail').val().toLowerCase() + '@' + $("#domainEmail").val()
    if value.length > 0
      if _items.indexOf(value) == -1
        emails = false
        #for e in ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'live.com']
        for e in ['gmail.com', 'yahoo.com']
          emails = value.indexOf(e) != -1
          if emails
            break
        if emails
          _items.push(value)
          loadTableEmails () ->
            bindDelEmail()
            $('#newEmail').val('')
            $("#newEmail").parent().parent()
              .removeClass('has-error').removeClass('has-success')
            $('label#info-msg').text('')