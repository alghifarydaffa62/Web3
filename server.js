const http = require('http');

const server = http.createServer(function(request, response) {
  response.statusCode = 200;
  response.setHeader('Content-Type', 'text/html');
  response.end(HTML);
});

server.listen({ port: 3000, host: 'localhost' }, function() {
  console.log('Server is running!');
});

const HTML = `
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>My Hello World</title>
    <style>
      body {
        background-color: black;
        color: yellow;
        text-align: center;
        font-size: 40px;
      }
    </style>
  </head>
  <body>
    Hello World
  </body>
</html>
`;