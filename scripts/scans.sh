#!/bin/bash
set -eu
# Reproduction helper. Original Mac scans were entered in Zenmap.
TARGET=172.16.57.128
mkdir -p results
case "${1:-}" in
 connect) nmap -n -Pn -sT -sV -p 8000,8001 --reason --script http-title,http-headers "$TARGET" -oA results/connect ;;
 syn) sudo nmap -n -Pn -sS -p 8000,8001 --reason --packet-trace "$TARGET" -oA results/syn ;;
 assessment) sudo nmap -n -Pn -sS -sV -O --osscan-limit -p 8000,8001 --script http-title,http-headers "$TARGET" -oA results/assessment ;;
 verify) sudo nmap -n -Pn -sS -p 8000,8001 --reason "$TARGET" -oA results/remediated ;;
 *) echo 'Usage: bash scripts/scans.sh connect|syn|assessment|verify'; exit 1 ;;
esac
