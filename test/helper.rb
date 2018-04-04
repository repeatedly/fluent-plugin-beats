require 'socket'

def find_available_port
  s = TCPServer.open(0)
  port = s.addr[1]
  s.close
  return port
end
