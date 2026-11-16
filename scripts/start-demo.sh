#!/bin/bash
set -eu
# Only bind to the verified project VM address; change after checking your VM.
TARGET=172.16.57.128
mkdir -p /tmp/cmps380-project
printf '%s\n' 'CMPS project demonstration file' > /tmp/cmps380-project/backup.txt
exec python3 -m http.server 8000 --bind "$TARGET" --directory /tmp/cmps380-project
