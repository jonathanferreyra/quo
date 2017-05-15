(function() {
  $('#mdRefreshCache').on('show.bs.modal', function() {
    return meg.server.ajax('/roles/id/actions', {}, function(err, res) {
      var k, rows, v;
      rows = [];
      for (k in res) {
        v = res[k];
        rows.push({
          id: k,
          nombre: k
        });
      }
      return meg.select.load('#md-rc-cb-models', rows, {}, function() {});
    });
  });

  $('#btn-refresh-cache-model').on('click', function() {
    if ($('#md-rc-cb-models').val().length > 0) {
      $('#md-rc-loader').removeClass('hide');
      return meg.server.ajaxPost('/clients/refreshModelInCache', {
        'ctrl': $('#md-rc-cb-models').val()
      }, function(err, res) {
        $('#md-rc-loader').addClass('hide');
        return $('#mdRefreshCache').modal('hide');
      });
    }
  });

}).call(this);
