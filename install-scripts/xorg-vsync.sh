#!/bin/bash
# Kompletny skrypt Xorg + Intel + Picom (z animacjami i przezroczystością)
# Obsługiwane dystrybucje: Debian 13, Arch Linux, Fedora, openSUSE

set -e

echo "=== Sprawdzanie systemu ==="

install_if_missing_debian() {
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      sudo apt install -y "$pkg"
    else
      echo "Pakiet $pkg już zainstalowany."
    fi
  done
}

install_if_missing_arch() {
  for pkg in "$@"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
      sudo pacman -S --noconfirm "$pkg"
    else
      echo "Pakiet $pkg już zainstalowany."
    fi
  done
}

install_if_missing_fedora() {
  for pkg in "$@"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
      sudo dnf install -y "$pkg"
    else
      echo "Pakiet $pkg już zainstalowany."
    fi
  done
}

install_if_missing_opensuse() {
  for pkg in "$@"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
      sudo zypper install -y "$pkg"
    else
      echo "Pakiet $pkg już zainstalowany."
    fi
  done
}

if [ -f /etc/debian_version ]; then
  OS="debian"
  echo "System: Debian/Ubuntu"
  sudo apt update
  install_if_missing_debian picom xserver-xorg xserver-xorg-core xserver-xorg-video-intel xinit xdg-user-dirs x11-xserver-utils x11-utils
elif [ -f /etc/arch-release ]; then
  OS="arch"
  echo "System: Arch Linux"
  install_if_missing_arch picom xorg-server xorg-xinit xf86-video-intel xdg-user-dirs xorg-xrandr xorg-xset xorg-xprop xorg-xwininfo
elif [ -f /etc/fedora-release ]; then
  OS="fedora"
  echo "System: Fedora"
  install_if_missing_fedora picom xorg-x11-server-Xorg xorg-x11-xinit xorg-x11-drv-intel xdg-user-dirs xorg-x11-utils
elif [ -f /etc/SuSE-release ] || ([ -f /etc/os-release ] && grep -qi "opensuse" /etc/os-release); then
  OS="opensuse"
  echo "System: openSUSE"
  install_if_missing_opensuse picom xorg-x11-server xorg-x11 xorg-x11-xinit xf86-video-intel xdg-user-dirs xorg-x11-utils
else
  echo "Nieobsługiwany system. Obsługiwane: Arch Linux, Debian 13, Fedora, openSUSE"
  exit 1
fi

# Tworzenie folderu konfiguracyjnego dla picom
mkdir -p ~/.config/picom

# Tworzenie pliku konfiguracyjnego picom z animacjami, przezroczystością i cieniami
cat >~/.config/picom/picom.conf <<EOF
backend = "glx";
vsync = true;

# Animacje
fading = true;
fade-delta = 4;
fade-in-step = 0.03;
fade-out-step = 0.03;

# Cienie
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.5;

# Przezroczystość
inactive-opacity = 0.85;
active-opacity = 1.0;
frame-opacity = 0.9;
opacity-rule = [
    "90:class_g = 'URxvt'",
    "90:class_g = 'Alacritty'"
]

# Blur (opcjonalnie)
blur-method = "none";
EOF
echo "Stworzono ~/.config/picom/picom.conf z animacjami i przezroczystością"

# Tworzenie folderu Xorg config
sudo mkdir -p /etc/X11/xorg.conf.d/

# Konfiguracja Intel iGPU
sudo tee /etc/X11/xorg.conf.d/20-intel.conf >/dev/null <<EOF
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF
echo "Stworzono /etc/X11/xorg.conf.d/20-intel.conf z TearFree + DRI3"

echo "=== Konfiguracja zakończona! ==="
echo "Plik picom znajduje się w ~/.config/picom/picom.conf"
echo "Zrestartuj Xorg lub wyloguj się i zaloguj ponownie, aby zmiany zaczęły działać."
