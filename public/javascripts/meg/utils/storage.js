(function() {
  var storage;

  if (this.meg == null) {
    this.meg = {};
  }

  this.meg.storage = {};

  storage = this.meg.storage;

  storage.checkDependencies = function(model, cb) {
    if (Modernizr.localstorage) {
      if (typeof Lawnchair !== "undefined" && Lawnchair !== null) {
        if (typeof jx !== "undefined" && jx !== null) {
          if (CryptoJS.AES != null) {
            if (typeof jsonMask !== "undefined" && jsonMask !== null) {
              return true;
            }
          }
        }
      }
    }
    return false;
  };

  storage.load = function(model, opts, cb) {
    if (!(opts.fields != null)) {
      opts.fields = null;
    }
    if (!(opts.remoteOnly != null)) {
      opts.remoteOnly = false;
    }
    if (!(opts.localOnly != null)) {
      opts.localOnly = false;
    }
    if (!(opts.reset != null)) {
      opts.reset = false;
    }
    return storage.getTimeSpan(model, function(err, timespanlocal) {
      return storage.getRemoteTimeSpan(model, function(err, timespanremote) {
        if (((timespanlocal === timespanremote) && !opts.reset && !opts.remoteOnly) || opts.localOnly) {
          return storage.getAllWithFilter(model, opts.fields, cb);
        } else {
          return storage.getRemoteAll(model, function(err, allData) {
            storage.filterByKeys(allData, opts.fields, cb);
            if (!opts.remoteOnly) {
              storage.saveAll(model, allData);
              storage.saveIndex(model, allData, "id");
              storage.saveTimeSpan(model, timespanremote);
              return console.info("Sincronizando Datos");
            }
          });
        }
      });
    });
  };

  storage.getTimeSpan = function(model, cb) {
    return storage.getByKey(model, 'TimeSpan', function(err, timespan) {
      if (err) {
        console.log("timespan local of " + model + " failed or not used, skipping...");
      }
      return cb(err, timespan);
    });
  };

  storage.getAll = function(model, cb) {
    console.log("Cargando datos locales.");
    return storage.getByKey(model, 'all', function(err, allData) {
      return cb(err, allData);
    });
  };

  storage.getAllWithFilter = function(model, query, cb) {
    return storage.getAll(model, function(err, allData) {
      if (err) {
        return console.log("err getAllWithFilter", err, allData);
      } else {
        return storage.filterByKeys(allData, query, cb);
      }
    });
  };

  storage.clear = function(model, cb) {};

  storage.clearAll = function(model, cb) {};

  storage.getRemoteTimeSpan = function(model, cb) {
    return storage.getRemoteData('/timespans/get/' + model + 'TimeSpan', function(timespan) {
      return cb(null, timespan);
    });
  };

  storage.getRemoteAll = function(model, cb) {
    return storage.getRemoteData('/' + model + '.json', function(allData) {
      var _data;
      _data = allData.hasOwnProperty('data') ? allData.data : allData;
      return cb(null, _data);
    });
  };

  storage.getRemoteData = function(route, cb) {
    return jx.load(route, cb, "json");
  };

  storage.saveByKey = function(model, key, data, cb) {
    var obj, store;
    if (cb == null) {
      cb = function() {};
    }
    obj = {
      key: key,
      data: data
    };
    return store = new Lawnchair({
      adapter: "dom",
      name: model
    }, function(store) {
      obj.data = storage.encrypt(obj.data);
      return store.save(obj, function(returnobj) {
        if (!(returnobj != null)) {
          return cb(1, "no se pudo guardar");
        }
        return cb(null, returnobj);
      });
    });
  };

  storage.getByKey = function(model, key, cb) {
    var store;
    return store = new Lawnchair({
      adapter: "dom",
      name: model
    }, function(store) {
      return store.get(key, function(value) {
        var data;
        if (!(value != null)) {
          return cb(1, "cannot read " + model + ", " + key);
        }
        data = storage.decrypt(value.data);
        return cb(null, data);
      });
    });
  };

  storage.saveTimeSpan = function(model, timespan) {
    return storage.saveByKey(model, 'TimeSpan', timespan);
  };

  storage.saveAll = function(model, alldata) {
    return storage.saveByKey(model, 'all', alldata);
  };

  storage.saveIndex = function(model, allData, key) {
    var index;
    index = allData.map(function(aKey) {
      return aKey[key];
    });
    return storage.saveByKey(model, 'index_' + key, index);
  };

  storage.getPositionToIndex = function(model, id, cb) {
    return storage.getByKey(model, 'index_id', function(err, index) {
      return cb(err, index.indexOf(id));
    });
  };

  storage.saveToShow = function(model, key, cb) {
    if (cb == null) {
      cb = function() {};
    }
    return storage.getPositionToIndex(model, key, function(err, indexposition) {
      return storage.saveByKey(model, '_toShow', indexposition, function(err, obj) {
        return cb(err);
      });
    });
  };

  storage.getToShow = function(model, cb) {
    return storage.load(model, {}, function() {
      return storage.getByKey(model, '_toShow', function(err, i) {
        if (err) {
          return cb(err, "error en getToShow");
        }
        return storage.getAll(model, function(err, allData) {
          return cb(err, allData[i]);
        });
      });
    });
  };

  storage.getItem = function(model, id, cb) {
    return storage.getPositionToIndex(model, id, function(err, indexposition) {
      return storage.getAll(model, function(err, allitems) {
        return cb(err, allitems[indexposition]);
      });
    });
  };

  storage.bindEventShow = function(selector, model) {
    return $(document).on("click", selector, function(e) {
      e.preventDefault();
      return meg.storage.saveToShow(model, $(e.currentTarget).attr('item'), function(err) {
        return document.location = "/" + model + "/show/";
      });
    });
  };

  storage.encrypt = function(data, secret) {
    if (secret == null) {
      secret = 'A secret';
    }
    return CryptoJS.AES.encrypt(JSON.stringify(data), secret).toString();
  };

  storage.decrypt = function(data, secret) {
    if (secret == null) {
      secret = 'A secret';
    }
    return JSON.parse(CryptoJS.AES.decrypt(data, secret).toString(CryptoJS.enc.Utf8));
  };

  storage.filterByKeys = function(rows, query, cb) {
    var results, row, _i, _len;
    if (query != null) {
      console.log("query", query);
      results = [];
      for (_i = 0, _len = rows.length; _i < _len; _i++) {
        row = rows[_i];
        results.push(jsonMask(row, query));
      }
      console.log(results);
      return cb(false, results);
    } else {
      return cb(false, rows);
    }
  };

  if (!storage.checkDependencies()) {
    alert("Dependencias no satisfechas para storage");
  }

}).call(this);
