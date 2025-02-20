#!/bin/bash

# Start the shadowlink (xray) service in the background
/opt/shadowlink/xray-core/xray run -c /opt/shadowlink/xray-core/tunnel_server.json &

# Start the x-ui service in the background
cd /opt/shadowlink/3x-ui && ./3x-ui &

# Wait to keep the script running (this ensures systemd knows the service is still running)
wait
