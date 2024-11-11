if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting
starship init fish | source
set -gx EDITOR nvim
set -gx QT_QPA_PLATFORMTHEMEgnome
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -gx PATH $PATH ~/.local/bin
fish_add_path /usr/bin
fish_add_path /opt/nbfc
fish_add_path ~/.local/bin
fish_add_path ~/usr/local/share/bin
fish_add_path ~/.config/hypr/scripts
fish_add_path ~/.config/suckless/scripts
export "MICRO_TRUECOLOR=1"

# Dracula FZF color 

#set -Ux FZF_DEFAULT_OPTS "\
  #--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
  #--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
  #--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
  #--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# Catppucin Mocha FZF color

set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# fish_config theme save "Catppuccin Mocha" # Unhash jednorazowo potem zahaszofać z powrotem

### ALIASES ###

# Aliases
if [ -f $HOME/.config/fish/alias.fish ]
source $HOME/.config/fish/alias.fish

zoxide init fish | source

end
