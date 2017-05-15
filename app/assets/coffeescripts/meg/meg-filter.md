MEG Filter
=========

Utilidad para generar criterios de búsqueda.

Version
----

0.2.0

Dependencias
-----------

* [jQuery]

Tipos soportados
--------------
- Ajax | ajax
- Default | number, date, time
- Personalizado | opts

Idiomas soportados
--------------
- Ingles (en)
- Español (es)

```sh
$('#un_div').MEGFilter({lang : 'en'})

```

Uso
--------------

### > Ajax

empty = 
  true: (default) agrega el elemento [Sin especificar] al combo permitiendo filtrar aquellos elementos donde el atributo buscado es blanco|vacio
  false: no agrega el elemento [Sin especificar]

```sh
$('#un_div').MEGFilter(
      fields : [
        {
          name : 'filter1'
          text : 'Filtro 1'
          type : 'ajax'
          empty: false
          ajaxSettings:
            url  : '/somedata'
            doneFn : function(res, cb){
                cb(res.data);
            },
          keyId : 'id',
          keyText : 'some_attr',
        }
      ]
    )

```

### > Default
```sh
$('#un_div').MEGFilter(
      fields : [
        {
          name : 'filter1'
          text : 'Filtro 1'
          type : 'number'
        }
      ]
    )

```
### > Personalizado

```sh
$('#un_div').MEGFilter(
      fields : [
        {
          name : 'filter1'
          text : 'Filtro 1'
          type : 'opts'
          options : [
            {id:'aaa',text:'AAA'}, 
            {id:'bbb',text:'BBB'}
          ]
        }
      ]
    )

```

Metodos
--------------
```sh
# obtener los filtros seleccionados
$('#un_div').MEGFilter('getFilters')
```