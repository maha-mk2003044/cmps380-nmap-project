from http.server import BaseHTTPRequestHandler,HTTPServer
from urllib.parse import parse_qs
import ssl,sys
class Login(BaseHTTPRequestHandler):
 def do_GET(self):
  page=b'<!doctype html><title>CMPS380 Project</title><h1>CMPS380 Project</h1><p>Dummy credentials only. Authorized isolated experiment.</p><form method="post" action="/login"><label>Username <input name="username"></label><br><label>Password <input type="password" name="password"></label><br><button>Log in</button></form>'
  self.send_response(200);self.send_header('Content-Type','text/html');self.end_headers();self.wfile.write(page)
 def do_POST(self):
  data=parse_qs(self.rfile.read(int(self.headers.get('Content-Length','0'))).decode())
  ok=data.get('username')==['student-demo'] and data.get('password')==['ProjectOnly-381']
  self.send_response(200 if ok else 401);self.end_headers();self.wfile.write(b'DEMO LOGIN SUCCESS' if ok else b'DEMO LOGIN DENIED')
server=HTTPServer(('10.200.39.2',int(sys.argv[1])),Login)
if len(sys.argv)>2:
 ctx=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER);ctx.load_cert_chain('cert.pem','key.pem');server.socket=ctx.wrap_socket(server.socket,server_side=True)
server.serve_forever()
