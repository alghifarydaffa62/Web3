const http = require('http');
const fs = require('fs');

const server = http.createServer(function(request, response) {
    let filename = "index.html";
    let contentType = "text/html";
    if(request.url === "/style.css") {
        filename = "style.css";
        contentType = "text/css";
    }

    fs.readFile(filename, function(err, content) {
        if(err) {
            response.statusCode = 500;
            response.end("Could not serve ${filename}");
        }
        else {
            response.statusCode = 200;
            response.setHeader('Content-Type', contentType);
            response.end(content);
        }
    });
});

server.listen({ port: 3000, host: 'localhost' }, function() {
  console.log('Server is running!');
});

