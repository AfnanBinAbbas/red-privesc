#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
parse_common_args "$@"
: "${WS:=$HOME/redteam-runs/probe}"
OUT="${OUT:-$WS/exploit/privesc_enum.txt}"
mkdir -p "$(dirname "$OUT")"

echo "privesc enum ($(date -u +%FT%TZ)) host=$(hostname 2>/dev/null || echo unknown)" > "$OUT"
{
echo "=== id/whoami ==="; id; whoami
echo "=== sudo -l ==="; sudo -n -l 2>&1 | head -40 || true
echo "=== SUID ==="; find / -perm -4000 -type f 2>/dev/null | head -60
echo "=== SGID ==="; find / -perm -2000 -type f 2>/dev/null | head -40
echo "=== capabilities ==="; getcap -r / 2>/dev/null | head -40 || true
echo "=== docker group ==="; groups | tr ' ' '\n' | grep -iE "docker|lxd|sudo|wheel|adm" || true
echo "=== writable cron ==="; ls -la /etc/cron* 2>/dev/null; crontab -l 2>/dev/null || true
echo "=== world-writable dirs in PATH ==="; echo "$PATH" | tr ':' '\n' | while read -r d; do [[ -d "$d" && -w "$d" ]] && echo "WW: $d"; done
echo "=== kernel ==="; uname -a
echo "=== os-release ==="; cat /etc/os-release 2>/dev/null | head -6
echo "=== interesting mounts ==="; mount | grep -vE "proc|sysfs|cgroup|devpts|mqueue" | head -20
echo "=== docker.sock ==="; ls -la /var/run/docker.sock 2>/dev/null || echo none
echo "=== env secrets ==="; env | grep -iE "key|token|secret|pass" | head -20 || true
echo "=== history ==="; tail -30 ~/.bash_history 2>/dev/null || true
echo "=== flag paths ==="; ls -la /root/root.txt /root/flag.txt /flag.txt /flag 2>/dev/null || true
} >> "$OUT" 2>&1

echo "---" >> "$OUT"
echo "next: cross-ref SUID/caps/sudo against GTFOBins; check kernel vs CVE db; try docker.sock escape" >> "$OUT"
logcheck "privesc_enum" "$OUT"
