#!/usr/bin/env bash

echo "Instalacja programów..."
yay -S --noconfirm --needed bat
yay -S --noconfirm --needed btop 
yay -S --noconfirm --needed eza
yay -S --noconfirm --needed fish
yay -S --noconfirm --needed konsole
yay -S --noconfirm --needed pcloud-drive
yay -S --noconfirm --needed starship
yay -S --noconfirm --needed stow
yay -S --noconfirm --needed tldr
yay -S --noconfirm --needed trash-cli
yay -S --noconfirm --needed yazi
yay -S --noconfirm --needed zoxide

echo "Kopiowanie repozytorium .dotfiles..."
git clone --depth=1 https:github.com/trebuhw/.dotfiles.git ~/.dotfiles
git clone --depth=1 https://github.com/trebuhw/.hydedots.git ~/.hydedots

echo "Usuwanie i kopiowanie plików..."
rm ~/.config/fastfetch/config.jsonc
rm ~/.config/fish/user.fish
rm ~/.local/lib/hyde/theme.switch.sh
rm ~/.local/share/hyde/hyprland.conf
rm ~/.local/share/waybar/modules/clock.jsonc
rm ~/.config/hypr/keybindings.conf
rm ~/.config/kitty/kity.conf
rm ~/.config/starship/starship.toml
rm ~/.vscode-oss
rm ~/.config/waybar/user-style.css

echo "Kopiowanie plików..."
cp ~/.hydedots/fastfetch/.config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
cp ~/.hydedots/fish/.config/fish/user.fish ~/.config/fish/user.fish
cp ~/.hydedots/hydelocal/.local/lib/hyde/theme.switch.sh ~/.local/lib/hyde/theme.switch.sh
cp ~/.hydedots/hydelocal/.local/share/hyde/hyprland.conf ~/.local/share/hyde/hyprland.conf
cp ~/.hydedots/hydelocal/.local/share/waybar/layouts/* ~/.local/share/waybar/layouts/
cp ~/.hydedots/hydelocal/.local/share/waybar/modules/clock.jsonc~/.local/share/waybar/modules/clock.jsonc
cp ~/.hydedots/hypr/.config/hypr/keybindings.conf ~/.config/hypr/keybindings.conf
cp ~/.hydedots/kitty/.config/kitty/kity.conf ~/.config/kitty/kity.conf
cp ~/.hydedots//starship/config/starship/starship.toml ~/.config/starship/starship.toml
cp ~/.hydedots/vscode/.vscode-oss ~/.vscode-oss
cp ~/.hydedots/waybar/.config/waybar/user-style.css ~/.config/waybar/user-style.css

echo "Linkowanie - stow plków konfiguracyjnych z .dotfiles"
cd ~/.dotfiles; stow bat/ btop/ bin/ eza/ lazynvim/ starship/ yazi/

echo "Instalacja zakończona!"

