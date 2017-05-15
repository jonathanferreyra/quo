module.exports = (compound, Timestamp) ->

  # Update timestamp from indicated model
  # @param {String} model - model name
  # @param {String} value - value of timestamp
  # @param {Function} cb - Callback
  Timestamp.updateTS = (model, value, cb) ->
    if typeof value == 'number'
      value = JSON.stringify(value)
    else if value is null
      value = JSON.stringify(new Date().valueOf())
    toSave =
      id: model + "Timestamp"
      v: value
    Timestamp.find toSave.id, (err, myTimestamp) =>
      if err
        compound.models.Timestamp.create toSave, (err, doc) =>
      else
        myTimestamp.updateAttributes toSave, (err) =>
      cb()

  # Refreshes the cache without reloading the entire model after create
  # @param {String} ctrl - controller name
  # @param {String} model - model name
  # @param {Object} doc - document
  # @param {Function} cb - Callback
  # Use:
  #  doc = {'id':'123', 'name':'Peter', model:'Person'}
  #  Timestamp.refreshCacheAfterCreate('persons', 'Person', doc, cb)
  Timestamp.refreshCacheAfterCreate = (ctrl, model, doc, cb=null) ->
    newTS = new Date().valueOf()
    # append the doc
    doc = JSON.parse(JSON.stringify(doc))
    doc['model'] = model
    compound.utils.cache.dataset.insert([doc])
    # update the ts in cache
    compound.utils.cache.setTimeStamp(model, newTS)
    # update the ts in bd
    compound.models.Timestamp.updateTS ctrl, newTS, () ->
      cb() if cb

  # @param {String} ctrl - controller name
  # @param {String} model - model name
  # @param {Object} doc - document
  # @param {Function} cb - Callback
  Timestamp.refreshCacheAfterUpdate = (ctrl, model, doc, cb=null) ->
    newTS = new Date().valueOf()
    # update the doc
    doc = JSON.parse(JSON.stringify(doc))
    doc['model'] = model
    compound.utils.cache.dataset({ id:doc.id }).update(doc)
    # update the ts in cache
    compound.utils.cache.setTimeStamp(model, newTS)
    # update the ts in bd
    compound.models.Timestamp.updateTS ctrl, newTS, () ->
      cb() if cb

  # @param {String} ctrl - controller name
  # @param {String} model - model name
  # @param {Object} doc - document
  # @param {Function} cb - Callback
  Timestamp.refreshCacheAfterDestroy = (ctrl, model, doc, cb=null) ->
    newTS = new Date().valueOf()
    # remove the doc
    compound.utils.cache.dataset().filter({ id:doc.id }).remove()
    # update the ts in cache
    compound.utils.cache.setTimeStamp(model, newTS)
    # update the ts in bd
    compound.models.Timestamp.updateTS ctrl, newTS, () ->
      cb() if cb