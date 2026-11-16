# Zenmap commands

Use only the verified Ubuntu project VM on the private VMware network. Our target was `172.16.57.128`. Keep the HTTP demonstration server running for steps 1–3. Paste a complete command into Zenmap's **Command** field and click **Scan**. SYN and OS detection require privileged Nmap execution.

## 1. Service and HTTP inspection

```bash
nmap -n -Pn -sT -sV -p 8000,8001 --reason --script http-title,http-headers 172.16.57.128
```

Save the completed scan as `mac-connect.xml` through Scan → Save Scan.

## 2. SYN scan and packet trace

```bash
nmap -n -Pn -sS -p 8000,8001 --reason --packet-trace 172.16.57.128
```

Save as `mac-syn.xml`. The original corrected run scanned exactly one IP. An old 0.0.0.2 sidebar entry in screenshots is history from an earlier typing error, not part of the corrected scan.

## 3. Service and OS assessment

```bash
nmap -n -Pn -sS -sV -O --osscan-limit -p 8000,8001 --script http-title,http-headers 172.16.57.128
```

Use capital letter **O**, not zero, for `-O`. Save as `mac-assessment.xml`. In the original run, Nmap found no exact OS match; an Ubuntu release must not be inferred from the Linux icon.

## 4. Verification after stopping the server

Stop the Ubuntu HTTP server with Control+C, then run:

```bash
nmap -n -Pn -sS -p 8000,8001 --reason 172.16.57.128
```

Save as `mac-remediated.xml`. If 8000 remains open, inspect whether the server stopped and repeat the check. Capture the command and completed result in Zenmap, not an unfinished scan. Retain warnings and uncertainty in your findings. For clean screenshots, capture only the relevant window with the mouse pointer hidden.

## Key options

| Option | Purpose |
|---|---|
| `-n` | Skip DNS resolution |
| `-Pn` | Skip ordinary host discovery; local ARP can still occur |
| `-sT` / `-sS` | TCP connect / SYN scan |
| `-sV` | Probe service versions |
| `-O` | Attempt OS fingerprinting |
| `-p` | Limit the requested port scan |
| `--reason` | Explain the reported port state |
| `--packet-trace` | Display sent and received packets |
| `--script` | Run the named HTTP inspection scripts |
