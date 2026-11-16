#!/bin/bash
set -eu
# Install while network access is available; then switch VMware to Private to my Mac.
[ "$(uname -s)" = Linux ] || { echo "Run inside Ubuntu."; exit 1; }
sudo apt-get update
sudo apt-get install -y python3 nmap openssl iproute2
uname -m
python3 --version
nmap --version
