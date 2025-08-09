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
            sudo pacman -S --needed --noconfirm base-devel libx11 libxinerama libxft xorg xorg-server xorg-xinit
            ;;
        ubuntu|debian)
            log "Instalacja zależności DWM dla $DISTRO..."
            sudo apt update
            sudo apt install -y libharfbuzz-dev libxft-dev libpango1.0-dev build-essential \
                libx11-dev libxinerama-dev libxcb1-dev libxcb-keysyms1-dev libxcb-icccm4-dev \
                libx11-xcb-dev libxcb-util0-dev libxcb-randr0-dev suckless-tools libfreetype6-dev
            ;;
        fedora)
            log "Instalacja zależności DWM dla Fedora..."
            sudo dnf install -y @development-tools libX11-devel libXinerama-devel libXft-devel \
                xorg-x11-server-Xorg xorg-x11-xinit
            ;;
        opensuse)
            log "Instalacja zależności DWM dla openSUSE..."
            sudo sudo zypper --non-interactive install --no-recommends gcc harfbuzz-devel patterns-devel-base-devel_basis libX11-devel libXinerama-devel libXft-devel make \
                xorg-x11-server xinit
            ;;
    esac
    check_success "Nie udało się zainstalować zależności DWM"
}

# Pakiety wspólne (repozytoria oficjalne)
COMMON_PACKAGES=(
    bash-completion bat blueman brightnessctl btop cups curl dunst feh file-roller firefox fish fzf galculator gcc gcolor3 gnome-disk-utility gparted gsettings-desktop-schemas gzip htop i3lock kitty mako meld neovim numlockx p7zip parcellite pavucontrol pdfarranger picom ripgrep rofi rsync scrot stow sxhkd thunar thunar-archive-plugin thunar-volman time trash-cli tree tumbler unrar unzip vim vlc wget xclip xdg-user-dirs xfce4-notifyd zathura zoxide
    )

# Odpowiedniki i pakiety dodatkowe
case "$DISTRO" in
    arch)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" alacritty code eza fastfetch font-manager libreoffice-fresh libreoffice-fresh-pl polkit-gnome network-manager-applet nsxiv mlocate os-prober sddm starship tldr tlp qt5ct xf86-input-synaptics xf86-video-intel wezterm yazi)
        YAY_PACKAGES=(google-chrome lm_sensors nwg-look mkinitcpio-firmware moc-pulse simple-sddm-theme-git sublime-text-4 ueberzug waypaper)
        ;;
    ubuntu)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" alacritty eza fastfetch font-manager nwg-look policykit-1-gnome network-manager-gnome mlocate starship sxiv xserver-xorg-input-synaptics xserver-xorg-video-intel wezterm yazi)
        ;;
    debian)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" alacritty font-manager neofetch lxappearance policykit-1-gnome network-manager-gnome mlocate xserver-xorg-input-synaptics xserver-xorg-video-intel)
        ;;
    fedora)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" alacritty fastfetch lxappearance polkit network-manager-applet sxiv xorg-x11-drv-synaptics xorg-x11-drv-intel )
        ;;
    opensuse)
        PACMAN_PACKAGES=("${COMMON_PACKAGES[@]}" eza fastfetch font-manager lxappearance opi polkit-gnome NetworkManager-applet mlocate tealdeer qt5ct starship sxiv sensors ueberzugpp wezterm yazi zathura-plugin-pdf-mupdf azote cliphist grim hyprland hyprland hyprland-qtutils mako sddm slurp swaybg swaylock swappy waybar waybar wlogout wofi wofi xdg-desktop-portal-hyprland xhost wl-clipboard)
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
    sudo systemctl enable tlp
    
    # Konfiguracja pacman
    #log "Konfigurowanie pacman..."
    #if ! grep -q "Color" /etc/pacman.conf; then
    #    sudo sed -i 's/#Color/Color/' /etc/pacman.conf && success "Włączono kolorowe wyjście pacman."
    #fi
    #
    #if ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
    #    sudo sed -i '/\[options\]/a ParallelDownloads = 50' /etc/pacman.conf && success "Dodano ParallelDownloads = 50 do pacman.conf."
    #else
    #    sudo sed -i 's/^#*ParallelDownloads *= *.*/ParallelDownloads = 50/' /etc/pacman.conf && success "Ustawiono ParallelDownloads = 50 w #pacman.conf."
    #fi

    # Optymalizacja systemu
    log "Optymalizacja systemu Arch..."
    echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
    
    # Optymalizacja SSD (jeśli jest)
    if [ -d "/sys/block/sda/queue/rotational" ] && [ "$(cat /sys/block/sda/queue/rotational)" -eq 0 ]; then
        log "Wykryto SSD, optymalizacja..."
        echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-ssd.conf > /dev/null
        sudo systemctl enable fstrim.timer
    fi

    # Skopiowanie konfiguracji SDDM
    [ -d /usr/share/sddm/themes/simple-sddm ] && sudo mv /usr/share/sddm/themes/simple-sddm /usr/share/sddm/themes/simple-sddm.bak
    [ -f /etc/sddm.conf.d ] && sudo mv /etc/sddm.conf.d /etc/sddm.conf.d.bak
    sudo cp -rv ~/.dotfiles/usr/.config/usr/share/sddm/themes/simple-sddm /usr/share/sddm/themes/
    sudo cp -rv ~/.dotfiles/etc/.config/sddm.conf.d /etc
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

    # Włączanie i uruchamianie usług
    log "Konfiguracja usług systemowych..."
    sudo systemctl enable --now NetworkManager 
    sudo systemctl enable --now cups
    # sudo systemctl enable sddm
    sudo systemctl enable tlp

    # Wyłączenie lightdm 
    # sudo systemctl disable display-manager

    # Skopiowanie konfiguracji lightdm-display-manager
    [ -d /etc/lightdm ] && sudo mv /etc/lightdm /etc/lightdm.bak
    sudo cp -rv ~/.dotfiles/etc/.config/lightdm /etc


    
    # Zmiana powłoki shell (inaczej niż w innych dystrybucjach)
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh -s /usr/bin/fish $USER && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Zmiana hostname
    sudo hostnamectl set-hostname --static "tumbleweed"

    # Optymalizacja Zypper
    log "Optymalizacja Zypper..."
    sudo sed -i 's/# solver.onlyRequires = false/solver.onlyRequires = true/' /etc/zypp/zypp.conf
    
    # Zmiana koloru Yast2
    sudo sed -i 's/Y2NCURSES_COLOR_THEME="[^"]*"/Y2NCURSES_COLOR_THEME="rxvt"/' /etc/sysconfig/yast2

    # Skopiowanie konfiguracji SDDM
    [ -d /usr/share/sddm/themes/simple-sddm ] && sudo mv /usr/share/sddm/themes/simple-sddm /usr/share/sddm/themes/simple-sddm.bak
    sudo cp -rv ~/.dotfiles/usr/.config/usr/share/sddm/themes/simple-sddm /usr/share/sddm/themes/

    [ -f /etc/sddm.conf.d ] && sudo mv /etc/sddm.conf.d /etc/sddm.conf.d.bak
    sudo cp -rv ~/.dotfiles/etc/.config/sddm.conf.d /etc
    
    # instalacja programow z opi
    sudo opi google-chrome
    sudo opi sublime-text
    sudo opi waypaper
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
stow Xresources/ alacritty/ background/ bat/ bash/ bin/ btop/ dunst/ fish/ fonts/ gtk-2.0/ gtk-3.0/ gtk-4.0/ gtkrc-2.0/ hypr/ icons/ kitty/ mako/ mc/ nvim/ nsxiv/ parcellite/ qt5ct/ ranger/ rofi/ starship/ suckless/ sublime-text/ themes/ thunar/ tldr/ sxiv/ swappy/ swaylock/ vim/ xfce4/ xinitrc/ xprofile/ yazi/ waybar/ wezterm/ wlogout/ wofi/ zathura/
check_success "Błąd podczas wykonywania stow"

