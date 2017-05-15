var forever = require('forever-monitor');

var child = new (forever.Monitor)('server.js', {
  max: 10,
  silent: false,
  options: []
});

child.on('exit', function () {
  console.log('server.js has exited after 10 restarts');
});

child.start();