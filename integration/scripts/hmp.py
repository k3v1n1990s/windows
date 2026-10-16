import socket,sys,re
s=socket.socket(socket.AF_UNIX);s.settimeout(15);s.connect('/run/shm/monitor.sock')
def response():
 out=b''
 while not out.endswith(b'(qemu) '):
  b=s.recv(65536)
  if not b:break
  out+=b
 return out
response()
s.sendall((' '.join(sys.argv[1:])+'\n').encode())
out=response().decode(errors='replace')
print('\n'.join(re.sub(r'\x1b\[[0-9;?]*[A-Za-z]','',out).splitlines()[1:]))
