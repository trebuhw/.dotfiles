#!/usr/bin/env bash

set -e

echo "=== Aktualizacja systemu ==="
apt update && apt upgrade -y

echo "=== Instalacja repozytoriów i narzędzi podstawowych ==="
apt install -y \
  build-essential \
  curl \
  wget \
  git \
  foot \
  kitty \
  alacritty \
  neovim \
  network-manager \
  network-manager-gnome \
  policykit-1 \
  polkitd \
  dbus-user-session \
  xdg-user-dirs \
  xdg-utils

echo "=== Instalacja Wayland i Hyprland ==="
apt install -y \
  hyprland \
  wayland-protocols \
  xwayland \
  wl-clipboard \
  grim \
  slurp \
  swappy

echo "=== PipeWire (audio) ==="
apt install -y \
  pipewire \
  wireplumber \
  pipewire-audio \
  pipewire-pulse \
  libspa-0.2-bluetooth \
  pavucontrol

echo "=== Portal dla Wayland ==="
apt install -y \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland

echo "=== Logowanie graficzne (SDDM) ==="
apt install -y sddm
systemctl enable sddm

echo "=== Powiadomienia i aplikacje pomocnicze ==="
apt install -y \
  mako-notifier \
  rofi-wayland \
  wofi \
  waybar \
  swaybg \
  swaylock \
  swayidle \
  brightnessctl \
  playerctl \
  thunar \
  thunar-archive-plugin \
  file-roller

echo "=== Bluetooth (opcjonalnie) ==="
apt install -y \
  bluez \
  blueman
systemctl enable bluetooth

echo "=== Włączenie NetworkManager ==="
systemctl enable NetworkManager

echo "=== Tworzenie katalogów użytkownika ==="
xdg-user-dirs-update

echo "=== Gotowe ==="
echo "Zrestartuj system i wybierz Hyprland w SDDM."
