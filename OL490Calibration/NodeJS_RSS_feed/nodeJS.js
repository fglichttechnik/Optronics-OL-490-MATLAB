var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.send('id: ' + req.query["id"]);
  //res.end('Hello World\n');
  console.log('received request');
}).listen(13370, '130.149.60.46');
console.log('Server running at http://130.149.60.46:13370/');