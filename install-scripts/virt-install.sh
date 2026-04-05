#!/bin/bash
# Skrypt instalacji wirtualizacji na Arch Linux
# Hubert, 2026-01-17

set -e

echo "=== Instalacja/konfiguracja libvirt + QEMU + GUI ==="

# Sprawdzenie root
if [ "$EUID" -ne 0 ]; then
    echo "Uruchom skrypt jako root: sudo ./install-virt.sh"
    exit 1
fi

# MENU wyboru
echo
echo "Wybierz co chcesz zainstalować:"
echo "1) GNOME Boxes"
echo "2) virt-manager"
echo "3) Oba"
read -rp "Wybór (1/2/3): " choice

# Lista pakietów backend
backend_pkgs=(libvirt dnsmasq qemu-base qemu-desktop edk2-ovmf swtpm bridge-utils virt-viewer)
boxes_pkgs=(gnome-boxes)
virtmgr_pkgs=(virt-manager)

# Tworzymy listę do instalacji według wyboru
to_install=("${backend_pkgs[@]}")
case "$choice" in
    1) to_install+=("${boxes_pkgs[@]}") ;;
    2) to_install+=("${virtmgr_pkgs[@]}") ;;
    3) to_install+=("${boxes_pkgs[@]}" "${virtmgr_pkgs[@]}") ;;
    *) echo "Nieprawidłowy wybór"; exit 1 ;;
esac

# Sprawdzanie czy wszystko już zainstalowane
all_installed=true
for pkg in "${to_install[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        all_installed=false
        break
    fi
done

# Sprawdzenie NAT
nat_active=false
if virsh net-info default >/dev/null 2>&1; then
    if virsh net-info default | grep -q "Active: yes"; then
        nat_active=true
    fi
fi

# Sprawdzenie timeoutu
timeout_ok=false
if [ -f /etc/systemd/system/libvirtd.service.d/timeout.conf ]; then
    if grep -q "TimeoutStopSec=5s" /etc/systemd/system/libvirtd.service.d/timeout.conf; then
        timeout_ok=true
    fi
fi

# Sprawdzenie socket activation
socket_ok=false
if systemctl is-enabled libvirtd.socket >/dev/null 2>&1 && \
   systemctl is-enabled libvirtd-ro.socket >/dev/null 2>&1 && \
   systemctl is-enabled libvirtd-admin.socket >/dev/null 2>&1; then
    socket_ok=true
fi

# Jeśli wszystko jest OK → zakończ
if $all_installed && $nat_active && $timeout_ok && $socket_ok; then
    echo
    echo "Wszystko jest już zainstalowane i skonfigurowane. Nic nie trzeba robić."
    exit 0
fi

# Funkcja do instalacji pakietów
install_packages() {
    echo "Instalacja pakietów: $*"
    pacman -S --needed --noconfirm "$@"
}

# Instalacja brakujących pakietów
for pkg in "${to_install[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        install_packages "$pkg"
    fi
done

# Konfiguracja libvirtd
echo "Konfiguracja libvirtd..."
systemctl disable libvirtd >/dev/null 2>&1 || true
systemctl enable libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket >/dev/null 2>&1 || true

# Skrócenie timeoutu do 5s
mkdir -p /etc/systemd/system/libvirtd.service.d
echo -e "[Service]\nTimeoutStopSec=5s" >/etc/systemd/system/libvirtd.service.d/timeout.conf

systemctl daemon-reexec

# NAT
if ! $nat_active; then
    echo "Tworzenie NAT (virbr0)..."
    virsh net-define /usr/share/libvirt/networks/default.xml >/dev/null 2>&1 || true
    virsh net-autostart default >/dev/null 2>&1 || true
    virsh net-start default >/dev/null 2>&1 || true
fi

echo
echo "=== GOTOWE ==="
echo "libvirtd startuje na żądanie."
echo "NAT (virbr0) aktywny."
echo "Wybrane GUI i backend zainstalowane."
systemctl status libvirtd --no-pager || true

