import socket
from zeroconf import ServiceInfo, Zeroconf

SERVICE_TYPE = "_bsb._tcp.local."
SERVICE_NAME = "BSB._bsb._tcp.local."
PORT = 8016
local_ip = "192.168.8.105" # set device ip from bsb

zeroconf = Zeroconf()
ip_address = socket.inet_aton(local_ip)

service_info = ServiceInfo(
    SERVICE_TYPE,
    SERVICE_NAME,
    addresses=[ip_address],
    port=PORT,
    properties={b"info": b"BSB"},
    server="bsb.local.",
)

zeroconf.register_service(service_info)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind(('', PORT))
    s.listen()
    print(f"Listening on port {PORT}")
    conn, addr = s.accept()
    with conn:
        print(f"Connected by {addr}")
        while True:
            message = input("Enter message (off or on) (id): ")
            conn.sendall(message.encode('utf-8'))
            print(f"Sent: {message}")
