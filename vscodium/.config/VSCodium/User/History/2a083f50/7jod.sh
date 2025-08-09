#!/bin/bash

# Pakiety zainstalowane tylko przeze mnie po instalacji CachyOs (wybrany desktop hyprland)
# Virt-Manager i potrzebne pakiety są instalowane razem ze skryptem instalacyjnym virt.sh
# Drukarka Brother DCP-1610W i potrzebne pakiety są instalowane razem ze skryptem instalacyjnym print.sh
#
#
# Install log save
exec > "$HOME/comai.txt" 2>&1
#
#
#
# Pacman
sudo pacman -S --needed --noconfirm acpi alacritty azote bash-completion bat blueman brightnessctl btop cliphist code cronie cups curl dunst eza fastfetch file-roller firefox fish font-manager foot fzf galculator gcc gcolor3 gimp gnome-disk-utility gparted grub-customizer gtk-engine-murrine gvfs gvfs-afc gvfs-dnssd gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb htop hyprland hyprpicker i3lock kitty libreoffice-fresh libreoffice-fresh-pl lm_sensors mako mc meld mlocate mousepad neovim network-manager-applet nsxiv numlockx nwg-look os-prober pamixer parcellite pavucontrol pdfarranger picom polkit-gnome power-profiles-daemon qt5ct ranger rclone ripgrep rofi rofi-emoji rsync sddm scrot slurp speedtest-cli starship stow swappy swaybg system-config-printer Tela-circle-icon-theme-dracula tealdeer thunar thunar-archive-plugin thunar-volman time timeshift tlp trash-cli tree tumbler udiskie unrar unzip vlc waybar wezterm wget wl-clipboard wofi xclip xdg-user-dirs xorg-xhost xwayland xreader yazi yt-dlp zathura zathura-pdf-mupdf zenity zoxide



#
# paru lub yay w zależności co zstało zainstalowane jeśli nic to:
#
# yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
#
# Paru
# sudo pacman -S --needed base-devel
# git clone https://aur.archlinux.org/paru.git
# cd paru
# makepkg -si
#
# 
yay -S --needed --noconfirm google-chrome grimblast-git mkinitcpio-firmware moc-pulse ookla-speedtest-bin simple-sddm-theme-git sublime-text-4 waypaper wlogout
