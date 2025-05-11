### EXPORT ###
export EDITOR='nvim'
export VISUAL='nvim'
export HISTCONTROL=ignoreboth:erasedups
export PAGER='most'
export MICRO_TRUECOLOR=1
export TERM=xterm-256color

#Starship config
#export STARSHIP_CONFIG=~/.config/starship-bash.toml
#eval "$(starship init bash)"
#Ibus settings if you need them
#type ibus-setup in terminal to change settings and start the daemon
#delete the hashtags of the next lines and restart
#export GTK_IM_MODULE=ibus
#export XMODIFIERS=@im=dbus
#export QT_IM_MODULE=ibus

#PS1='[\u@\h \W]\$ '
PS1='\[\e[1;31m\][\[\e[1;33m\]\u\[\e[1;32m\]@\[\e[1;34m\]\h \[\e[1;35m\]\w\[\e[1;31m\]]\[\e[1;00m\]\$\[\e[0;00m\] '


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


if [ -d "$HOME/.bin" ] ;
  then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/usr/local/share/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.config/hypr/scripts" ] ;
  then PATH="$HOME/.config/hypr/scripts:$PATH"
fi

if [ -d "$HOME/.config/dwm/scripts" ] ;
  then PATH="$HOME/.config/dwm/scripts:$PATH"
fi

if [ -d "$HOME/.config/dwm/scripts" ] ;
  then PATH="$HOME/.config/suckless/scripts:$PATH"
fi

# include .bashrc if it exists
if [ -f $HOME/.config/fish/alias.fish ]; then
    . $HOME/.config/fish/alias.fish
fi

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# zoxide bind 
bind '"\C-f":"zi\n"'

# alias clonowania z Git po ssh wpisać tylko nazwę repo czyli to co:
function gcs() {
    local repo=$1
    git clone --depth=1 git@github.com:$repo
}


### ALIASES ###
source $HOME/.dotfiles/fish/.config/fish/alias.fish

