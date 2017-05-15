# recargar modelo en cache
$('#mdRefreshCache').on 'show.bs.modal', ->
    meg.server.ajax '/roles/id/actions', {}, (err, res) ->
      rows = []
      for k, v of res
        rows.push({id:k, nombre:k})
      meg.select.load '#md-rc-cb-models', rows, {}, () ->

$('#btn-refresh-cache-model').on 'click', ->
  if $('#md-rc-cb-models').val().length > 0
    $('#md-rc-loader').removeClass('hide')
    meg.server.ajaxPost '/clients/refreshModelInCache', {'ctrl':$('#md-rc-cb-models').val()}, (err, res) ->
      $('#md-rc-loader').addClass('hide')
      $('#mdRefreshCache').modal('hide')