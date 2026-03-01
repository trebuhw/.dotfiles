#!/usr/bin/env bash
set -e

echo "=== Debian Minimal Hyprland + LightDM Setup ==="

echo "==> Wyłączam Recommends globalnie"
echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/99no-recommends

echo "==> Aktualizacja systemu"
apt update
apt upgrade -y

echo "==> Podstawy systemu"
apt install -y --no-install-recommends \
  sudo \
  curl \
  wget \
  git \
  ca-certificates \
  dbus-user-session \
  policykit-1 \
  xdg-user-dirs \
  xdg-utils

echo "==> NetworkManager (bez GNOME)"
apt install -y --no-install-recommends \
  network-manager
systemctl enable NetworkManager

echo "==> Wayland + Hyprland"
apt install -y --no-install-recommends \
  hyprland \
  xwayland \
  wayland-protocols \
  wl-clipboard \
  grim \
  slurp \
  swappy

echo "==> Audio (PipeWire minimal)"
apt install -y --no-install-recommends \
  pipewire \
  wireplumber \
  pipewire-pulse \
  libspa-0.2-bluetooth \
  pavucontrol

echo "==> Portal Wayland"
apt install -y --no-install-recommends \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland

echo "==> LightDM (lekki display manager)"
apt install -y --no-install-recommends \
  lightdm \
  lightdm-gtk-greeter
systemctl enable lightdm

echo "==> Terminal + launcher + powiadomienia"
apt install -y --no-install-recommends \
  foot \
  wofi \
  mako-notifier

echo "==> Narzędzia użytkowe"
apt install -y --no-install-recommends \
  brightnessctl \
  playerctl \
  thunar \
  thunar-archive-plugin

echo "==> Bluetooth (opcjonalnie)"
apt install -y --no-install-recommends \
  bluez \
  blueman
systemctl enable bluetooth

echo "==> Tworzenie katalogów użytkownika"
xdg-user-dirs-update || true

echo
echo "========================================="
echo "Instalacja zakończona."
echo
echo "W LightDM wybierz sesję: Hyprland"
echo
echo "Brak GNOME. Brak KDE. Brak meta-desktopów."
echo "========================================="
