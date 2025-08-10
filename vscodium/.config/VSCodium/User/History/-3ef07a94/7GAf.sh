#!/usr/bin/env bash

# Definicja zmiennej - użyj jednej z opcji
packer="yay"
# packer="paru"

echo "Instalacja programów..."
$packer -S --noconfirm --needed bat
$packer -S --noconfirm --needed btop 
$packer -S --noconfirm --needed eza
$packer -S --noconfirm --needed fish
$packer -S --noconfirm --needed konsole
$packer -S --noconfirm --needed pcloud-drive
$packer -S --noconfirm --needed starship
$packer -S --noconfirm --needed stow
$packer -S --noconfirm --needed tldr
$packer -S --noconfirm --needed trash-cli
$packer -S --noconfirm --needed yazi
$packer -S --noconfirm --needed zoxide

echo "Kopiowanie repozytorium .dotfiles..."
# Poprawiono URL - brakowało ://
git clone --depth=1 https://github.com/trebuhw/.dotfiles.git ~/.dotfiles
git clone --depth=1 https://github.com/trebuhw/.hydedots.git ~/.hydedots

echo "Usuwanie i kopiowanie plików..."
# Dodano sprawdzenie istnienia plików przed usunięciem
[ -f ~/.config/fastfetch/config.jsonc ] && rm ~/.config/fastfetch/config.jsonc
[ -f ~/.config/fish/user.fish ] && rm ~/.config/fish/user.fish
[ -f ~/.local/lib/hyde/theme.switch.sh ] && rm ~/.local/lib/hyde/theme.switch.sh
[ -f ~/.local/share/hyde/hyprland.conf ] && rm ~/.local/share/hyde/hyprland.conf
[ -f ~/.local/share/waybar/modules/clock.jsonc ] && rm ~/.local/share/waybar/modules/clock.jsonc
[ -f ~/.config/hypr/keybindings.conf ] && rm ~/.config/hypr/keybindings.conf
[ -f ~/.config/kitty/kitty.conf ] && rm ~/.config/kitty/kitty.conf
[ -f ~/.config/starship/starship.toml ] && rm ~/.config/starship/starship.toml
[ -d ~/.vscode-oss ] && rm -rf ~/.vscode-oss
[ -f ~/.config/waybar/user-style.css ] && rm ~/.config/waybar/user-style.css

echo "Kopiowanie plików..."
# Tworzenie katalogów docelowych jeśli nie istnieją
mkdir -p ~/.config/fastfetch ~/.config/fish ~/.local/lib/hyde ~/.local/share/hyde ~/.local/share/waybar/modules ~/.config/hypr ~/.config/kitty ~/.config/starship ~/.config/waybar

cp ~/.hydedots/fastfetch/.config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
cp ~/.hydedots/fish/.config/fish/user.fish ~/.config/fish/user.fish
cp ~/.hydedots/hydelocal/.local/lib/hyde/theme.switch.sh ~/.local/lib/hyde/theme.switch.sh
cp ~/.hydedots/hydelocal/.local/share/hyde/hyprland.conf ~/.local/share/hyde/hyprland.conf
cp ~/.hydedots/hydelocal/.local/share/waybar/layouts/* ~/.local/share/waybar/layouts/
cp ~/.hydedots/hydelocal/.local/share/waybar/modules/clock.jsonc ~/.local/share/waybar/modules/clock.jsonc
cp ~/.hydedots/hypr/.config/hypr/keybindings.conf ~/.config/hypr/keybindings.conf
cp ~/.hydedots/kitty/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp ~/.hydedots/starship/.config/starship/starship.toml ~/.config/starship/starship.toml
cp -r ~/.hydedots/vscode/.vscode-oss ~/.vscode-oss
cp ~/.hydedots/waybar/.config/waybar/user-style.css ~/.config/waybar/user-style.css

echo "Linkowanie - stow plików konfiguracyjnych z .dotfiles"
cd ~/.dotfiles && stow bat/ btop/ bin/ eza/ lazynvim/ starship/ yazi/

echo "Instalacja zakończona!"