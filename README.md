# CMPS380 Project — Nmap Network Security Assessment

A Cybersecurity Fundamentals project investigating how exposed network services create security risks, how Nmap reveals them, and how repeated checks verify a fix.

The workflow is **setup → scan → findings → fix → verification**. We used Zenmap on macOS to assess our Ubuntu VM, then demonstrated why dummy login traffic needs HTTPS in a separate isolated Ubuntu experiment. This demonstrates reconnaissance and exposure verification; it does not demonstrate an account takeover or a software exploit.

## Main findings

| Check | Observed result |
|---|---|
| Mac connect scan with HTTP scripts | Port 8000 open, Python HTTP service and directory listing; port 8001 filtered; 196.93 seconds |
| Corrected Mac SYN scan | Port 8000 open, port 8001 closed; 0.26 seconds |
| OS detection attempt | No exact OS match; one hop; 19.28 seconds |
| Browser check | Harmless backup.txt accessible without authentication |
| After stopping HTTP server | Ports 8000 and 8001 closed; 0.27 seconds |
| Separate dummy login comparison | Dummy password visible in HTTP packet bytes, not visible as plaintext in HTTPS capture |

Different scan options and conditions mean the timings are not a controlled speed comparison. The difference in port 8001 states was not conclusively explained. See [genuine screenshots and original results](evidence/README.md).

## Files

- `scripts/`: installation, demonstration server, scans, and login comparison.
- `website/`: dummy login website, test client, and dedicated-interface packet capture.
- `docs/zenmap-commands.md`: commands for the actual Zenmap application.
- `evidence/`: original results and labeled screenshots.

The scripts were packaged for reproduction after the assessment. They do not imply that the original Mac scans were run as a script. The full report is submitted separately.

## 1. Set up the project

Requirements: macOS with Nmap/Zenmap (the original Mac run used 7.993), VMware Fusion, and an Ubuntu VM. The original Ubuntu VM was 22.04.1, x86_64, with Python 3.10.4; earlier Ubuntu scans used Nmap 7.80. Package installation today may give different versions.

Download this repository with **Code → Download ZIP** and extract it on the Mac and in Ubuntu. Alternatively, use the clone URL shown by GitHub.

In Ubuntu, install prerequisites while package repositories are reachable:

```bash
bash scripts/setup-ubuntu.sh
```

Then select **VMware Fusion → Network Adapter → Private to my Mac**. Check the VM address and routing in Ubuntu:

```bash
uname -m
ip -br -4 address
ip -4 route
```

Our VM address was `172.16.57.128`, with no default IPv4 route. Confirm that this is still your own VM before using it; update the address in the instructions and scripts if it differs. Do not use bridged networking, port forwarding, or third-party targets for these tests.

## 2. Start the harmless file demonstration

In Ubuntu:

```bash
bash scripts/start-demo.sh
```

Leave it running. It serves only a dedicated temporary directory with a harmless `backup.txt` file. On the Mac, use [the Zenmap commands](docs/zenmap-commands.md) to discover the service and inspect its HTTP information. Then visit `http://172.16.57.128:8000/backup.txt` to verify access.

## 3. Fix and verify

In the Ubuntu terminal running the server, press **Control+C** and confirm that the command prompt returns. Run the verification scan in Zenmap. Record the actual result; a successful reproduction should show port 8000 closed. Stopping an unnecessary service removes this exposure; a required service would instead need appropriate access controls and secure configuration.

Optional terminal equivalents on the Mac:

```bash
bash scripts/scans.sh connect
bash scripts/scans.sh syn
bash scripts/scans.sh assessment
# Stop the Ubuntu server before this last command:
bash scripts/scans.sh verify
```

New exports go to ignored `results/`. Save each run before repeating if you want to retain all outputs.

## 4. Separate HTTP versus HTTPS demonstration

Inside Ubuntu, from the repository directory:

```bash
sudo bash scripts/login-comparison.sh
```

This creates a temporary network namespace at `10.200.39.2` connected to a dedicated interface at `10.200.39.1`. It has no default route. It starts HTTP on 8080 and HTTPS on 8443, generates a temporary certificate, makes dummy login requests, captures only the dedicated interface, checks for the dummy password bytes, and rescans after stopping HTTP. HTTPS certificate validation is enabled. The namespace and services are cleaned up on exit.

Dummy credentials: `student-demo` / `ProjectOnly-381`. These are intentionally public demonstration values, never real account credentials. The server uses simple hard-coded authentication solely to demonstrate transport security; it is not a production login system. Python's standard library is sufficient; no pip requirements or repository dependencies are needed.

New results are in `website/results/`. The original evidence predates the project naming update and retains the original dummy values. No original evidence has been rewritten to match the revised source. This packaged Linux workflow has been syntax-checked, not rerun as a new Ubuntu experiment during repository preparation.

## What we learned

An open port is an exposed service, not automatically a confirmed vulnerability. Service detection should be followed by verification, and a fix should be followed by another scan. HTTPS protects credentials in transit, while inconclusive scan results must remain labeled as inconclusive.

## References

- [Nmap reference guide](https://nmap.org/book/man.html)
- [Nmap port scanning techniques](https://nmap.org/book/man-port-scanning-techniques.html)
- [Nmap OS detection](https://nmap.org/book/man-os-detection.html)
- [Python HTTP server documentation](https://docs.python.org/3.10/library/http.server.html)
- [NIST SP 800-115: Technical Guide to Information Security Testing and Assessment](https://csrc.nist.gov/pubs/sp/800/115/final)
