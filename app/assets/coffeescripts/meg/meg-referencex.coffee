# DEPS: meg-server, meg-select, meg-gui
# VERSION 1.0.0
    
    # title : 'Nuevo XXX'
    # postUrl : '/unmodelo/create'
    # fields : [
    #   {
    #     name:'name'
    #     text:'Nombre'
    #     field : 'input'
    #     attrs : 
    #       type : 'text'
    #       required : ''
    #   }
    #   {
    #     name:'estado_civil'
    #     text:'Estado civil'
    #     field : 'select'
    #     attrs : 
    #       options : [
    #         { id: 'aaa', text:'AAA' }
    #         { id: 'bbb', text:'BBB' }
    #       ]
    #   }
    # ]

(($) ->
  
  _defaultInitOptions =
    # titulo modal
    title : 'Nuevo'
    # campos que generaran el formulario
    fields: []
    # url servidor donde se enviaran los datos
    postUrl: ''
    # selector del select donde se cargara el elemento creado
    selectRefSelector : ''
    # funcion que se ejecutara una vez creado el elemento
    selectRefFn : () ->
    # ejecutar funcion en el evento 'shown'
    execOnShown: null
      
  _utilVars = 
    modalTemplate : '
    <div id="{id}" class="modal" aria-hidden="true" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" data-dismiss="modal" aria-hidden="true" class="close">×</button>
                    <h3 class="modal-title" id="myModalLabel">{title}</h3>
                  </div>
                <div class="modal-body">                    
                    <form id="{form-id}">
                      {fields}
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" data-dismiss="modal" class="btn btn-default">Cancelar</button>
                    <button type="button" id="MEGRef-btn-{btn-save}" class="btn btn-primary btn-lg">Guardar</button>
                </div>
            </div>
        </div>
    </div>'
    formGroupTmpl : '<div class="form-group"><label for="{id}" class="control-label">{text}</label>{widget}</div>'
    inputTemplate : '<input name="{name}" id="{id}" class="form-control" type="text">'
    textareaTemplate : '<textarea name="{name}" id="{id}" class="form-control" type="text", rows="4"></textarea>'
    selectTemplate : '<select name="{name}" id="{id}" class="form-control"></select>'
  
  methods =
    init: (options) -> 
      # <img class="center-block loader" src="/images/loader.gif">
      settings = $.extend({}, _defaultInitOptions, _utilVars, options)
      settings.modalId = $(@).selector.replace('#','').replace('.','')
      settings.modalName = 'MEGRef-md-' + settings.modalId
      mdTemplate = settings.modalTemplate

      # button attrs
      $(@).on 'click', ->
        $(@).attr({
          'href':'#',
          'data-toggle':"modal",
          'data-target':"#" + settings.modalName
        })
        mdTemplate = mdTemplate
          .replace('{title}', settings.title)
          .replace('{id}', settings.modalName)
          .replace('{btn-save}',settings.modalId)
          .replace('{form-id}','MEGRef-form-' + settings.modalId)
          .replace('{fields}',_genFields(settings))
        $('form').append(mdTemplate)
        
        $('#' + settings.modalName).on 'shown.bs.modal', ->
          for f in settings.fields
            if f.field == 'select'
              selId = '#' + settings.modalName + '_' + f.name
              opts = 
                id : f.attrs.keyId
                showname: f.attrs.keyText
              meg.server.ajax f.attrs.url, {}, (err, items) ->
                # check if lodash is loaded
                if typeof(_) != 'undefined'
                  items = _.sortBy(items, opts.showname)
                meg.select.load selId, items, opts, () ->
                  if settings.execOnShown != null
                    if typeof settings.execOnShown == 'function'
                      settings.execOnShown()
        
        $('#' + settings.modalName).modal('show')

        # btn save event
        $('#MEGRef-btn-' + settings.modalId).on 'click', ->
          _validateFieldsGUI settings, (ok) ->
            if ok
              _store(settings)

      
        $('#' + settings.modalName).on 'hidden.bs.modal', ->
          $('#' + settings.modalName)
            .off('shown.bs.modal')
            .remove()

      $(@).data('settings', settings)

  _genFields = (settings) ->
    result = ''
    for field in settings.fields
      iid = settings.modalName + '_' + field.name
      row = settings.formGroupTmpl
      row = row
        .replace('{text}', field.text)        
        .replace('{id}', iid)

      types = 
        'input': settings.inputTemplate
        'select':settings.selectTemplate
        'textarea':settings.textareaTemplate
      w = types[field.field]

      if field.attrs
        w = $(w).attr(field.attrs)
        w = $(w)[0].outerHTML

      w = w.replace('{id}', iid).replace('{name}', field.name)
      row = row.replace('{widget}',$(w)[0].outerHTML)
      result += row
    result

  _store = (settings) ->
    fields = $('form#MEGRef-form-' + settings.modalId).serializeArray()
    data = {}
    for f in fields
      data[f.name] = f.value
    data.authenticity_token = $("meta[name=csrf-token]").attr("content")
    
    $.post(settings.postUrl, data)
      .done (data, textStatus, jqXHR) ->
        # console.log 'done jojojo',data, textStatus, jqXHR
        $("#" + settings.modalName).modal('hide')
        settings.selectRefFn(data['data']['id'])
      .fail (jqXHR, textStatus, errorThrown) ->
        console.log 'MEGReferencex ERROR: ', jqXHR, textStatus, errorThrown
        alert('Se produjo un error al intentar crear el elemento.')
        $("#" + settings.modalName).modal('hide')

  _validateFieldsGUI = (settings, cb) ->
    valid = true
    fields_gui = $('form#MEGRef-form-' + settings.modalId).serializeArray()
    idxFieldsGUI = {}
    for f in fields_gui
      idxFieldsGUI[f.name] = f.value
    for f in settings.fields
      if f.hasOwnProperty('attrs')
        if f.attrs.hasOwnProperty('required')
          if idxFieldsGUI[f.name].length == 0
            $('#' + settings.modalName + '_' + f.name).parent().addClass('has-error')
            valid = false
    cb(valid)

  $.fn.MEGReferencex = (methodOrOptions) ->
    if methods[methodOrOptions]
      methods[methodOrOptions].apply this, Array::slice.call(arguments, 1)
    else if typeof methodOrOptions is "object" or not methodOrOptions
      methods.init.apply this, arguments
    else
      $.error "Method " + methodOrOptions + " does not exist"

) jQuery