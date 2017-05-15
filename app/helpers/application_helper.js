module.exports = {
	getObjectKeys:function(e){t=["trigger","_initProperties","whatTypeName","save","isNewRecord","_adapter","toObject","toJSON","destroy","updateAttribute","updateAttributes","fromObject","propertyChanged","reload","reset","isValid","inspect"],n="[";for(s=0,o=e.length;s<o;s++){r=e[s],n+="{";for(i in r)t.indexOf(i)===-1&&i.slice(-4)!=="_was"&&(n+="'"+i+"':'"+r[i]+"',");n=n.slice(0,-1)+"},"}return (n.slice(0,-1)+"]").replace(/[\\]/g,"\\\\").replace(/[\"]/g,'\\"').replace(/[\/]/g,"\\/").replace(/[\b]/g,"\\b").replace(/[\f]/g,"\\f").replace(/[\n]/g,"\\n").replace(/[\r]/g,"\\r").replace(/[\t]/g,"\\t")}
	// getObjectKeys = (objetos) ->
	//   invalidlist = [ "trigger", "_initProperties", "whatTypeName", "save", "isNewRecord",
	//   "_adapter", "toObject", "toJSON", "destroy", "updateAttribute",
	//   "updateAttributes", "fromObject", "propertyChanged", "reload",
	//   "reset", "isValid", "inspect" ]
	//   list = "["
	//   for objeto in objetos
	//     list += "{"
	//     for property of objeto
	//       if invalidlist.indexOf(property) is -1
	//         if not(property[-4..] is "_was")
	//           #console.log objeto[property]
	//           list += "'" + property + "':'" + objeto[property] + "',"
	//     list = list[..-2] + "},"
	//   list[..-2] + "]"
	// alert getObjectKeys([{"hh_was":"llll","inspect":"opopop","ijdihsaidhihas":"saas"}])
,
	getMenuList:function(){
		return '<li><a href="/componentes">Componentes</a></li>'+
		'<li><a href="/formulas">Formulas</a></li>'+
		'<li><a href="/granels">Productos a granel</a></li>'+
		'<li><a href="/terminados">Productos terminados</a></li>'+		
		'<li><a href="/reports">Listas de precios</a></li>' +
		'<li><a href="/proveedores">Proveedores</a></li>' +
		'<li><a href="/clientes">Clientes</a></li>' +
		'<li><a href="/remitos">Remitos</a></li>'}
,
	firstLetterCapitalize:function(string) {
  		return string.charAt(0).toUpperCase() + string.slice(1);
	}
}