# Kompilacja i instalacja DWM
log "Kompilacja i instalacja DWM..."
cd ~/.config/suckless/dwm || { error "Nie można przejść do katalogu DWM"; exit 1; }
[ -f config.h ] && rm config.h
sudo make && sudo make clean install && rm -f config.h
check_success "Błąd podczas kompilacji DWM"

# Kompilacja i instalacja DMENU
log "Kompilacja i instalacja DMENU..."
cd ~/.config/suckless/dmenu || { error "Nie można przejść do katalogu DMENU"; exit 1; }
[ -f config.h ] && rm config.h
sudo make && sudo make clean install && rm -f config.h
check_success "Błąd podczas kompilacji DMENU"

# Kompilacja i instalacja slstatus
log "Kompilacja i instalacja slstatus..."
cd ~/.config/suckless/slstatus || { error "Nie można przejść do katalogu slstatus"; exit 1; }
[ -f config.h ] && rm config.h
sudo make && sudo make clean install && rm -f config.h
check_success "Błąd podczas kompilacji slstatus"

# Kompilacja i instalacja st
log "Kompilacja i instalacja st (terminal)..."
cd ~/.config/suckless/st || { error "Nie można przejść do katalogu st"; exit 1; }
sudo make && sudo make clean install
check_success "Błąd podczas kompilacji st"

# Instalacja pliku .desktop
log "Kopiowanie pliku .desktop..."
[ -d /usr/share/xsessions ] || sudo mkdir -p /usr/share/xsessions
sudo cp ~/.config/suckless/usr/share/xsessions/dwm.desktop /usr/share/xsessions/
check_success "Nie udało się skopiować pliku .desktop"

# Instalacja pliku start-dwm.sh uruchamiającego slstatus w autostarcie w GDM i SDDM
[ -d /usr/local/bin ] || sudo mkdir -p /usr/local/bin
sudo cp ~/.config/suckless/usr/local/bin/start-dwm.sh /usr/local/bin/

log "Instalacja zakończona pomyślnie!"
log "Aby uruchomić DWM, wyloguj się i wybierz sesję DWM z menedżera logowania."

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

# TLP
[ -f /etc/tlp.conf ] && sudo mv /etc/tlp.conf /etc/tlp.conf.back
sudo ln -sf ~/.dotfiles/etc/.config/tlp.conf

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
