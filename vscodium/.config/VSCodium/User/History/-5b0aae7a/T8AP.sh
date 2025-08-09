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
if [ -f /etc/lsb-release ]; then
    DISTRO="Artix"
    log "Wykryto dystrybucję: Artix Linux"
else
    error "Nieobsługiwana dystrybucja. Skrypt obsługuje tylko Artix Linux."
    exit 1
fi

# Instalacja yay
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
    log "Instalacja zależności DWM dla Artix Linux..."
    sudo pacman -S --needed --noconfirm base-devel libx11 libxinerama libxft xorg xorg-server xorg-xinit
    check_success "Nie udało się zainstalować zależności DWM"
}

# Pakiety dla Artix
PACMAN_PACKAGES=(
    alacritty bash-completion blueman brightnessctl btop curl dunst fastfetch feh file-roller firefox font-manager fzf galculator gcc gnome-disk-utility gparted gsettings-desktop-schemas gzip htop i3lock libreoffice-fresh libreoffice-fresh-pl meld neovim networkmanager networkmanager-runit network-manager-applet nsxiv numlockx p7zip pavucontrol picom plocate polkit-gnome ripgrep rofi rsync scrot sddm stow sxhkd thunar thunar-archive-plugin thunar-volman time tldr tlp qt5ct tree tumbler unrar unzip vim vlc wezterm wget xclip xdg-user-dirs xfce4-notifyd yazi zathura 
    )
YAY_PACKAGES=(
    eza google-chrome lm_sensors nwg-look sublime-text-4 trash-cli zoxide
    )

# Instalacja pakietów z repozytoriów
install_repo_packages() {
    local pkgs=("$@")
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

# Konfiguracje specyficzne dla Artix
artix_specific_configs() {
    log "Wykonywanie konfiguracji specyficznych dla Artix Linux..."

    # Włączanie i uruchamianie usług z runit
    log "Konfiguracja usług systemowych z runit..."
    # sudo ln -s /etc/runit/sv/NetworkManager /run/runit/service/
    # sudo ln -s /etc/runit/sv/cupsd /run/runit/service/
    # sudo ln -s /etc/runit/sv/sddm /run/runit/service/
    #sudo ln -s /etc/runit/sv/tlp /run/runit/service/

    # Zmiana powłoki shell
    if command -v fish &> /dev/null; then
        log "Zmiana powłoki na fish..."
        sudo chsh $USER -s /bin/fish && success "Powłoka zmieniona na fish. Wyloguj się, aby zastosować zmiany."
    fi
    
    # Instalacja starship
    curl -sS https://starship.rs/install.sh | sh
}

# Wykonywanie głównego kodu skryptu
install_dwm_deps
install_yay
log "Instalacja pakietów z repozytoriów (pacman)..."
install_repo_packages "${PACMAN_PACKAGES[@]}"
check_success "Nie udało się zainstalować pakietów z pacman"

log "Instalacja pakietów z AUR (yay)..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"
check_success "Nie udało się zainstalować pakietów AUR"

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
[ -f ~/.gtkrc-2.0 ] && mv ~/.gtkrc-2.0 ~/.gtkrc-2.0.bak
[ -d ~/.config/gtk-2.0 ] && mv ~/.config/gtk-2.0 ~/gtk-2.0.bak
[ -d ~/.config/gtk-3.0 ] && mv ~/.config/gtk-3.0 ~/gtk-3.0.bak
[ -d ~/.config/gtk-4.0 ] && mv ~/.config/gtk-4.0 ~/gtk-4.0.bak

# Stow
log "Tworzenie symlinków za pomocą stow..."
cd ~/.dotfiles || { error "Nie można przejść do katalogu ~/.dotfiles"; exit 1; }
stow Xresources/ alacritty/ background/ bin/ btop/ dunst/ fish/ fonts/ gtk-2.0/ gtk-3.0/ gtk-4.0/ gtkrc-2.0/ icons/ nvim/ nsxiv/ qt5ct/ rofi/ suckless/ sublime-text/ themes/ thunar/ tldr/ sxiv/ starship/ swappy/ vim/ xfce4/ xinitrc/ xprofile/ yazi/ waybar/ wezterm/ zathura/
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

# Instalacja pliku start-dwm.sh
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

# Wykonanie konfiguracji specyficznych dla Artix
log "Wykonywanie konfiguracji specyficznych dla Artix..."
artix_specific_configs

# Pytanie o reboot
read -p "Czy chcesz teraz zrestartować system? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Restartuję system..."
    sudo reboot
fi

exit 0