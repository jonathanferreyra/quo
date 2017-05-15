# VERSION 1.5.0
(($) ->
  _base_operators =
    es:
      igual: [
        {op:'=', text:'igual'}
        {op:'!', text:'no igual'}
      ]
      entre : [
        {op:'=', text:'igual'}
        {op:'>=', text:'mayor o igual'}
        {op:'<=', text:'menor o igual'}
      ]
    en:
      igual: [
        {op:'=', text:'equal'}
        {op:'!', text:'not equal'}
      ]
      entre : [
        {op:'=', text:'equal'}
        {op:'>=', text:'major or equal'}
        {op:'<=', text:'minor or equal'}
      ]

  _defaultInitOptions =
    # Array of fields/filters.
    fields: []
    # lang es | en
    lang : 'es'
    filter_caption :
      es : 'Añadir filtro'
      en : 'Add filter'
    operators :
      es :
        ajax : _base_operators['es']['igual']
        opts : _base_operators['es']['igual']
        bool : _base_operators['es']['igual']
        number : _base_operators['es']['entre']
        date : _base_operators['es']['entre']
        time : _base_operators['es']['entre']
      en :
        ajax : _base_operators['en']['igual']
        opts : _base_operators['en']['igual']
        bool : _base_operators['en']['igual']
        number : _base_operators['en']['entre']
        date : _base_operators['en']['entre']
        time : _base_operators['en']['entre']

  _utilVars =
    main_template : '
      <div class="row">
        <div class="col-md-12">
          <div class="col-md-8 list-filters"></div>
          <div class="col-md-4 add-filter">
            <form class="form-inline">
              <label for="add_filter_select">{filter_caption}</label>
              <select id="add_filter_select" class="form-control">
                <option></option>
                {filters}
              </select>
            </form>
          </div>
        </div>
      </div>'
    sample_filter : '<div id="{filter_id}" class="row filter">
      <div class="col-md-4 field">
        <div class="checkbox">
          <label for="{filter_id}">
            <input id="{filter_id}" name="{filter_id}" type="checkbox" checked="checked">{filter_name}
          </label>
        </div>
      </div>
      <div class="col-md-4 operator">
        {operator}
      </div>
      <div class="col-md-4 values">
        {values}
      </div>
    </div>'
    select_operator : '<select id="op_{filter_id}" class="form-control">{opts}</select>'
    select_values : '<select id="val_{filter_id}" class="form-control">{opts}</select>'
    input_values : '<input id="val_{filter_id}" class="form-control" type="{type}">'

  methods =
    init: (options) ->
      settings = $.extend({}, _defaultInitOptions, _utilVars, options)

      settings.fieldsByName = {}
      for f in settings.fields
        settings.fieldsByName[f.name] = f

      target = @
      if target.length > 0
        tbWhole = target[0]

        # Save options
        $(tbWhole).data('settings', settings)

        template = settings.main_template

        $('.filter-loader').addClass('hide')
        filters = _genFilterOptions(tbWhole)
        template = template.replace('{filter_caption}', settings.filter_caption[settings.lang])
        template = template.replace('{filters}', filters)
        # Remove existing content and append new thead and tbody
        $(tbWhole).empty().append(template)

        $('#add_filter_select').on 'click', ->
          field = $(@).val()
          if field.length > 0
            $('#add_filter_select option:selected').attr('disabled', true)
            $(@).val('')
            _genRowfilter tbWhole, field, (html) ->
              $('.list-filters').append(html)

              $('.checkbox').on 'change', ->
                _element = $(@).find('input')
                _name = _element.attr('name')
                if _element.is(':checked')
                  $('#op_' + _name + ', #val_' + _name).show()
                else
                  $('#op_' + _name + ', #val_' + _name).hide()

    getFilters: () ->
      return _getFilters()

    getValue: (key) ->
      settings = $(@).data('settings')
      return if settings[key] then settings[key] else null

    filterData: (rows) ->
      if typeof(TAFFY) == 'undefined'
        throw new Error('taffy not found')
      else
        settings = $(@).data('settings')
        fields = _.indexBy(settings.fields, 'name')
        filters = _getFilters()
        results = rows
        taffyQuery = {}
        for _f in filters
          if not fields[_f.field].hasOwnProperty('json')
            if fields[_f.field].type == 'bool'
              _true = [1, true, 'true', '1']
              _false = [0, false, 'false', '0']
              values = if _f.value == '1' then _true else _false
              operator = if _f.operator == '=' then 'is' else '!is'
              condition = {}
              condition[operator] = values
              taffyQuery[_f.field] = condition
            else
              if _f.operator == '='
                taffyQuery[_f.field] = {'is':_f.value}
              else if _f.operator == '!'
                taffyQuery[_f.field] = {'!is':_f.value}
          else
            operator = if _f.operator == '=' then 'like' else '!like'
            condition = {}
            condition[operator] = _f.value
            taffyQuery[_f.field] = condition

        results = TAFFY(rows)().filter(taffyQuery).get()

  _getFilters = () ->
    settings = $(@).data('settings')
    dom = $('.list-filters .filter')
    filters = []
    if $(dom).length > 0
      for f in dom
        checked = $(f).find('.field .checkbox input').is(':checked')
        if checked
          row = {}
          row.field = $(f).attr('id')
          row.operator = $(f).find('.operator select').val()
          value = $(f).find('.values select').val()
          if value is undefined
            value = $(f).find('.values input').val()
          row.value = value
          filters.push row
    filters

  _genFilterOptions = (tbWhole) ->
    settings = $(tbWhole).data('settings')
    fields = settings.fields
    result = ''
    for f in fields
      result += '<option value="' + f.name + '">' + f.text + '</option>'
    result

  _genRowfilter = (tbWhole, field, cb) ->
    settings = $(tbWhole).data('settings')
    filter = settings.fieldsByName[field]

    # generate row
    html = settings.sample_filter
    while html.indexOf('{filter_id}') != -1
      html = html.replace('{filter_id}', filter.name)
    html = html.replace('{filter_name}', filter.text)

    # generate operators
    html_op = settings.select_operator
    html_op = html_op.replace('{filter_id}', filter.name)
    options = _genOptions(_getOperators(tbWhole, filter.type))
    html_op = html_op.replace('{opts}', options)
    html = html.replace('{operator}', html_op)

    _genOptValues tbWhole, filter, (values) ->
      if filter.empty
        values += '<option value="">[Sin especificar]</option>'
      if filter.type in ['ajax','opts','bool']
        html_values = settings.select_values
        html_values = html_values.replace('{opts}', values)
      else if filter.type in ['number', 'date', 'time']
        html_values = settings.input_values
        html_values = html_values.replace('{type}', filter.type)
      html_values = html_values.replace('{filter_id}', filter.name)
      html = html.replace('{values}', html_values)
      cb(html)

  _getOperators = (tbWhole, type) ->
    settings = $(tbWhole).data('settings')
    settings.operators[settings.lang][type]

  _genOptions = (options, keyId='op', keyText='text', sort=true) ->
    result = ''
    if sort
      if typeof(_) != 'undefined' # check if lodash is loaded
        options = _.sortBy(options, keyText)
    for opt in options
      result += '<option value="' + opt[keyId] + '">' + opt[keyText] + '</option>'
    result

  _genOptValues = (tbWhole, filter, cb) ->
    settings = $(tbWhole).data('settings')
    if filter.type == 'opts'
      sortItems = if filter.hasOwnProperty('sort') then filter.sort else true
      cb(_genOptions(filter.options, 'id', 'text', sortItems))
    else if filter.type == 'ajax'
      defOpts =
        dataType : 'json'
        async : true
      $.ajax($.extend(defOpts, filter.ajaxSettings))
        .done (res) ->
          if filter.ajaxSettings.doneFn
            filter.ajaxSettings.doneFn res, (_res) ->
              cb(_genOptions(_res, filter.keyId, filter.keyText))
          else
            cb(_genOptions(res, filter.keyId, filter.keyText))
    else if filter.type in ['number', 'date', 'time']
      cb(null)
    if filter.type == 'bool'
      opts = [{op:1, text:'SI'}, {op:0, text:'NO'}]
      cb(_genOptions(opts, 'op', 'text', false))

  $.fn.MEGFilter = (methodOrOptions) ->
    if methods[methodOrOptions]
      methods[methodOrOptions].apply this, Array::slice.call(arguments, 1)
    else if typeof methodOrOptions is "object" or not methodOrOptions
      methods.init.apply this, arguments
    else
      $.error "Method " + methodOrOptions + " does not exist"
) jQuery
