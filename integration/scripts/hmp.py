import socket,sys,time
s=socket.socket(socket.AF_UNIX);s.settimeout(5);s.connect('/run/shm/monitor.sock')
s.recv(65536)
s.sendall((' '.join(sys.argv[1:])+'\n').encode())
out=b''
while True:
 try:
  b=s.recv(65536)
  if not b:break
  out+=b
  if b'(qemu)' in out:break
 except TimeoutError:break
print(out.decode(errors='replace'))
