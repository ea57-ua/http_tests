from http.server import BaseHTTPRequestHandler, HTTPServer

class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.write_response()
        print("GET")

    def do_POST(self):
        len = int(self.headers.get('content-length',0))
        body = self.rfile.read(len)
        self.write_response()
        print("POST")
        print(f"Received: {body.decode('utf-8')} from {self.client_address}")


    def handle_request(self):
        len = int(self.headers.get('content-length',0))
        body = self.rfile.read(len)
        print(f"Received: {body.decode('utf-8')}")

    def write_response(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(bytes("<html> <body> <h1> WELCOME TO MY HTTP SERVER WITH PYTHON </h1> </body> </html> \n", "utf-8"))
        print(self.headers)


HOST = "127.0.0.1"
PORT = 8080

server = HTTPServer((HOST,PORT), MyHandler)
print(f"Http server starting at http://{HOST}:{PORT}")

try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
server.server_close()
print("Server stopped")