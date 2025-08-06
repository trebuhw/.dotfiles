#!/bin/bash

set -e

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

success() {
    echo -e "\e[34m[SUCCESS]\e[0m $1"
}

warning() {
    echo -e "\e[33m[WARNING]\e[0m $1"
}

check_success() {
    if [ $? -ne 0 ]; then
        error "$1"
        exit 1
    fi
}

# Wykrywanie dystrybucji
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
    log "Wykryto dystrybucję: Arch Linux"
elif [ -f /etc/lsb-release ] && grep -qi "ubuntu" /etc/lsb-release; then
    DISTRO="ubuntu"
    log "Wykryto dystrybucję: Ubuntu"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
    log "Wykryto dystrybucję: Debian"
elif grep -qi "opensuse" /etc/os-release; then
    DISTRO="opensuse"
    log "Wykryto dystrybucję: openSUSE"
elif grep -qi "fedora" /etc/os-release; then
    DISTRO="fedora"
    log "Wykryto dystrybucję: Fedora"
else
    error "Nieobsługiwana dystrybucja. Skrypt obsługuje: Arch, Ubuntu, Debian, Fedora, openSUSE."
    exit 1
fi

# Instalacja yay dla Arch Linux
install_yay() {
    if ! command -v yay &> /dev/null; then
        log "Instalacja yay z AUR..."
        tempdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
        (
            cd "$tempdir/yay" || exit 1
            makepkg -si --noconfirm
        )
        rm -rf "$tempdir"
        check_success "Nie udało się zainstalować yay"
    else
        log "yay jest już zainstalowany"
    fi
}

# Zależności DWM
install_dwm_deps() {
    case "$DISTRO" in
        arch)
            log "Instalacja zależności DWM dla Arch Linux..."
            sudo pacman -S --needed --noconfirm brightnessctl grim hyprland mako networkmanager qt5-wayland qt6-wayland slurp swaybg swayidle swaylock waybar wireplumber wl-clipboard xdg-desktop-portal-hyprland 
            ;;
        ubuntu|debian)
            log "Instalacja zależności DWM dla $DISTRO..."
            sudo apt update
            sudo apt install -y 
            ;;
        fedora)
            log "Instalacja zależności DWM dla Fedora..."
            sudo dnf install -y 
            ;;
        opensuse)
            log "Instalacja zależności DWM dla openSUSE..."
            sudo sudo zypper --non-interactive install --no-recommends 
            ;;
    esac
    check_success "Nie udało się zainstalować zależności DWM"
}

# Pakiety wspólne (repozytoria oficjalne)
COMMON_PACKAGES=(
    azote bash-completion bat blueman btop brightnessctl cliphist cronie cups curl file-roller firefox fish foot fzf galculator gcc gcolor3 gnome-disk-utility gparted grub-customizer gzip htop hyprpicker hyprland i3lock iptables kitty mako mc meld neovim numlockx nwg-look os-prober pamixer parcellite pavucontrol pdfarranger picom polkit-gnome qemu-full qemu-img qt5ct ranger rclone ripgrep rofi rofi-emoji rsync sane sddm scrot simple-scan slurp starship stow sxhkd swappy swaybg system-config-printer thunar thunar-archive-plugin thunar-volman time timeshift trash-cli tree tumbler unrar unzip virt-install virt-manager virt-viewer vlc waybar wget wl-clipboard wofi xfce4-notifyd xfce4-terminal xclip xdg-user-dirs xreader yazi yt-dlp zathura zathura-pdf-mupdf zoxide
)

