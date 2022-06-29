var http = require('http');
http.createServer(function(req,res) {

  var data = {
    RequestHeader: req.headers
  };

  if(req.method == 'GET') {
    response(res,data);
  }else if(req.method == 'POST') {
    req.on('data', function(body){
      data.RequestBody = body.toString();
      req.on('end',function(){
        response(res,data);
      });
    });
  }
}).listen(8080);

function response(res, data) {
  var json = JSON.stringify(data);
  res.writeHead(200, {'Content-Type':'application/json','Content-Length':json.length});
  res.end(json);
}