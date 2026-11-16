#!/bin/bash
set -eu
[ "$(uname -s)" = Linux ] || { echo "Run this inside Ubuntu."; exit 1; }
[ "$(id -u)" = 0 ] || { echo "Run with sudo inside Ubuntu."; exit 1; }
cd "$(dirname "$0")/../website"
mkdir -p results
if ip netns list | grep -q '^login-target'; then
 echo 'login-target already exists. Inspect and clean up the previous project first.'
 exit 1
fi
if ip link show login-scan >/dev/null 2>&1; then
 echo 'login-scan already exists. Inspect the previous project first.'
 exit 1
fi
cleanup() {
 for p in ${HTTP_PID:-} ${HTTPS_PID:-}; do kill "$p" 2>/dev/null || true; done
 ip netns delete login-target 2>/dev/null || true
}
trap cleanup EXIT
ip netns add login-target
ip link add login-scan type veth peer name login-target
ip link set login-target netns login-target
ip addr add 10.200.39.1/30 dev login-scan
ip link set login-scan up
ip netns exec login-target ip addr add 10.200.39.2/30 dev login-target
ip netns exec login-target ip link set login-target up
ip netns exec login-target ip link set lo up
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 2 -subj /CN=cmps-login-project -addext subjectAltName=IP:10.200.39.2 >results/cert-build.log 2>&1
ip netns exec login-target python3 server.py 8080 >results/http-server.log 2>&1 &
HTTP_PID=$!
ip netns exec login-target python3 server.py 8443 tls >results/https-server.log 2>&1 &
HTTPS_PID=$!
sleep 1
nmap -n -sS -sV --version-light -p 8080,8443 --script http-title,http-headers,ssl-cert 10.200.39.2 -oA results/login-nmap
python3 capture.py results/http.pcap &
CAP=$!
sleep 1
python3 client.py http://10.200.39.2:8080/login >results/http-client.txt
wait "$CAP"
python3 capture.py results/https.pcap &
CAP=$!
sleep 1
python3 client.py https://10.200.39.2:8443/login >results/https-client.txt
wait "$CAP"
python3 - <<'PY'
from pathlib import Path
with open('results/comparison.txt','w') as f:
 for name in ['http','https']:
  data=Path('results/'+name+'.pcap').read_bytes()
  f.write(name.upper()+' capture bytes = '+str(len(data))+'\n')
  f.write('Dummy password visible in packet bytes = '+str(b'ProjectOnly-381' in data)+'\n')
  f.write(Path('results/'+name+'-client.txt').read_text())
PY
kill "$HTTP_PID"
wait "$HTTP_PID" || true
HTTP_PID=
nmap -n -sS -p 8080,8443 --reason 10.200.39.2 -oA results/protected
cat results/comparison.txt
echo "New results are in website/results; these do not replace the original evidence."
