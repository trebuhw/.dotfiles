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
cp ~/.hydedots/hydelocal/ ~/.local/lib/hyde/theme.switch.sh
cp ~/.hydedots/ ~/.local/share/hyde/hyprland.conf
cp ~/.hydedots/ ~/.local/share/waybar/modules/clock.jsonc
cp ~/.hydedots/ ~/.config/hypr/keybindings.conf
cp ~/.hydedots/ ~/.config/kitty/kity.conf
cp ~/.hydedots/ ~/.config/starship/starship.toml
cp ~/.hydedots/ ~/.vscode-oss
cp ~/.hydedots/ ~/.config/waybar/user-style.css







# Klonowanie
#.dotfiles
cd ~/
git clone --depth=1 https:github.com/trebuhw/.dotfiles.git &
#.hydedots
cd ~/
git clone --depth=1 https://github.com/trebuhw/.hydedots.git &

# stow
cd ~/.dotfiles
stow bat/ btop/ bin/ eza/ starship/ yazi/ &
cd ~/.hydedots
stow fastfetch/ fish/ hydelocal/ hypr/ kitty/ starship/ vscode/ waybar/
