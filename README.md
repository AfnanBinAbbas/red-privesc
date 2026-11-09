# red-privesc

Post-foothold local enumeration — run ON the compromised shell (CTF/lab):

```bash
WS=~/redteam-runs/<target>/<ts> ./checks/privesc_enum.sh
```

Collects: id, `sudo -l`, SUID/SGID, capabilities, docker/lxd group, cron writability,
PATH writable dirs, kernel, mounts, docker.sock, env secrets, history, flag paths.

Output: `exploit/privesc_enum.txt`. Next: cross-ref against GTFOBins + kernel CVEs.
Authorized targets only.
