(function() {
  var doneTyping, doneTypingInterval, typingTimer, _items;

  if (this.urlGetUserItem === void 0) {
    this.urlGetUserItem = '/users/getItem/id';
  }

  if (this.urlGetRoles === void 0) {
    this.urlGetRoles = '/roles.json?f=id,raw_name,name';
  }

  if (this.urlCheckExistEmail === void 0) {
    this.urlCheckExistEmail = '/users/existEmail/';
  }

  typingTimer = null;

  doneTypingInterval = 1000;

  $("#newEmail").keyup(function() {
    clearTimeout(typingTimer);
    return typingTimer = setTimeout(doneTyping, doneTypingInterval);
  });

  $("#newEmail").keydown(function() {
    return clearTimeout(typingTimer);
  });

  $("#domainEmail").on('change', function() {
    return doneTyping();
  });

  doneTyping = function() {
    var e, emails, value, _i, _len, _ref;
    value = $("#newEmail").val().toLowerCase() + '@' + $("#domainEmail").val();
    emails = false;
    _ref = ['gmail.com', 'yahoo.com'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      emails = value.indexOf(e) !== -1;
      if (emails) {
        break;
      }
    }
    if ((value.length > 0) && emails) {
      return meg.server.ajax(this.urlCheckExistEmail + value, {}, function(err, res) {
        $("#newEmail").parent().parent().removeClass('has-error').removeClass('has-success');
        if (!res.exist) {
          $('.btn-add-email').removeAttr('disabled');
          $("#newEmail").parent().parent().addClass('has-success');
          return $('label#info-msg').text('Cuenta de correo disponible');
        } else {
          $('.btn-add-email').attr('disabled', 'disabled');
          $("#newEmail").parent().parent().addClass('has-error');
          return $('label#info-msg').text('Cuenta de correo en uso en otra cuenta');
        }
      });
    }
  };

  _items = [];

  $('form#User_form').submit(function(e) {
    var emails;
    e.preventDefault();
    emails = JSON.stringify(_items);
    if (_items.length > 0) {
      $('#User_account_emails').val(emails);
      return this.submit();
    } else {
      bootbox.alert('Debes indicar al menos una cuenta de correo para este usuario.');
      return false;
    }
  });

  meg.server.ajax(this.urlGetUserItem, {}, function(err, doc_item) {
    var attr, bindDelEmail, def_value, loadTableEmails, model_id, opts, url, value;
    model_id = '#User_';
    attr = model_id + 'roles';
    url = this.urlGetRoles;
    def_value = '';
    if (doc_item.hasOwnProperty('roles')) {
      def_value = doc_item.roles;
    }
    if (doc_item.email) {
      _items.push(doc_item.email);
    }
    opts = {
      select2: false,
      id: 'id',
      showname: 'name',
      empty: false
    };
    if (def_value.length > 0) {
      opts["default"] = def_value;
    }
    meg.server.ajax(url, {}, function(err, items) {
      if (typeof _ !== 'undefined') {
        items = _.sortBy(items, 'nombre');
      }
      return meg.select.load(attr, items, opts, function() {});
    });
    if ($('#User_account_emails').val().length > 0) {
      value = JSON.parse($('#User_account_emails').val());
      if (value.length > 0) {
        _items = value;
      }
    }
    bootbox.setDefaults({
      locale: 'es'
    });
    loadTableEmails = function(cb) {
      var email, tr, trs, _i, _len;
      trs = '';
      tr = '<tr> <td>{email}</td> <td><a href="#" name="{email}" class="del-user-email">Eliminar</a></td> </tr>';
      for (_i = 0, _len = _items.length; _i < _len; _i++) {
        email = _items[_i];
        trs += tr.replace('{email}', email).replace('{email}', email);
      }
      $('.user-emails > tbody').empty().append(trs);
      return cb();
    };
    bindDelEmail = function() {
      return $('.del-user-email').on('click', function() {
        var item;
        item = $(this).attr('name');
        if ($('.del-user-email').length > 1) {
          return bootbox.confirm("Confirmar eliminación...", function(res) {
            var index;
            if (res) {
              index = _items.indexOf(item);
              if (index > -1) {
                _items.splice(index, 1);
              }
              return loadTableEmails(function() {});
            }
          });
        } else {
          return bootbox.alert("Este correo no puede ser eliminado.\nDebes tener una cuenta de correo como mínimo.");
        }
      });
    };
    loadTableEmails(function() {
      return bindDelEmail();
    });
    return $('.btn-add-email').on('click', function() {
      var e, emails, _i, _len, _ref;
      value = $('#newEmail').val().toLowerCase() + '@' + $("#domainEmail").val();
      if (value.length > 0) {
        if (_items.indexOf(value) === -1) {
          emails = false;
          _ref = ['gmail.com', 'yahoo.com'];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            e = _ref[_i];
            emails = value.indexOf(e) !== -1;
            if (emails) {
              break;
            }
          }
          if (emails) {
            _items.push(value);
            return loadTableEmails(function() {
              bindDelEmail();
              $('#newEmail').val('');
              $("#newEmail").parent().parent().removeClass('has-error').removeClass('has-success');
              return $('label#info-msg').text('');
            });
          }
        }
      }
    });
  });

}).call(this);
