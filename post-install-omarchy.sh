#!/usr/bin/env bash
set -euo pipefail

### =========================
###  LOGGING
### =========================
LOG_DIR="$HOME/.local/share/omarchy-logs"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/post-install-$TIMESTAMP.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

### =========================
###  CONFIG
### =========================
USER_NAME="hubert"
DOTFILES_REPO="https://github.com/trebuhw/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

PACMAN_PKGS=(
  alsa-utils
  baobab
  bat
  brightnessctl
  fcitx5-configtool
  fish
  gnome-boxes
  htop
  nsxiv
  nwg-look
  qt5ct
  qt6ct
  rsync
  speedtest-cli
  stow
  tlp
  trash-cli
  vlc
  xdg-user-dirs
  xorg-xrdb
  yazi
  zathura
  zathura-pdf-mupdf
)

AUR_PKGS=(
  catppuccin-gtk-theme-mocha
  kvantum-theme-catppuccin-git
  tela-circle-icon-theme-dracula
)

REMOVE_PKGS=(
  1password-beta
  1password-cli
  containerd
  docker
  docker-buildx
  docker-compose
  github-cli
  kdenlive
  lazydocker
  obs-studio
  power-profiles-daemon
  runc
  signal-desktop
  typora
  ufw-docker
  xournalpp
)

STOW_PKGS=(
  applications
  backgrounds
  bat
  bin
  chromium
  fastfetch
  fcitx5
  fish
  ghostty
  hypr
  Kvantum
  nsxiv
  nvim
  qt5ct
  qt6ct
  waybar
  Xresources
  yazi
  zathura
)

CONFIG_BACKUPS=(
  "$HOME/.local/share/applications"
  "$HOME/.local/share/omarchy/themes/catppuccin/backgrounds"
  "$HOME/.config/bat"
  "$HOME/.config/bin"
  "$HOME/.config/chromium-flags.conf"
  "$HOME/.config/etc"
  "$HOME/.config/fastfetch"
  "$HOME/.config/fcitx5"
  "$HOME/.config/fish"
  "$HOME/.config/ghostty"
  "$HOME/.config/hypr"
  "$HOME/.config/Kvantum"
  "$HOME/.config/nsxiv"
  "$HOME/.config/nvim"
  "$HOME/.config/qt5ct"
  "$HOME/.config/qt6ct"
  "$HOME/.config/waybar"
  "$HOME/.config/Xresources"
  "$HOME/.config/yazi"
  "$HOME/.config/zathura"
)

### =========================
###  HELPERS
### =========================
msg() { echo -e "\n\033[1;32m==> $1\033[0m"; }

ensure_yay() {
  if ! command -v yay &>/dev/null; then
    msg "Installing yay"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
  fi
}

backup_if_exists() {
  local src="$1"
  local dst="$1.bak"
  [[ ! -e "$src" ]] && return 0
  [[ -e "$dst" ]] && return 0
  mv "$src" "$dst"
}

enable_service_if_needed() {
  local svc="$1"
  if ! systemctl is-active --quiet "$svc"; then
    sudo systemctl start "$svc"
  fi
  if ! systemctl is-enabled --quiet "$svc"; then
    sudo systemctl enable "$svc"
  fi
}

### =========================
###  PACKAGES
### =========================
msg "Installing pacman packages"
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

ensure_yay
msg "Installing AUR packages"
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

### =========================
###  LOCALE / KEYBOARD (PL)
### =========================
msg "Configuring locale and keyboard (pl_PL)"
sudo sed -i 's/^#pl_PL.UTF-8/pl_PL.UTF-8/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=pl_PL.UTF-8
sudo localectl set-x11-keymap pl
sudo tee /etc/vconsole.conf >/dev/null <<'EOF'
KEYMAP=pl
FONT=lat2-Terminus16
EOF

### =========================
###  REMOVE UNWANTED SOFTWARE
### =========================
msg "Removing docker stack and unused applications"
sudo systemctl stop docker.service docker.socket containerd.service 2>/dev/null || true
sudo systemctl disable docker.service docker.socket containerd.service 2>/dev/null || true
sudo pacman -Rns --noconfirm "${REMOVE_PKGS[@]}" || true

### =========================
###  DEFAULT SHELL
### =========================
msg "Setting default shell to fish"
FISH_PATH="$(command -v fish)"
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
  chsh -s "$FISH_PATH"
else
  msg "Fish is already the default shell"
fi

### =========================
###  DOTFILES
### =========================
msg "Cloning or updating dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull
fi

cd "$DOTFILES_DIR"

### =========================
###  SAFE BACKUP + STOW
### =========================
msg "Backing up existing configs and stowing dotfiles"

for path in "${CONFIG_BACKUPS[@]}"; do
  backup_if_exists "$path"
done

for pkg in "${STOW_PKGS[@]}"; do
  [[ ! -d "$pkg" ]] && continue
  while IFS= read -r file; do
    backup_if_exists "$HOME/$file"
  done < <(
    stow -n --target="$HOME" "$pkg" 2>&1 |
    awk '/existing target is neither a link nor a directory/ {print $NF}'
  )
  stow --target="$HOME" "$pkg"
done

### =========================
###  VIRTUALIZATION (LIBVIRT)
### =========================
msg "Configuring libvirt / QEMU"
sudo pacman -S --needed --noconfirm \
  qemu-full qemu-img libvirt virt-install virt-manager virt-viewer \
  edk2-ovmf swtpm guestfs-tools libosinfo dnsmasq iptables dmidecode

enable_service_if_needed libvirtd.service
sudo usermod -aG libvirt "$USER_NAME"
sudo virsh net-autostart default || true
sudo virsh net-start default || true

### =========================
###  USER DIRS
### =========================
msg "Updating XDG user directories"
LANG=pl_PL.UTF-8 xdg-user-dirs-update --force

### =========================
###  POWER / SERVICES (TLP)
### =========================
msg "Configuring power management (TLP)"

# Backup istniejącego tlp.conf jeśli istnieje
if [[ -f /etc/tlp.conf ]]; then
    msg "Backing up existing /etc/tlp.conf to /etc/tlp.conf.bak"
    sudo mv /etc/tlp.conf /etc/tlp.conf.bak
fi

# Skopiuj własny plik tlp.conf
if [[ -f "$HOME/.dotfiles/etc/.config/tlp.conf" ]]; then
    msg "Copying custom tlp.conf from dotfiles"
    sudo cp "$HOME/.dotfiles/etc/.config/tlp.conf" /etc/tlp.conf
fi

# Włącz i uruchom usługę TLP
sudo systemctl stop power-profiles-daemon.service 2>/dev/null || true
sudo systemctl disable power-profiles-daemon.service 2>/dev/null || true
# sudo systemctl enable tlp.service --now
# sudo systemctl start tlp.service

### =========================
###  BOOTLOADER (LIMINE)
### =========================
# aby dodać na raz kilka bootloaderów wybierz numery 1 2 3 tylko spacja między numerami

#if command -v limine-scan &>/dev/null; then
#  msg "Scanning bootloaders (Limine)"
#  sudo limine-scan
#else
#  msg "limine-scan not found – skipping"
#fi

### =========================
###  FINISH
### =========================
msg "POST-INSTALL FINISHED ✔"

echo -e "\nNiektóre zmiany wymagają restartu systemu."
read -rp "Czy chcesz teraz zrestartować komputer? [y/N]: " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
  msg "Restarting system..."
  sudo reboot
else
  msg "Restart pominięty. Zmiany zostaną w pełni zastosowane po kolejnym uruchomieniu."
fi

