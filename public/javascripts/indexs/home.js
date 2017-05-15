(function() {
  var cookie_date, current_date, d, data, getDayPart, getNewFromServer, loadInBoxPalabraDiaria, palabra;

  getDayPart = function() {
    var day_part, hour;
    day_part = '';
    hour = new Date().getHours();
    if (hour >= 0 && hour <= 5) {
      day_part = 'Buenas noches';
    }
    if (hour >= 6 && hour <= 12) {
      day_part = 'Buenos días';
    }
    if (hour >= 13 && hour <= 19) {
      day_part = 'Buenas tardes';
    }
    if (hour >= 20 && hour <= 23) {
      day_part = 'Buenas noches';
    }
    return day_part;
  };

  loadInBoxPalabraDiaria = function(data) {
    var title;
    if (data.hasOwnProperty('mensaje')) {
      $('#mensaje').text(data.mensaje);
      $('#autor').text(data.autor);
      title = ' ' + getDayPart() + ', tu palabra del día es:';
      $('#title').text(title);
      return $('.palabra_diaria').fadeIn();
    }
  };

  getNewFromServer = function() {
    return meg.server.ajax('/palabradiaria_get_random', {}, function(err, res) {
      var current_date, d, title, to_save;
      if (!err) {
        if (Object.keys(res).length > 0) {
          d = new Date();
          current_date = d.getDate() + '-' + (d.getMonth() + 1);
          to_save = {
            date: current_date,
            mensaje: res.mensaje,
            autor: res.autor
          };
          $.cookie('palabra_diaria', JSON.stringify(to_save));
          return loadInBoxPalabraDiaria(res);
        } else {
          $('.palabra_diaria > .box-body > blockquote').hide();
          title = ' ' + getDayPart();
          $('#title').text(title);
          $('.empty-info').removeClass('hide');
          return $('.palabra_diaria').fadeIn();
        }
      }
    });
  };

  d = new Date();

  current_date = d.getDate() + '-' + (d.getMonth() + 1);

  palabra = $.cookie('palabra_diaria');

  if (palabra !== null) {
    data = JSON.parse(palabra);
    cookie_date = data.date;
    if (cookie_date === current_date) {
      loadInBoxPalabraDiaria(data);
    } else {
      getNewFromServer();
    }
  } else {
    getNewFromServer();
  }

}).call(this);
