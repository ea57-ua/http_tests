const http = require("http");


const host = '127.0.0.1'; 
const port = 8080; 

const requestListener = function (req, res) { 
    res.setHeader("Content-Type", "text/html"); 
    res.writeHead(200); 
    res.end(`<html><body><h2><Strong> Hello from http server (JS) </h2></body></html>`);
   };


const server = http.createServer(requestListener); 

server.on('connection',(socket) => {
    console.log("New connection !!");
})
server.listen(port, host, () => { 
    console.log(`Server is running on http://${host}:${port}`); 
}); 