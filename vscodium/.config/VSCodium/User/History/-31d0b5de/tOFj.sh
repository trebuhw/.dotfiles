#!/bin/bash

# Install log save
# exec > "$HOME/plik_log.txt" 2>&1

# packer="sudo zypper -n install" # Wersja skrócona polecenia
packer="sudo zypper --non-interactive install --no-recommends"

$packer alacritty bash-completion bat blueman brightnessctl btop cpuid cups curl dconf-editorduf dunst fastfetch feh file-roller firefox fish flameshot font-manager fzf galculator gcc gcolor2 gimp git gnome-disk-utility gparted gsettings-desktop-schemas gzip harfbuzz-devel htop i3lock kitty libreoffice libreoffice-l10n-pl libX11-devel libXft-devel libXinerama-devel libxcb-res0 mako meld mlocate MozillaThunderbird neovim NetworkManager-applet ncurses-devel numlockx nwg-look opi os-prober p7zip papirus-icon-theme parcellite pavucontrol pdfarranger picom polkit polkit-gnome ranger rclone ripgrep rofi rsync scrot sensors starship stow sxhkd sxiv system-config-printer tealdeer tealdeer-fish-completion thunar thunar-volman time tree ueberzugpp unrar unzip vim vlc wget xclip xdg-user-dirs xfce4-notifyd xinit xorg-x11-driver-video xorg-x11-essentials xorg-x11-fonts xorg-x11-fonts-converted xorg-x11-fonts-core xorg-x11-fonts-legacy xorg-x11-libX11-ccache xorg-x11-server xorg-x11-server-extra xorg-x11-server-Xvfb xorg-x11-Xvnc xorg-x11-Xvnc-module xorgproto-devel xwininfo yazi zathura zathura-plugin-pdf-poppler zoxide

# Nvidia add repository
sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
sudo zypper refresh
sudo zypper dup

# Install Drives
$packer kernel-firmware-nvidia libnvidia-egl-wayland1 nvidia-compute-G06 nvidia-compute-G06-32bit nvidia-driver-G06-kmp-default nvidia-gl-G06 nvidia-gl-G06-32bit nvidia-video-G06 nvidia-video-G06-32bit xf86-video-intel

# OPI APP
opi google-chrome
opi trash-cli
opi sublime

# install QUEMU
$packer -t pattern kvm_server kvm_tools
$packer libvirt qemu virt-manager libvirt-daemon-driver-qemu qemu-kvma
sudo usermod -aG libvirt hubert
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
#sudo virsh net-list --all
sudo virsh net-autostart default
sudo virsh net-start default

#install Brother
$packer avahi sane-airscan sane-saned simple-scan sane-backends libstdc++6-32bit cups-filters
systemctl start avahi-daemon.service
systemctl enable avahi-daemon.service

# Install Github Desktop
#sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key
#sudo sh -c 'echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" > /etc/zypp/repos.d/shiftkey-packages.repo'
#sudo zypper ref && sudo zypper in github-desktop

# File Coopy
# sudo mv /etc/tlp.conf /etc/tlp.conf.bak
sudo cp -r ~/dwm/files/usr/share/rofi /usr/share
sudo cp -r ~/dwm/files/usr/share/xsessions/dwm.desktop /usr/share/xsessions
sudo cp -r ~/dwm/files/usr/share/fonts/{.,}* /usr/share/fonts
sudo cp -r ~/dwm/files/usr/share/icons/{.,}* /usr/share/icons
sudo cp -r ~/dwm/files/usr/share/themes/{.,}* /usr/share/themes
sudo cp ~/dwm/files/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d
sudo cp ~/dwm/files/etc/tlp.conf /etc

# TLP
sudo cp ~/dwm/files/etc/tlp.conf /etc
sudo systemctl enable tlp.service
sudo systemctl start tlp.servicea

# Coppy files
cp -r ~/dwm/files/home/{.,}* ~/
cp -r ~/dwm/files/.icons ~/
cp -r ~/dwm/files/.config/{.,}* ~/.config
sudo ln -s ~/.config/yazi/ /root/.config/
sudo ln -s ~/.config/ranger/ /root/.config/

# Make the file executable
cd /usr/share/xsessions
sudo chmod +x dwm.desktop

# Change shell to fish
sudo chsh $USER -s /usr/bin/fish


# Change hostname
sudo hostnamectl set-hostname tumbleweed

# Refrech fonts
sudo fc-cache -fv

# Install May DWM
cd ~/.config/suckless/dwm && make && sudo make clean install && cd ~
cd ~/.config/suckless/dmenu && make && sudo make clean install && cd ~
cd ~/.config/suckless/slstatus && make && sudo make clean install && cd ~
cd ~/.config/suckless/st && make && sudo make clean install


# Theme set
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-white-cursors'
gsettings set org.gnome.desktop.interface font-name 'MesloLGL Nerd Font 10'

sudo sed -i 's/Y2NCURSES_COLOR_THEME="[^"]*"/Y2NCURSES_COLOR_THEME="rxvt"/' /etc/sysconfig/yast2

systemctl reboot