# Odpowiedniki i pakiety dodatkowe
case "$DISTRO" in
    arch)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" alacritty code eza fastfetch font-manager libreoffice-fresh libreoffice-fresh-pl lm_sensors mousepad network-manager-applet nsxiv nwg-look mlocate os-prober polkit-gnome starship swappy tealdeer wezterm wofi yazi)
        YAY_PACKAGES=(
        brother-dcp1610w brscan4 google-chrome grimblast-git moc-pulse mkinitcpio-firmware simple-sddm-theme-git sublime-text-4 waypaper wlogout)
        ;;
    ubuntu)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" 
            
            )
        ;;
    debian)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}"

            )
        ;;
    fedora)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}"
            
            )
        ;;
    opensuse)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}"

            )
        ;;
esac

# Instalacja pakietów z repozytoriów
install_repo_packages() {
    local pkgs=("$@")
    case "$DISTRO" in
        arch)
            sudo pacman -S --needed --noconfirm "${pkgs[@]}"
            ;;
        ubuntu|debian)
            sudo apt install -y "${pkgs[@]}"
            ;;
        fedora)
            sudo dnf install -y "${pkgs[@]}"
            ;;
        opensuse)
            sudo zypper --non-interactive install --no-recommends "${pkgs[@]}"
            ;;
    esac
}

# Funkcje dla specyficznych konfiguracji dystrybucji
# ===================================================

# Specyficzne konfiguracje dla Arch Linux
arch_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla Arch Linux..."
    
    # Zmiana powłoki shell
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh $USER -s /bin/fish && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Włączanie i uruchamianie usług
    log "Konfiguracja usług systemowych..."
    sudo systemctl enable --now NetworkManager 
    sudo systemctl enable --now cups
    sudo systemctl enable sddm

    # Konfiguracja pacman
    log "Konfigurowanie pacman..."
    if ! grep -q "Color" /etc/pacman.conf; then
        sudo sed -i 's/#Color/Color/' /etc/pacman.conf && success "Włączono kolorowe wyjście pacman."
    fi
    
    if ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
    sudo sed -i '/\[options\]/a ParallelDownloads = 50' /etc/pacman.conf && success "Dodano ParallelDownloads = 50 do pacman.conf."
    else
    sudo sed -i 's/^#\?ParallelDownloads *= *.*/ParallelDownloads = 50/' /etc/pacman.conf && success "Ustawiono ParallelDownloads = 50 w pacman.conf."
    fi

    # Optymalizacja systemu
    log "Optymalizacja systemu Arch..."
    echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
    
    # Optymalizacja SSD (jeśli jest)
    if [ -d "/sys/block/sda/queue/rotational" ] && [ "$(cat /sys/block/sda/queue/rotational)" -eq 0 ]; then
        log "Wykryto SSD, optymalizacja..."
        echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-ssd.conf > /dev/null
        sudo systemctl enable fstrim.timer
    fi
}

# Specyficzne konfiguracje dla Ubuntu
ubuntu_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla Ubuntu..."
    
    # Zmiana powłoki shell
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh -s /usr/bin/fish $USER && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Konfiguracja APT
    log "Konfigurowanie APT..."
    echo 'APT::Install-Recommends "false";' | sudo tee /etc/apt/apt.conf.d/99custom > /dev/null
    echo 'APT::Install-Suggests "false";' | sudo tee -a /etc/apt/apt.conf.d/99custom > /dev/null
    
    # Włączanie firewall
    log "Konfiguracja firewall..."
    sudo ufw enable
    
    # Usuwanie snapd jeśli użytkownik tego chce
    read -p "Czy chcesz usunąć snapd? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Usuwanie snapd..."
        sudo apt purge -y snapd
        sudo apt autoremove -y
        mkdir -p $HOME/.config/autostart/
        # Zapobieganie reinstalacji snapd
        cat > $HOME/.config/autostart/nosnap.desktop << EOF
[Desktop Entry]
Type=Application
Name=NoSnap
Exec=sudo apt-mark hold snapd
EOF
        success "Usunięto snapd i zabezpieczono przed reinstalacją."
    fi
}

