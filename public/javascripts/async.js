(function(){function s(b){for(var d=Object.keys(b),a=-1,c=d.length,e=Array(c);++a<c;)e[a]=b[d[a]];return e}function G(b){for(var d=-1,a=b.length,c=Array(a);++d<a;)c[d]=b[d];return c}function u(b,d){var a=-1,c=b.length-d;if(0>=c)return[];for(var e=Array(c);++a<c;)e[a]=b[a+d];return e}function la(b){for(var d=-1,a=b.length,c=Array(a);++d<a;)c[a-d-1]=b[d];return c}function r(b,d){for(var a=-1,c=b.length;++a<c;)d(b[a],a);return b}function v(b,d,a){a=a||Object.keys(b);for(var c=-1,e=a.length;++c<e;){var g=
a[c];d(b[g],g)}return b}function w(b,d){for(var a=-1;++a<b;)d(a)}function ma(b,d){for(var a=b.length,c=-1;++c<a;)if(!d(b[c]))return!1;return!0}function y(b){for(var d=b.length,a=-1,c=Array(d);++a<d;)c[a]=b[a];return c}function z(b){for(var d=Object.keys(b),a=d.length,c=-1,e={};++c<a;){var g=d[c];e[g]=b[g]}return e}function T(b,d){for(var a=-1,c=b.length,e=Array(c);++a<c;)e[a]=(b[a]||{})[d];return e}function U(b,d){for(var a=-1,c=b.length;++a<c;)if(b[a]===d)return a}function t(b){var d=!1;return function(a,
c){if(d){if(a)return b(a,c);throw Error("Callback was already called.");}d=!0;b(a,c)}}function I(b,d,a,c){function e(b){k(b,t(g))}function g(b,c){b?(a(b),a=l):!1===c?(a(),a=l):++h===f&&(a(),a=l)}a=a||l;var f,h=0,k=c?d.bind(c):d;if(Array.isArray(b)){f=b.length;if(!f)return a();r(b,e)}else if(b&&"object"===typeof b){d=Object.keys(b);f=d.length;if(!f)return a();v(b,e,d)}else a()}function J(b,d,a,c){function e(b,c){if(h)throw Error("Callback was already called.");h=!0;if(b)return a(b);if(++k===g||!1===
c)return a();f()}a=a||l;var g,f,h,k=0,m=c?d.bind(c):d;if(Array.isArray(b)){g=b.length;if(!g)return a();f=function(){h=!1;m(b[k],e)}}else if(b&&"object"===typeof b){var n=Object.keys(b);g=n.length;if(!g)return a();f=function(){h=!1;m(b[n[k]],e)}}else return a();f()}function V(b,d,a,c,e){function g(b,a){b?(c(b),c=l):++m===f?(c(),c=l):!1===a?(c(),c=l):h()}c=c||l;if(isNaN(d)||1>d)return c();var f,h,k=0,m=0,n=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c();h=function(){var a=k++;a>=f||n(b[a],
t(g))}}else if(b&&"object"===typeof b){var p=Object.keys(b);f=p.length;if(!f)return c();h=function(){var a=k++;a>=f||n(b[p[a]],t(g))}}else return c();w(d>f?f:d,h)}function W(b,d,a,c){function e(b){n(b,g(k++))}function g(b){var c=!1;return function(d,e){if(c)throw Error("Callback was already called.");c=!0;h[b]=e;d?(a(d,y(h)),a=l):++m===f&&(a(void 0,h),a=l)}}a=a||l;var f,h,k=0,m=0,n=c?d.bind(c):d;if(Array.isArray(b)){f=b.length;if(!f)return a(void 0,[]);h=Array(f);r(b,e)}else if(b&&"object"===typeof b){d=
Object.keys(b);f=d.length;if(!f)return a(void 0,[]);h=Array(f);v(b,e,d)}else a(void 0,[])}function Y(b,d,a,c){function e(b){var c=!1;return function(d,e){if(c)throw Error("Callback was already called.");c=!0;f[b]=e;d?(a(d,y(f)),a=l):++k===g?(a(void 0,f),a=l):h()}}a=a||l;var g,f,h,k=0,m=c?d.bind(c):d;if(Array.isArray(b)){g=b.length;if(!g)return a(void 0,[]);h=function(){m(b[k],e(k))}}else if(b&&"object"===typeof b){var n=Object.keys(b);g=n.length;if(!g)return a(void 0,[]);h=function(){m(b[n[k]],e(k))}}else return a(void 0,
[]);f=Array(g);h()}function Z(b,d,a,c,e){function g(b){var a=!1;return function(d,e){if(a)throw Error("Callback was already called.");a=!0;h[b]=e;d?(c(d,y(h)),c=l):++n===f?(c(void 0,h),c=l):k()}}c=c||l;if(isNaN(d)||1>d)return c(void 0,[]);var f,h,k,m=0,n=0,p=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c(void 0,[]);k=function(){var a=m++;a>=f||p(b[a],g(a))}}else if(b&&"object"===typeof b){var q=Object.keys(b);f=q.length;if(!f)return c(void 0,[]);k=function(){var a=m++;a>=f||p(b[q[a]],
g(a))}}else return c(void 0,[]);h=Array(f);w(d>f?f:d,k)}function $(b,d,a,c){b&&"object"===typeof b&&(b=s(b));K(b,d,a,c)}function aa(b,d,a,c){b&&"object"===typeof b&&(b=s(b));L(b,d,a,c)}function ba(b,d,a,c,e){b&&"object"===typeof b&&(b=s(b));M(b,d,a,c,e)}function N(b,d,a,c,e){function g(b){m(b,k(b))}a=a||l;var f,h=0,k=function(){function b(c){return function(b){b?++h===f&&(a(),a=l):(a(c),a=l)}}function c(b){return function(c){c?(a(b),a=l):++h===f&&(a(),a=l)}}return e?b:c}(),m=c?d.bind(c):d;if(Array.isArray(b)){f=
b.length;if(!f)return a();r(b,g)}else if(b&&"object"===typeof b){d=Object.keys(b);f=d.length;if(!f)return a();v(b,g,d)}else a()}function O(b,d,a,c,e){a=a||l;var g,f,h,k=0,m=function(){function b(c){return function(b){if(h)throw Error("Callback was already called.");h=!0;if(!b)return a(c);if(++k===g)return a();f()}}function c(b){return function(c){if(h)throw Error("Callback was already called.");h=!0;if(c)return a(b);if(++k===g)return a();f()}}return e?b:c}(),n=c?d.bind(c):d;if(Array.isArray(b)){g=
b.length;if(!g)return a();f=function(){h=!1;var a=b[k];n(a,m(a))}}else if(b&&"object"===typeof b){var p=Object.keys(b);g=p.length;if(!g)return a();f=function(){h=!1;var a=b[p[k]];n(a,m(a))}}else return a();f()}function P(b,d,a,c,e,g){c=c||l;if(isNaN(d)||1>d)return c();var f,h,k=0,m=0,n=function(){function b(a){return function(b){b?++m===f?(c(),c=l):h():(c(a),c=l)}}function a(b){return function(a){a?(c(b),c=l):++m===f?(c(),c=l):h()}}return g?b:a}(),p=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c();
h=function(){var a=k++;a>=f||(a=b[a],p(a,t(n(a))))}}else if(b&&"object"===typeof b){var q=Object.keys(b);f=q.length;if(!f)return c();h=function(){var a=k++;a>=f||(a=b[q[a]],p(a,t(n(a))))}}else return c();w(d>f?f:d,h)}function K(b,d,a,c,e){function g(b,a){p(b,n(a,b))}a=a||l;var f,h=Array.isArray(b),k={},m=0,n=function(){function b(c,d){var e=!1;return function(b){if(e)throw Error("Callback was already called.");e=!0;b||(k[c+""]=d);++m===f&&a(h?s(k):k)}}function c(b,d){var e=!1;return function(c){if(e)throw Error("Callback was already called.");
e=!0;c&&(k[b+""]=d);++m===f&&a(h?s(k):k)}}return e?b:c}(),p=c?d.bind(c):d;if(h){f=b.length;if(!f)return a([]);r(b,g)}else if(b&&"object"===typeof b){d=Object.keys(b);f=d.length;if(!f)return a({});v(b,g,d)}else a([])}function L(b,d,a,c,e){a=a||l;var g,f,h=Array.isArray(b),k={},m=0,n=function(){function b(c,d){var e=!1;return function(b){if(e)throw Error("Callback was already called.");e=!0;b||(k[c+""]=d);if(++m===g)return a(h?s(k):k);f()}}function c(b,d){var e=!1;return function(c){if(e)throw Error("Callback was already called.");
e=!0;c&&(k[b+""]=d);if(++m===g)return a(h?s(k):k);f()}}return e?b:c}(),p=c?d.bind(c):d;if(h){g=b.length;if(!g)return a([]);f=function(){var a=b[m];p(a,n(m,a))}}else if(b&&"object"===typeof b){var q=Object.keys(b);g=q.length;if(!g)return a({});f=function(){var a=q[m],c=b[a];p(c,n(a,c))}}else return a([]);f()}function M(b,d,a,c,e,g){c=c||l;if(isNaN(d)||1>d)return c([]);var f,h,k=Array.isArray(b),m={},n=0,p=0,q=function(){function b(a,d){var e=!1;return function(b){if(e)throw Error("Callback was already called.");
e=!0;b||(m[a+""]=d);if(++p===f)return c(k?s(m):m);h()}}function a(b,d){var e=!1;return function(a){if(e)throw Error("Callback was already called.");e=!0;a&&(m[b+""]=d);if(++p===f)return c(k?s(m):m);h()}}return g?b:a}(),A=e?a.bind(e):a;if(k){f=b.length;if(!f)return c([]);h=function(){var a=n++;if(!(a>=f)){var c=b[a];A(c,q(a,c))}}}else if(b&&"object"===typeof b){var X=Object.keys(b);f=X.length;if(!f)return c({});h=function(){var a=n++;if(!(a>=f)){var a=X[a],c=b[a];A(c,q(a,c))}}}else return c([]);w(d>
f?f:d,h)}function H(b,d,a,c,e){function g(b,a){if(k)throw Error("Callback was already called.");k=!0;if(b)return c(b);if(++m===f)return c(void 0,a);h(a)}c=c||l;var f,h,k,m=0,n=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c(void 0,d);h=function(a){k=!1;n(a,b[m],g)}}else if(b&&"object"===typeof b){var p=Object.keys(b);f=p.length;if(!f)return c(void 0,d);h=function(a){k=!1;n(a,b[p[m]],g)}}else return c(void 0,d);h(d)}function ca(b,d,a,c,e){function g(b,a){if(k)throw Error("Callback was already called.");
k=!0;if(b)return c(b);if(++m===f)return c(void 0,a);h(a)}c=c||l;var f,h,k,m=0,n=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c(void 0,d);h=function(a){k=!1;n(a,b[f-m-1],g)}}else if(b&&"object"===typeof b){var p=Object.keys(b);f=p.length;if(!f)return c(void 0,d);h=function(a){k=!1;n(a,b[p[f-m-1]],g)}}else return c(void 0,d);h(d)}function Q(b){function d(a,b,d,k){b=c(b,k);Y(a,b,e(d))}function a(b,a,d,k,m){d=c(d,m);Z(b,a,d,e(k))}function c(b,a){var c=a?b.bind(a):b;return function(b,a){c(b,
function(c,d){c?(a(c),a=l):a(void 0,{item:b,criteria:d})})}}function e(b){return function(a,c){if(a)b(a),b=l;else{var d=c.sort(function(b,a){return a.criteria<b.criteria});b(void 0,T(d,"item"))}}}switch(b){case "series":return d;case "limit":return a;default:return function(b,a,d,k){a=c(a,k);W(b,a,e(d))}}}function da(b,d,a,c){N(b,d,function(b){a=a||l;a(!!b)},c)}function ea(b,d,a,c){N(b,d,function(b){a=a||l;a(!b)},c,!0)}function fa(b,d,a){function c(b){var a=!1;return function(c,h){if(a)throw Error("Callback was already called.");
a=!0;if(c)d(c,g),d=l;else{var q=u(arguments,1);g[b]=1>=q.length?h:q;++f===e&&(d(void 0,g),d=l)}}}d=d||l;var e,g,f=0;if(Array.isArray(b)){e=b.length;if(!e)return d(void 0,[]);g=Array(e);a?r(b,function(b,d){b.call(a,c(d))}):r(b,function(b,a){b(c(a))})}else if(b&&"object"===typeof b){var h=Object.keys(b);e=h.length;if(!e)return d(void 0,{});g={};a?v(b,function(b,d){b.call(a,c(d))},h):v(b,function(b,a){b(c(a))},h)}else d()}function ga(b,d,a){function c(b){var a=!1;return function(c,k){if(a)throw Error("Callback was already called.");
a=!0;if(c)return d(c,g);var l=u(arguments,1);g[b]=1>=l.length?k:l;if(++h===e)return d(void 0,g);f()}}d=d||l;var e,g,f,h=0;if(Array.isArray(b)){e=b.length;if(!e)return d(void 0,[]);g=Array(e);f=a?function(){b[h].call(a,c(h))}:function(){b[h](c(h))}}else if(b&&"object"===typeof b){var k=Object.keys(b);e=k.length;if(!e)return d(void 0,{});g={};f=a?function(){var d=k[h];b[d].call(a,c(d))}:function(){var a=k[h];b[a](c(a))}}else return d();f()}function R(b,d,a,c){function e(b){var c=!1;return function(d,
e){if(c)throw Error("Callback was already called.");c=!0;if(d)a(d,f),a=l;else{var k=u(arguments,1);f[b]=1>=k.length?e:k;if(++m===g)return a(void 0,f);h()}}}a=a||l;var g,f,h,k=0,m=0;if(Array.isArray(b)){g=b.length;if(!g)return a(void 0,[]);f=Array(g);h=c?function(){var a=k++;a>=g||b[a].call(c,e(a))}:function(){var a=k++;if(!(a>=g))b[a](e(a))}}else if(b&&"object"===typeof b){var n=Object.keys(b);g=n.length;if(!g)return a(void 0,{});f={};h=c?function(){var a=k++;a>=g||(a=n[a],b[a].call(c,e(a)))}:function(){var a=
k++;a>=g||(a=n[a],b[a](e(a)))}}else return a();w(d>g?g:d,h)}function ha(){var b=arguments;return function(){var d=this,a=G(arguments),c=a.pop();H(b,a,function(a,b,c){a.push(function(a){var b=u(arguments,1);c(a,b)});b.apply(d,a)},function(a,b){b=Array.isArray(b)?b:[b];b.unshift(a);c.apply(d,b)})}}function ia(b){var d="series"===b?J:I;return function(a){var b=function(){var b=this,c=G(arguments),e=c.pop()||l;return d(a,function(a,d){a.apply(b,c.concat(d))},e)};if(1<arguments.length){var e=u(arguments,
1);return b.apply(this,e)}return b}}function ja(b,d,a){function c(a,b,c){e.started=!0;var d=Array.isArray(a)?a:[a];a&&d.length?(c="function"===typeof c?c:l,r(d,function(a){e.tasks.push({task:a,priority:b,callback:c});e.tasks=e.tasks.sort(function(a,b){return b.priority<a.priority});"function"===typeof e.saturated&&e.length()===e.concurrency&&e.saturated();x(e.process)})):e.idle()&&x(function(){"function"===typeof e.drain&&e.drain()})}var e={tasks:[],concurrency:d||1,saturated:l,empty:l,drain:l,started:!1,
paused:!1,push:function(a,b,d){c(a,b,d)},kill:function(){e.drain=l;e.tasks=[]},process:function(){function a(){g--;b.callback&&b.callback.apply(b,arguments);"function"===typeof e.drain&&e.idle()&&e.drain();e.process()}if(!(e.paused||g>=e.concurrency)&&e.length()){var b=e.tasks.shift();"function"!==typeof e.empty||e.length()||e.empty();g++;(e._thisArg?e._worker.bind(e._thisArg):e._worker)(b.task,t(a))}},length:function(){return e.tasks.length},running:function(){return g},idle:function(){return 0===
e.length()+g},pause:function(){e.paused=!0},resume:function(){!1!==e.paused&&(e.paused=!1,w(e.concurrency,function(){E.setImmediate(e.process)}))},_worker:b,_thisArg:a},g=0;return e}function ka(b,d,a,c){function e(c){var d=!1;return function(l,p){if(d)throw Error("Callback was already called.");d=!0;g[c]=p;if(l)return a(l);if(++f===b)return a(void 0,g);h(f,e(f))}}a=a||l;if(!Number.isFinite(b)||1>b)return a(void 0,[]);var g=Array(b),f=0,h=c?d.bind(c):d;h(f,e(f))}function S(b){function d(a){if(B[typeof console])if(a)console.error&&
console.error(a);else if(console[b]){var c=u(arguments,1);r(c,function(a){console[b](a)})}}return function(a){var b=u(arguments,1);b.push(d);a.apply(null,b)}}function C(b,d){this._emitter=b||ga;this._limit=d||4;this._events={};this._once=[]}var D=this,na=D&&D.async,l=function(){},B={"function":!0,object:!0},F,x;(function(){B[typeof process]&&process.nextTick?(F=process.nextTick,x=B[typeof setImmediate]?function(b){setImmediate(b)}:F):x=F=B[typeof setImmediate]?function(b){setImmediate(b)}:function(b){setTimeout(b,
0)}})();var E={VERSION:"0.6.2",each:I,eachSeries:J,eachLimit:V,forEach:I,forEachSeries:J,forEachLimit:V,map:W,mapSeries:Y,mapLimit:Z,mapValues:function(b,d,a,c){function e(b){var c=!1;return function(d,e){if(c)throw Error("Callback was already called.");c=!0;f[b]=e;d?(a(d,z(f)),a=l):++k===g&&(a(void 0,f),a=l)}}a=a||l;var g,f={},h=0,k=0,m=c?d.bind(c):d;if(Array.isArray(b)){g=b.length;if(!g)return a(void 0,f);d=function(a){m(a,e(h++))};r(b,d)}else if(b&&"object"===typeof b){var n=Object.keys(b);g=n.length;
if(!g)return a(void 0,f);d=function(a){m(a,e(n[h++]))};v(b,d,n)}else a(void 0,f)},mapValuesSeries:function(b,d,a,c){function e(b){var c=!1;return function(d,e){if(c)throw Error("Callback was already called.");c=!0;h[b]=e;d?(a(d,z(h)),a=l):++k===g?(a(void 0,h),a=l):f()}}a=a||l;var g,f,h={},k=0,m=c?d.bind(c):d;if(Array.isArray(b)){g=b.length;if(!g)return a(void 0,{});f=function(){m(b[k],e(k))}}else if(b&&"object"===typeof b){var n=Object.keys(b);g=n.length;if(!g)return a(void 0,{});f=function(){var a=
n[k];m(b[a],e(a))}}else return a(void 0,{});f()},mapValuesLimit:function(b,d,a,c,e){function g(a){var b=!1;return function(d,e){if(b)throw Error("Callback was already called.");b=!0;k[a]=e;d?(c(d,z(k)),c=l):++n===f?(c(void 0,k),c=l):h()}}c=c||l;if(isNaN(d)||1>d)return c(void 0,[]);var f,h,k={},m=0,n=0,p=e?a.bind(e):a;if(Array.isArray(b)){f=b.length;if(!f)return c(void 0,k);h=function(){var a=m++;a>=f||p(b[a],g(a))}}else if(b&&"object"===typeof b){var q=Object.keys(b);f=q.length;if(!f)return c(void 0,
k);h=function(){var a=m++;a>=f||(a=q[a],p(b[a],g(a)))}}else return c(void 0,k);w(d>f?f:d,h)},filter:$,filterSeries:aa,filterLimit:ba,select:$,selectSeries:aa,selectLimit:ba,reject:function(b,d,a,c){b&&"object"===typeof b&&(b=s(b));K(b,d,a,c,!0)},rejectSeries:function(b,d,a,c){b&&"object"===typeof b&&(b=s(b));L(b,d,a,c,!0)},rejectLimit:function(b,d,a,c,e){b&&"object"===typeof b&&(b=s(b));M(b,d,a,c,e,!0)},detect:N,detectSeries:O,detectLimit:P,pick:K,pickSeries:L,pickLimit:M,reduce:H,inject:H,foldl:H,
reduceRight:ca,foldr:ca,transform:function(b,d,a,c,e){function g(a,b){p(m,a,b,t(f))}function f(b,c){b?(a(b,k?y(m):z(m)),a=l):!1===c?(a(void 0,k?y(m):z(m)),a=l):++n===h&&(a(void 0,m),a=l)}a=a||l;var h,k=Array.isArray(b),m=void 0!==c?c:k?[]:{},n=0,p=e?d.bind(e):d;if(k){h=b.length;if(!h)return a(void 0,m);r(b,g)}else if(b&&"object"===typeof b){d=Object.keys(b);h=d.length;if(!h)return a(void 0,m);v(b,g,d)}else a(void 0,m)},transformSeries:function(b,d,a,c,e){function g(b,c){if(k)throw Error("Callback was already called.");
k=!0;if(b)return a(b,n);if(!1===c||++p===f)return a(void 0,n);h()}a=a||l;var f,h,k,m=Array.isArray(b),n=void 0!==c?c:m?[]:{},p=0,q=e?d.bind(e):d;if(m){f=b.length;if(!f)return a(void 0,n);h=function(){k=!1;q(n,b[p],p,g)}}else if(b&&"object"===typeof b){var A=Object.keys(b);f=A.length;if(!f)return a(void 0,n);h=function(){k=!1;var a=A[p];q(n,b[a],a,g)}}else return a(void 0,n);h()},transformLimit:function(b,d,a,c,e,g){function f(a,b){a?(c(a,h?y(k):z(k)),c=l):!1===b?(c(void 0,h?y(k):z(k)),c=l):++q===
m?(c(void 0,k),c=l):n()}c=c||l;var h=Array.isArray(b),k=void 0!==e?e:h?[]:{};if(isNaN(d)||1>d)return c(void 0,k);var m,n,p=0,q=0,A=g?a.bind(g):a;if(h){m=b.length;if(!m)return c(void 0,k);n=function(){var a=p++;a>=m||A(k,b[a],a,t(f))}}else if(b&&"object"===typeof b){var r=Object.keys(b);m=r.length;if(!m)return c(void 0,k);n=function(){var a=p++;a>=m||(a=r[a],A(k,b[a],a,t(f)))}}else return c(void 0,k);w(d>m?m:d,n)},sortBy:Q(),sortBySeries:Q("series"),sortByLimit:Q("limit"),some:da,someSeries:function(b,
d,a,c){O(b,d,function(b){a=a||l;a(!!b)},c)},someLimit:function(b,d,a,c,e){P(b,d,a,function(a){c=c||l;c(!!a)},e)},any:da,every:ea,all:ea,everySeries:function(b,d,a,c){O(b,d,function(b){a=a||l;a(!b)},c,!0)},everyLimit:function(b,d,a,c,e){P(b,d,a,function(a){c=c||l;c(!a)},e,!0)},concat:function(b,d,a,c){function e(a){m(a,t(g))}function g(b,c){c&&Array.prototype.push.apply(h,Array.isArray(c)?c:[c]);b?(a(b,y(h)),a=l):++k===f&&(a(void 0,h),a=l)}a=a||l;var f,h=[],k=0,m=c?d.bind(c):d;if(Array.isArray(b)){f=
b.length;if(!f)return a(void 0,h);r(b,e)}else if(b&&"object"===typeof b){d=Object.keys(b);f=d.length;if(!f)return a(void 0,h);v(b,e,d)}else a(void 0,h)},concatSeries:function(b,d,a,c){function e(b,c){if(h)throw Error("Callback was already called.");h=!0;c&&Array.prototype.push.apply(k,Array.isArray(c)?c:[c]);if(b)return a(b,k);if(++m===g)return a(void 0,k);f()}a=a||l;var g,f,h,k=[],m=0,n=c?d.bind(c):d;if(Array.isArray(b)){g=b.length;if(!g)return a(void 0,k);f=function(){h=!1;n(b[m],e)}}else if(b&&
"object"===typeof b){var p=Object.keys(b);g=p.length;if(!g)return a(void 0,k);f=function(){h=!1;n(b[p[m]],e)}}else return a(void 0,k);f()},concatLimit:function(b,d,a,c,e){function g(a,b){b&&Array.prototype.push.apply(f,Array.isArray(b)?b:[b]);a?(c(a,f),c=l):++n===h?(c(void 0,f),c=l):k()}c=c||l;var f=[];if(isNaN(d)||1>d)return c(void 0,f);var h,k,m=0,n=0,p=e?a.bind(e):a;if(Array.isArray(b)){h=b.length;if(!h)return c(void 0,f);k=function(){var a=m++;a>=h||p(b[a],t(g))}}else if(b&&"object"===typeof b){var q=
Object.keys(b);h=q.length;if(!h)return c(void 0,f);k=function(){var a=m++;a>=h||p(b[q[a]],t(g))}}else return c(void 0,f);w(d>h?h:d,k)},parallel:fa,series:ga,parallelLimit:R,waterfall:function(b,d){function a(e,g){function f(b){if(b)return d(b);var f=u(arguments,1);if(e===c)return f.unshift(void 0),d.apply(null,f);F(function(){a(e,f)})}var h=b[e++];switch(g.length){case 0:return h(f);case 1:return h(g[0],f);case 2:return h(g[0],g[1],f);case 3:return h(g[0],g[1],g[2],f);case 4:return h(g[0],g[1],g[2],
g[3],f);case 5:return h(g[0],g[1],g[2],g[3],g[4],f);default:return g.push(f),h.apply(null,g)}}d=d||l;if(!Array.isArray(b))return d(Error("First argument to waterfall must be an array of functions"));var c=b.length;if(!c)return d();a(0,[])},whilst:function(b,d,a,c){function e(){b()?g(function(b){if(b)return a(b);e()}):a()}a=a||l;var g=c?d.bind(c):d;e()},doWhilst:function(b,d,a,c){function e(){g(function(b){if(b)return a(b);var g=u(arguments,1);d.apply(c,g)?e():a()})}a=a||l;var g=c?b.bind(c):b;e()},
until:function(b,d,a,c){function e(){b()?a():g(function(b){if(b)return a(b);e()})}a=a||l;var g=c?d.bind(c):d;e()},doUntil:function(b,d,a,c){function e(){g(function(b){if(b)return a(b);var g=u(arguments,1);d.apply(c,g)?a():e()})}a=a||l;var g=c?b.bind(c):b;e()},forever:function(b,d,a){function c(){e(function(a){if(a)return d(a);c()})}d=d||l;var e=a?b.bind(a):b;c()},compose:function(){return ha.apply(null,la(arguments))},seq:ha,applyEach:ia(),applyEachSeries:ia("series"),queue:function(b,d,a){function c(a,
b,c){e.started=!0;var d=Array.isArray(a)?a:[a];a&&d.length?(b="function"===typeof b?b:null,r(d,function(a){a={task:a,callback:b};c?e.tasks.unshift(a):e.tasks.push(a);"function"===typeof e.saturated&&e.length()===e.concurrency&&e.saturated();x(e.process)})):e.idle()&&x(function(){"function"===typeof e.drain&&e.drain()})}var e=ja(b,d,a);e.unshift=function(a,b){c(a,b,!0)};e.push=function(a,b){c(a,b)};return e},priorityQueue:ja,cargo:function(b,d){var a={tasks:[],payload:d,saturated:l,empty:l,drain:l,
drained:!0,push:function(b,c){b=Array.isArray(b)?b:[b];c="function"===typeof c?c:l;r(b,function(b){a.tasks.push({data:b,callback:c});a.drained=!1;"function"===typeof a.saturated&&a.length()===a.payload&&a.saturated()});x(a.process)},process:function(){if(!c)if(a.length()){var e="number"===typeof a.payload?a.tasks.splice(0,d):a.tasks,g=T(e,"data");a.length()||"function"!==typeof a.empty||a.empty();c=!0;b(g,function(){c=!1;var b=arguments;r(e,function(a){a.callback&&a.callback.apply(null,b)});a.process()})}else"function"!==
typeof a.drain||a.drained||a.drain(),a.drained=!0},length:function(){return a.tasks.length},running:function(){return c}},c=!1;return a},auto:function(b,d){function a(a){f.unshift(a)}function c(){g--;r(f.slice(0),function(a){a()})}d=d?t(d):l;var e=Object.keys(b),g=e.length;if(!g)return d();var f=[],h={};a(function(){g||d(void 0,h)});v(b,function(b,e){function g(a){var b=u(arguments,1);1>=b.length&&(b=b[0]);if(a){var f=z(h);f[e]=b;d(a,f);d=l}else h[e]=b,x(c)}function p(){return!h.hasOwnProperty(e)&&
ma(t,function(a){return h.hasOwnProperty(a)})}function q(){if(p()){var a=U(f,q);0<=a&&f.splice(a,1);s(g,h)}}b=Array.isArray(b)?b:[b];var r=b.length,t=b.slice(0,r-1),s=b[r-1];if(p())return s(g,h);a(q)},e)},retry:function(b,d,a){function c(c,g){a=c||a||l;var f,h;ka(b,function(a,c){d(function(d,e){f=d;h=e;if(!d)return c(!0);c(d&&a===b-1)},g)},function(){a(f,h)})}"function"===typeof b&&(a=d,d=b,b=5);b=parseInt(b,10)||5;return"function"===typeof a?c():c},iterator:function(b){function d(e){var g=function(){a&&
b[c[e]||e].apply(null,arguments);return g.next()};g.next=function(){return e<a-1?d(e+1):null};return g}var a=0,c=[];Array.isArray(b)?a=b.length:(c=Object.keys(b),a=c.length);return d(0)},apply:function(b){var d=u(arguments,1);return function(){return b.apply(this,Array.prototype.concat.apply(d,G(arguments)))}},nextTick:F,setImmediate:x,times:function(b,d,a,c){function e(c){var d=!1;return function(e,h){if(d)throw Error("Callback was already called.");d=!0;g[c]=h;e?(a(e),a=l):++f===b&&(a(void 0,g),
a=l)}}a=a||l;if(!Number.isFinite(b)||1>b)return a(void 0,[]);var g=Array(b),f=0,h=c?d.bind(c):d;w(b,function(a){h(a,e(a))})},timesSeries:ka,timesLimit:function(b,d,a,c,e){function g(a){var e=!1;return function(g,m){if(e)throw Error("Callback was already called.");e=!0;f[a]=m;g?(c(g),c=l):++h===b?(c(void 0,f),c=l):h>=k+d&&(k=h,n())}}c=c||l;if(!Number.isFinite(b)||1>b)return c(void 0,[]);var f=Array(b),h=0,k=0,m=e?a.bind(e):a;d=d>b?b:d;var n=function(){w(d,function(a){a=k+a;a>=b||m(a,g(a))})};n()},
memoize:function(b,d,a){d=d||function(a){return a};var c={},e={},g=function(){function f(){var b=G(arguments);c[l]=b;var d=e[l];delete e[l];for(var f=-1,g=d.length;++f<g;)d[f].apply(a,b)}var g=G(arguments),k=g.pop(),l=d.apply(null,g);if(c.hasOwnProperty(l))F(function(){k.apply(a,c[l])});else{if(e.hasOwnProperty(l))return e[l].push(k);e[l]=[k];g.push(f);b.apply(a,g)}};g.memo=c;g.unmemoized=b;return g},unmemoize:function(b){return function(){return(b.unmemoized||b).apply(null,arguments)}},log:S("log"),
dir:S("dir"),createLogger:S,noConflict:function(){D.async=na;return E},eventEmitter:function(b){b=b||{};var d=b.limit;return b.parallel&&!d?new C(fa):b.parallel||b.parallelLimit?new C(R,d):new C(b.emitter)},EventEmitter:C};B[typeof define]&&define&&define.amd?define([],function(){return E}):B[typeof module]&&module&&module.exports?module.exports=E:D&&B[typeof D.async]?D.neo_async=E:D.async=E;C.prototype.on=function d(a,c){var e=this;"object"===typeof a?v(a,function(a,c){d.call(e,c,a)}):(e._events[a]=
e._events[a]||[],Array.isArray(c)?Array.prototype.push.apply(e._events[a],c):e._events[a].push(c));return e};C.prototype.once=function a(c,e){var g=this;"object"===typeof c?v(c,function(c,e){a.call(g,e,c)}):(Array.isArray(e)?Array.prototype.push.apply(g._once,e):g._once.push(e),g.on(c,e));return g};C.prototype.emit=function(a,c,e){function g(a,e){r(f._once,function(a){a=U(h,a);0<=a&&h.splice(a,1)});f._once=[];c(a,e)}c=c||l;var f=this,h=f._events[a]||[];if(!h.length)return c();a=f._emitter;a=e?a.bind(e):
a;a===R?a(h,f._limit,g):a(h,g);return f}}).call(this);
