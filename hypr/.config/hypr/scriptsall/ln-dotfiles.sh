#!/usr/bin/env bash

# Symbolic link - config files is .dotfiles

ln -s ~/Dokumenty/GitHub/.dotfiles/.bash.rc ~/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.vimrc ~/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.Xresources ~/ &

ln -s ~/Dokumenty/GitHub/.dotfiles/.config/alacritty ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/btop ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/Code ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/dunst ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/fish ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/gtk-2.0 ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/gtk-3.0 ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/gtk-4.0 ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/hypr ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/kitty ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/lsd ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/mc ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/moc ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/neofetch ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/ranger ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/rolfi ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/sxiv ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/zathura ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/mimieapps.list ~/.config/ &
ln -s ~/Dokumenty/GitHub/.dotfiles/.config/starship.toml ~/.config/ &

exit 0