# Specyficzne konfiguracje dla Debian
debian_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla Debian..."
    
    # Zmiana powłoki shell
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh -s /usr/bin/fish $USER && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Konfiguracja APT (podobnie jak Ubuntu, ale może być nieco inaczej)
    log "Konfigurowanie APT..."
    echo 'APT::Install-Recommends "false";' | sudo tee /etc/apt/apt.conf.d/99custom > /dev/null
    echo 'APT::Install-Suggests "false";' | sudo tee -a /etc/apt/apt.conf.d/99custom > /dev/null
    
    # Dodanie repozytoriów non-free jeśli ich nie ma
    if ! grep -q "non-free" /etc/apt/sources.list; then
        log "Dodawanie repozytoriów non-free..."
        sudo sed -i 's/main/main non-free contrib/g' /etc/apt/sources.list
        sudo apt update
    fi
    
    # Konfiguracja dnsmasq dla szybszego DNS
    log "Konfiguracja dnsmasq dla szybszego rozwiązywania DNS..."
    sudo apt install -y dnsmasq
    echo "listen-address=127.0.0.1" | sudo tee /etc/dnsmasq.conf > /dev/null
    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf.head > /dev/null
    sudo systemctl restart dnsmasq
}

# Specyficzne konfiguracje dla Fedora
fedora_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla Fedora..."
    
    # Zmiana powłoki shell
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh -s /bin/fish $USER && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Optymalizacja DNF
    log "Optymalizacja DNF..."
    echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    echo "deltarpm=true" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    
    # Dodanie RPM Fusion jeśli nie ma
    if ! dnf repolist | grep -q "rpmfusion-free"; then
        log "Dodawanie repozytoriów RPM Fusion..."
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
    
    # Instalacja sterowników
    log "Instalacja sterowników do multimediów..."
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
    sudo dnf install -y lame\* --exclude=lame-devel
    
    # Konfiguracja firewall
    log "Konfiguracja firewall..."
    sudo firewall-cmd --set-default-zone=home
    sudo firewall-cmd --reload
}

# Specyficzne konfiguracje dla openSUSE
opensuse_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla openSUSE..."
    
    # Zmiana powłoki shell (inaczej niż w innych dystrybucjach)
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh -s /usr/bin/fish $USER && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Optymalizacja Zypper
    log "Optymalizacja Zypper..."
    sudo sed -i 's/# solver.onlyRequires = false/solver.onlyRequires = true/' /etc/zypp/zypp.conf
}

# Wykonywanie głównego kodu skryptu
# ===================================================

# Instalacja zależności
install_dwm_deps

# Instalacja yay + pacman packages
if [ "$DISTRO" = "arch" ]; then
    install_yay
    log "Instalacja pakietów z repozytoriów (pacman)..."
    install_repo_packages "${PACMAN_PACKAGES[@]}"
    check_success "Nie udało się zainstalować pakietów z pacman"

    log "Instalacja pakietów z AUR (yay)..."
    yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"
    check_success "Nie udało się zainstalować pakietów AUR"
else
    log "Instalacja pakietów..."
    install_repo_packages "${PACMAN_PACKAGES[@]}"
    check_success "Nie udało się zainstalować pakietów"
fi

log "Instalacja zakończona pomyślnie!"

# Klonowanie repozytorium
log "Klonowanie repozytorium dotfiles..."
if [ -d ~/.dotfiles ]; then
    read -p "Katalog ~/.dotfiles już istnieje. Czy chcesz go nadpisać? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf ~/.dotfiles
    else
        error "Anulowano. Katalog ~/.dotfiles już istnieje."
        exit 1
    fi
fi

git clone --depth 1 https://github.com/trebuhw/.dotfiles ~/.dotfiles
check_success "Nie udało się sklonować repozytorium"

