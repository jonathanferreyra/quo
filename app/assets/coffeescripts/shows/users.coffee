$('.item-del').on 'click', ->
  item = $(@)
  item_id = $(@).attr('item')
  msg = '<legend><i class="fa fa-ban text-danger"></i>  Se procede a deshabilitar este usuario</legend>
  <br>
  <p><b>Esto implica:</b></p>
  <ul>
    <li>El usuario ya no podrá ingresar al sistema desde ninguna de sus cuentas de correo.</li>
    <li>No se podrán crear nuevos usuarios asociados a las actuales cuentas de correo del usuario.</li>
  </ul>
  <div class="alert alert-info">
    <p>Se podrá volver a habilitar al usuario cuando se desee.</p>
  </div>'
  bootbox.confirm msg, (result) =>
    if result
      $('<a>').attr({
        'href':"/users/" + item_id
        'data-remote':"true"
        'data-method':"delete"
        'data-jsonp':"(function (u) {location.href = u;})"
      }).appendTo('body').click()

meg.server.ajax '/users/getItem/id', {}, (err, doc_item) ->
  _items = null
  _item = doc_item
  bootbox.setDefaults({locale:'es'})

  if typeof doc_item['deleted'] isnt 'undefined' and doc_item['deleted'] isnt null
    if doc_item['deleted']
      dd = new Date(doc_item['disabled_date']).toString('dddd, dd-MM-yyyy hh:mm')
      $('#disabled-date').text(' ' + dd)
      $('#disabled-user').show()

  loadTableEmails = (cb) ->
    meg.server.ajax '/users/get_user_account_emails/' + doc_item.id, {}, (err, res) ->
      _items = res
      trs = ''
      tr = '<tr><td><a href="mailto:{email}">{email}</a></td></tr>'
      for email in res
        trs += tr.replace(/{email}/g, email)
      $('.user-emails > tbody').empty().append(trs)
      cb()

  loadTableEmails () ->

  $('#enable-user').on 'click', ->
    msg = '<h4>Se procede a habilitar este usuario</h4>'
    bootbox.confirm msg, (response) ->
      opts =
        method: 'POST'
        url:'/users/setEnabled'
        data:
          id: _item.id
          authenticity_token: $("meta[name=csrf-token]").attr("content")
      meg.server.ajax '', opts, (err, res) ->
        window.location.reload()
