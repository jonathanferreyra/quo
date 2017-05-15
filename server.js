var app, host, port, server;

app = module.exports = function(params) {
  params = params || {};
  params.root = params.root || __dirname;
  return require('compound').createServer(params);
};

if (!module.parent) {
  port = process.env.PORT || 3000;
  host = process.env.HOST || "0.0.0.0";
  server = app();
  server.listen(port, host, function() {
    return console.log("Compound server listening on %s:%d within %s environment", host, port, server.set('env'));
  });
}
