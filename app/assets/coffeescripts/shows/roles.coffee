module_main = '<div class="panel box box-success">
  <div class="box-header">
    <h4 class="box-title">
      <a id="box_{ctrlName2}" data-toggle="collapse" data-parent="#box-perms" href="{ctrlName1}" class="collapsed">
      <i class="{icon}"></i>  {ctrlText}
      </a>
    </h4>
  </div>
  <div id="{ctrlName2}" class="panel-collapse in">
    <div class="box-body">
      {submodules}
    </div>
  </div>
</div>'
tb_main = '<table class="table table-condensed">
  <thead>
    <tr>
      <th>Acción</th>
      <th>Permiso</th>
    </tr>
  </thead>
  <tbody>{trs}</tbody>
</table>'

renderTable = (item) ->
  perms = ''
  if item.description.length > 0
    $('.role-details')
      .append($('<p>').text(item.description))
      .removeClass('hide')

  if item.hasOwnProperty('permissions')
    perms = item.permissions
  if perms.length > 0
    perms = JSON.parse(perms)
    if typeof perms == 'string'
      perms = JSON.parse(perms)

    meg.server.ajax '/roles/id/actions', {}, (err, ctrls) ->
      # parse actions
      for ctrl, ctrldata of ctrls
        for act in ctrldata.actions
          can = false
          if perms.hasOwnProperty(ctrldata.rawName)
            if perms[ctrldata.rawName].indexOf(act.action) != -1
              can = true
          act.can = can
      # generate table
      st_modules = ''
      for position in values.positions
        raw_m = position.m.toLowerCase().replace(' ','_')
        st_submodules = ''
        for ctrl_rawname in position.ctrls
          ctrl = ctrl_rawname
          data = ctrls[ctrl_rawname]

          row_ctrl = '<tr><td><b>' + data.showName + '</b></td><td></td></tr>'
          for act in data.actions
            _row = '<tr><td>{name}</td><td>{can}</td></tr>'
            if act.can
              icon = '<span class="badge bg-green">SI</span>'
            else
              icon = '<span class="badge bg-red">NO</span>'
            _row = _row.replace('{can}', icon)
            _row = _row.replace('{name}', act.showName)
            row_ctrl += _row
          st_submodules += row_ctrl

        _module = module_main
        _module = _module.replace('{submodules}', tb_main.replace('{trs}',st_submodules))
        _module = _module.replace('{ctrlName1}', '#' + raw_m)
        _module = _module.replace('{ctrlName2}', raw_m)
        _module = _module.replace('{ctrlName2}', raw_m)
        _module = _module.replace('{ctrlText}', position.m)
        _module = _module.replace('{icon}', position.i)
        st_modules += _module
      $('#perms-list').append(st_modules)

meg.server.ajax '/roles/getItem/id', {}, (err, role) ->
  renderTable(role)
  _item = role
  $('#md-set-role').on 'show.bs.modal', ->
    meg.server.ajax '/users.json', {}, (err, items) ->
      availables = []
      for item in items
        if item.roles.indexOf(role.raw_name) == -1
          availables.push(item)
      formated = _.map availables, (item) ->
        if typeof item isnt 'undefined'
          row = {}
          row.id = item.id
          row.nombre = item.displayName
          if typeof item.email isnt 'undefined' and item.email isnt null
            if item.email.length > 0
              email = item.email
            else
              email = JSON.parse(item.account_emails)[0]
            row.nombre += ' (' + email + ')'
          row
      formated = _.sortBy(formated, 'nombre')
      meg.select.load '#cb-users', formated, {empty:false}, () ->

  $('#btn-set-role').on 'click', ->
    user = $('#cb-users').val()
    if user.length > 0
      data =
        role : _item.raw_name
        user : user
      meg.server.ajaxPost '/roles/setRole', data, () ->
        $('#md-set-role').modal('hide')
        window.location.reload()