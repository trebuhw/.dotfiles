# **GNU STOW - .dotfiles**

## Install stow

`sudo pacman -S stow`

## Clone repozytory .dotfiles

`cd ~/`

`git clone --depth=1 https://github.com/trebuhw/.dotfiles.git`

## Usage stow

`cd ~/.dotfiles/`

`stow .` -> _( all ln -s link .dotfiles to ~/.config)_

or

np: `stow kitty/` -> _( ln -as link .dotfiles to ~/.config/kitty )_
