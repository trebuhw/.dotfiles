#!/bin/bash

set -e

echo "=== Naprawa długiego zamykania systemu po virt-manager ==="

# 1. Wyłączenie autostartu libvirtd
echo "[1/4] Wyłączanie autostartu libvirtd..."
systemctl disable libvirtd >/dev/null 2>&1 || true

# 2. Upewnienie się, że socket activation zostaje
echo "[2/4] Włączanie socket activation libvirtd..."
systemctl enable libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket >/dev/null 2>&1

# 3. Skrócenie timeoutu zamykania libvirtd do 5s
echo "[3/4] Ustawianie TimeoutStopSec=5s..."
mkdir -p /etc/systemd/system/libvirtd.service.d

cat <<EOF >/etc/systemd/system/libvirtd.service.d/timeout.conf
[Service]
TimeoutStopSec=5s
EOF

# 4. Przeładowanie systemd
echo "[4/4] Przeładowanie konfiguracji systemd..."
systemctl daemon-reexec

echo
echo "=== GOTOWE ==="
echo "Sieć NAT libvirt (virbr0) pozostaje aktywna."
echo "libvirtd startuje tylko na żądanie,"
echo "a zamykanie systemu nie będzie się już wieszać."
echo
echo "Aktualny status libvirtd:"
systemctl status libvirtd --no-pager || true

