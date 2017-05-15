
/**
@license MEG server vs 1.5
Informatica MEG - 2014 Todos los derechos reservados
 */

(function() {
  var server;

  server = {};


  /** @expose */

  server.ajax = function(aUrl, opts, cb) {
    var defaultsOptions, errorFunction, successFunction;
    if (opts == null) {
      opts = {};
    }
    successFunction = function(data) {
      if (data) {
        if (data.code) {
          return cb(0, data.data);
        } else {
          return cb(0, data);
        }
      } else {
        console.log("NOT DATA EXIST");
        return cb(1, null);
      }
    };
    errorFunction = function() {
      return cb(1, "ERROR RETRIEVE DATA in " + aUrl);
    };
    defaultsOptions = {
      "dataType": 'json',
      "async": true,
      "success": successFunction,
      "error": errorFunction
    };
    return $.ajax(aUrl, $.extend(defaultsOptions, opts));
  };


  /** @expose */

  server.ajaxPost = function(aUrl, data, cb) {
    if (!data.hasOwnProperty('authenticity_token')) {
      data.authenticity_token = $("meta[name=csrf-token]").attr("content");
    }
    return $.ajax({
      type: "POST",
      url: aUrl,
      data: data,
      success: cb,
      error: cb,
      dataType: 'json'
    });
  };

  if (this["meg"] == null) {
    this["meg"] = {};
  }

  this["meg"]["server"] = server;

}).call(this);
