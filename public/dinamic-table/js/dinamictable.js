/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
	"sWrapper": "dataTables_wrapper form-inline"
} );

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
	return {
		"iStart":         oSettings._iDisplayStart,
		"iEnd":           oSettings.fnDisplayEnd(),
		"iLength":        oSettings._iDisplayLength,
		"iTotal":         oSettings.fnRecordsTotal(),
		"iFilteredTotal": oSettings.fnRecordsDisplay(),
		"iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
		"iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
	};
}

/* Bootstrap style pagination control */
$.extend( $.fn.dataTableExt.oPagination, {
	"bootstrap": {
		"fnInit": function( oSettings, nPaging, fnDraw ) {
			var oLang = oSettings.oLanguage.oPaginate;
			var fnClickHandler = function ( e ) {
				e.preventDefault();
				if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
					fnDraw( oSettings );
				}
			};

			$(nPaging).addClass('pagination').append(
				'<ul>'+
					'<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
					'<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
				'</ul>'
			);
			var els = $('a', nPaging);
			$(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
			$(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
		},

		"fnUpdate": function ( oSettings, fnDraw ) {
			var iListLength = 5;
			var oPaging = oSettings.oInstance.fnPagingInfo();
			var an = oSettings.aanFeatures.p;
			var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

			if ( oPaging.iTotalPages < iListLength) {
				iStart = 1;
				iEnd = oPaging.iTotalPages;
			}
			else if ( oPaging.iPage <= iHalf ) {
				iStart = 1;
				iEnd = iListLength;
			} else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
				iStart = oPaging.iTotalPages - iListLength + 1;
				iEnd = oPaging.iTotalPages;
			} else {
				iStart = oPaging.iPage - iHalf + 1;
				iEnd = iStart + iListLength - 1;
			}

			for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
				// Remove the middle elements
				$('li:gt(0)', an[i]).filter(':not(:last)').remove();

				// Add the new list items and their event handlers
				for ( j=iStart ; j<=iEnd ; j++ ) {
					sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
					$('<li '+sClass+'><a href="#">'+j+'</a></li>')
						.insertBefore( $('li:last', an[i])[0] )
						.bind('click', function (e) {
							e.preventDefault();
							oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
							fnDraw( oSettings );
						} );
				}

				// Add / remove disabled classes from the static elements
				if ( oPaging.iPage === 0 ) {
					$('li:first', an[i]).addClass('disabled');
				} else {
					$('li:first', an[i]).removeClass('disabled');
				}

				if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
					$('li:last', an[i]).addClass('disabled');
				} else {
					$('li:last', an[i]).removeClass('disabled');
				}
			}
		}
	}
} );

/*Convertion functions */
var convertToLink = function(dataArray,numCol){
	for (row in dataArray){
		dataArray[row][numCol] = "<a href='" + dataArray[row][numCol] + "' target='_blank'>" + dataArray[row][numCol] + "</a>"
	};
	return dataArray;
}

var convertToBold = function(dataArray,numCol){
	for (row in dataArray){
		dataArray[row][numCol] = "<b>" + dataArray[row][numCol] + "</b>"
	};
	return dataArray;
}

var convertToSomeTag = function(dataArray,numCol,tag){
	for (row in dataArray){
		dataArray[row][numCol] = tag[0] + dataArray[row][numCol] + tag[1]
	};
	return dataArray;
}

var createTableFromArraysArray = function (arraysArray){
	var firstRow = arraysArray[0];
	var aoColumns = [];
	for (i in firstRow) {
		aoColumns.push({"sTitle": firstRow[i]});
	};
	arraysArray.splice(0,1);
	return data = [arraysArray, aoColumns]
};

var createTableFromJSON = function(objectsArray){
	var keys = Object.keys(objectsArray[0]);
    var aoColumns = [];
    for (i=0;i<keys.length;i++){
		aoColumns.push({ "sTitle": keys[i]});
    }
	var dataArray = $.map(objectsArray, function (obj) {return [$.map(obj, function (value, key) {return value})]});
	return data = [dataArray, aoColumns]
};

var showTableDinamic = function(data){
	dataArray = data[0];
	aoColumns = data[1]

	var selector = arguments[1] ? arguments[1] : "#example";

	$(selector).dataTable( {
		"aaData":dataArray,
		"aoColumns":aoColumns,
		"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
		"sPaginationType": "bootstrap",
		"bDestroy": true,
		"oLanguage": {
			"sLengthMenu": "_MENU_ entradas por página",
			"sInfo": "Mostrando _START_ a _END_ de _TOTAL_ entradas",
			"oPaginate": {
				"sNext": "Próximos",
				"sPrevious": "Anterior"
			},
			"sZeroRecords": "No se han encontrado resultados"
		}
	} );
	$('tr:first').addClass("titles");
	$('input').attr("placeholder","Buscar...")
	$('[rel="tooltip"],[data-rel="tooltip"]').tooltip()
};

var showTableStatic = function(){
	$('#example').dataTable( {
		"sPaginationType": "bootstrap",
		"oLanguage": {
			"sLengthMenu": "_MENU_ entradas por página",
			"sInfo": "Mostrando _START_ a _END_ de _TOTAL_ entradas",
			"oPaginate": {
				"sNext": "Siguiente",
				"sPrevious": "Anterior"
			},
			"sZeroRecords": "No se han encontrado resultados"
		}
	} );
	$('tr:first').addClass("titles");
	$('input').attr("placeholder","Buscar...")
};