# Tworzenie kopii zapasowych
log "Tworzenie kopii zapasowych plików konfiguracyjnych..."
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
[ -f ~/.bash_logout ] && mv ~/.bash_logout ~/.bash_logout.bak
[ -f ~/.bash_profile ] && mv ~/.bash_profile ~/.bash_profile.bak
[ -f ~/.gtkrc-2.0 ] && mv ~/.gtkrc-2.0 ~/.gtkrc-2.0.bak
[ -d ~/.config/gtk-2.0 ] && mv ~/.config/gtk-2.0 ~/gtk-2.0.bak
[ -d ~/.config/gtk-3.0 ] && mv ~/.config/gtk-3.0 ~/gtk-3.0.bak
[ -d ~/.config/gtk-4.0 ] && mv ~/.config/gtk-4.0 ~/gtk-4.0.bak

# Stow
log "Tworzenie symlinków za pomocą stow..."
cd ~/.dotfiles || { error "Nie można przejść do katalogu ~/.dotfiles"; exit 1; }
stow Xresources/ alacritty/ background/ bash/ btop/ dunst/ fish/ foot/ fonts/ gtk-2.0/ gtk-3.0/ gtk-4.0/ gtkrc-2.0/ hypr/ icons/ kitty/ mako/ mc/ mousepad/ nsxiv/ nvim/ qt5ct/ profile/ ranger/ rofi/ sublime-text/ swappy/ swaylock/ tldr/ themes/ thunar/ vim/ vscode/ waybar/ wezterm/ wlogout/ wofi/ wofifull/ xfce4/ yazi/ zathura/
check_success "Błąd podczas wykonywania stow"

# SDDM
[ -d ~/etc/sddm.conf.d ] && sudo mv /etc/sddm.conf.d/ /etc/sddm.conf.d.bak
sudo ln -sf ~/.dotfiles/etc/.config/sddm.conf.d /etc/sddm.conf.d
sudo ln -sf ~/.dotfiles/usr/share/sddm/themes/simple-sddm/ /usr/share/sddm/themes/simple-sddm/

# Dodanie czcionek
sudo fc-cache -fv

# Ustawienie theme gtk
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size 20 
gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Dark"
gsettings set org.gnome.desktop.wm.preferences theme "Catppuccin-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dracula-dark"
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10'
ln -sf ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# Ustawienie konfiguracji programów root
[ -d /root/.config ] && sudo mv /root/.config /root/.config.bak
sudo mkdir -p /root/.config/
sudo ln -sf ~/dotfiles/gtkrc-2.0/.gtkrc-2.0 /root/.gtkrc-2.0
sudo ln -sf ~/dotfiles/vim/.vimrc /root/.vimrc
sudo ln -sf ~/dotfiles/vim/.viminfo /root/.viminfo
sudo ln -sf ~/dotfiles/nvim/.config/nvim /root/.config/nvim
sudo ln -sf ~/dotfiles/mc/.config/mc /root/.config/mc
sudo ln -sf ~/dotfiles/gtk-4.0/.config/gtk-4.0 /root/.config/gtk-4.0
sudo ln -sf ~/dotfiles/gtk-3.0/.config/gtk-3.0 /root/.config/gtk-3.0
sudo ln -sf ~/dotfiles/gtk-2.0/.config/gtk-2.0 /root/.config/gtk-2.0
sudo ln -sf ~/dotfiles/ranger/.config/ranger /root/.config/ranger

# Wykonanie konfiguracji specyficznych dla danej dystrybucji
log "Wykonywanie konfiguracji specyficznych dla dystrybucji $DISTRO..."
case "$DISTRO" in
    arch)
        arch_specific_configs
        ;;
    ubuntu)
        ubuntu_specific_configs
        ;;
    debian)
        debian_specific_configs
        ;;
    fedora)
        fedora_specific_configs
        ;;
    opensuse)
        opensuse_specific_configs
        ;;
esac

# Pytanie o reboot
read -p "Czy chcesz teraz zrestartować system? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Restartuję system..."
    sudo systemctl reboot
fi

exit 0
