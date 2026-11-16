import socket,struct,time,sys
s=socket.socket(socket.AF_PACKET,socket.SOCK_RAW,socket.htons(3));s.bind(('login-scan',0));s.settimeout(.5)
with open(sys.argv[1],'wb') as f:
 f.write(struct.pack('<IHHIIII',0xa1b2c3d4,2,4,0,0,65535,1))
 end=time.monotonic()+8
 while time.monotonic()<end:
  try:p=s.recv(65535)
  except socket.timeout:continue
  now=time.time();sec=int(now)
  f.write(struct.pack('<IIII',sec,int((now-sec)*1e6),len(p),len(p)));f.write(p)
