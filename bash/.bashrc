### EXPORT ###
export EDITOR='nvim'
export VISUAL='nvim'
export HISTCONTROL=ignoreboth:erasedups
export PAGER='most'
export MICRO_TRUECOLOR=1
export TERM=xterm-256color

#Starship config
export STARSHIP_CONFIG=~/.config/starship-bash.toml
eval "$(starship init bash)"
#Ibus settings if you need them
#type ibus-setup in terminal to change settings and start the daemon
#delete the hashtags of the next lines and restart
#export GTK_IM_MODULE=ibus
#export XMODIFIERS=@im=dbus
#export QT_IM_MODULE=ibus

PS1='[\u@\h \W]\$ '

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

### ALIASES ###

#list
alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -alFh'
alias l='ls'
alias l.="ls -A | egrep '^\.'"
alias listdir="ls -d */ > list"

alias df='df -h'
alias free="free -mt"
alias update-fc='sudo fc-cache -fv'
alias hw="hwinfo --short"
alias wget="wget -c"
alias userlist="cut -d: -f1 /etc/passwd | sort"
alias ws="watch sensors"
alias ns="nvidia-smi"
alias btinfo="bluetoothctl info"
alias br='sudo systemctl restart bluetooth'

#fix obvious typo's
alias cd..='cd ..'
alias wal='cd $HOME/Obrazy/Wallpaper && ls'
alias cp='cp -riv'
alias mv='mv -iv'
alias rm="trash-put -v" # trash-cli przenosi pliki do kosza
alias tl="trash-list" # lista plików w koszu
alias te='trash-empty' #opróżnianie kosza
alias tr='trash-restore' #przywracanie plików z kosza
alias trm='trash-rm' #usówa pojedyńcze pliki z kosza
#alias rm='rm -rdv' # usówa pliki całkowicie 
alias mkdir='mkdir -vp'
alias pdw='pwd'
alias up='sudo zypper update'
alias dup='sudo zypper dist-upgrade'
alias zin='sudo zypper install'
alias zrm='sudo zypper remove -u'
alias zse='sudo zypper search'
alias zsi='zypper search -i' # show installed Packages
alias zre='sudo zypper repos'
alias zrr='sudo zypper rr' #removerepo, rr - Usuwanie wybranego repozytorium

alias tldr='tldr -t ocean'

alias find='find -name'
alias locate='locate -b'


alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias riplong="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -3000 | nl"

#iso and version used to install ArcoLinux
alias iso="cat /etc/dev-rel | awk -F '=' '/ISO/ {print $2}'"
alias isoo="cat /etc/dev-rel"

#search content with ripgrep
alias rg="rg --sort path"

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

#know what you do in these files
alias ngrub="sudo $EDITOR /etc/default/grub"
alias nconfgrub="sudo $EDITOR /boot/grub/grub.cfg"
alias nmkinitcpio="sudo $EDITOR /etc/mkinitcpio.conf"
alias nfstab="sudo $EDITOR /etc/fstab"
alias nhosts="sudo $EDITOR /etc/hosts"
alias nhostname="sudo $EDITOR /etc/hostname"

#reading logs with bat
alias lxorg="bat /var/log/Xorg.0.log"
alias lxorgo="bat /var/log/Xorg.0.log.old"

#systeminfo
alias probe="sudo -E hw-probe -all -upload"
alias sysfailed="systemctl list-units --failed"

# Moje aliasy
alias v='nvim'
alias nv='nvim'
alias vim='vim'
alias ffa='$HOME/.config/scripts/fzf-run-app.sh'
alias ffc='$HOME/.config/scripts/fzf-config.sh'
alias ffl='$HOME/.config/scripts/fzf-import-rofi.sh'
alias ffd='$HOME/.config/scripts/fzf-run-dir-scripts.sh'
alias ffr='$HOME/.config/scripts/fzf_speed/run/fzf-run.sh'
alias ffe='$HOME/.config/scripts/fzf_speed/edit/fzf-edit.sh'
alias ffes='$HOME/.config/scripts/fzf-scripts.sh'
alias ffcp='cliphist list | fzf | cliphist decode | wl-copy'
alias i30='nvim $HOME/Dokumenty/"i30_info.txt"'
alias nf='neofetch'
alias wi='xprop'
alias bg='sxiv -t $HOME/Obrazy/Wallpaper/'
alias sbg='cd $HOME/Obrazy/Wallpaper && sxiv'
alias e="exit"
alias po="sudo poweroff"
alias rb="sudo reboot"
alias rh="hyprctl dispatch exit"
alias r='ranger'
alias rs='ranger --confdir=$HOME/.config/ranger.st/'
alias b="btop"
alias c="cal -y"
alias pcinfo="inxi -Fxz"
alias nm="nmtui"
alias nt='SpeedTest++'
alias hnt='cd $HOME/.config/scripts&&./fast'
alias wcolor="$HOME/.config/scripts/grim-gcolor.sh"
alias cis="$HOME/.config/scripts/grim-copyimg.sh"
alias cl="clear"
alias ag="alias | grep"
alias hg='history | grep '
alias pogoda='curl wttr.in/Swidnica'
alias pp='pacman -Qqet' # pacman - zainstalowane pakiety
alias pq='pacman -Q' # pacman - zainstalowane programy
alias oi="grep -i installed /var/log/pacman.log"
alias uo='pacman -Rsn $(pacman -Qdtq)' # usówanie osieroconych pakietów
alias app='hyprctl clients' # class i id window
alias rk='du -sh *'
alias mpdf='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=' # Merge pdf. Podać nazwa po połączeniu potem nazwy złączanych plików.
alias sddmb='sudo cp $HOME/.background.jpg /usr/share/sddm/themes/arcolinux-simplicity/images/background.jpg'
alias picker='hyprpicker -an'
alias cc='rm /home/hubert/.cache/cliphist/db' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
#alias cc='cliphist wipe && rm /home/hubert/.cache/cliphist/db' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias cbwipe='cliphist wipe' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias cbdel='rm /home/hubert/.cache/cliphist/db' # Cliphist usunięcie  bazy - numeracja skopiowanych będzię kontynuowana od nowa
alias umount='sudo umount -dflnrv' # Podaj ścieżkę zamontowanego katalogu
alias mocp='mocp -C $HOME/.config/moc/config.example'
alias ff='fastfetch'
alias hc='nvim ~/.config/hypr/hyprland.conf'
alias fa='nvim ~/.config/fish/alias.fish'
alias exp='~/.config/hypr/scripts/export-archiv'
alias cdh='cd ~/ && ls'
alias cdcl='cd ~/Cloud/ && ls'
alias cdd='cd ~/Dokumenty/ && ls'
alias cdo='cd ~/Obrazy/ && ls'
alias cdp='cd ~/Pobrane/ && ls'
alias cdc='cd ~/.config && ls'
alias cddw='cd ~/.config/suckless/dwm/ && ll'
alias cds='cd ~/.config/suckless/ && ll'
alias cdbg='cd ~/.config/dwm/bg/ && ls'
alias cdf='cd ~/.config/fish/ && ls'
alias cdss='cd ~/.config/suckless/scripts/ && ll'
alias cdhs='cd ~/.config/hypr/scripts/ && ll'
alias brc='nvim ~/bashrc'
alias ptt='pdftotext -layout'
alias backup='~/.config/suckless/scripts/rsync-backup.sh'
alias mpdf='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=' # Merge pdf. Podać nazwa po połączeniu potem nazwy złączanych plików.

alias gb='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # git --bare
alias gbs='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status'
alias gba='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add '
alias gbr='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME rm -r --cached '
alias gbc='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME commit -am '
alias gbp='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push '

# Aliases rsync
alias sync='rsync -rlpva --delete'
alias synchypr='rsync -rlpva --delete ~/.config/hypr/ ~/Dokumenty/GitHub/hypr/' #rsync hypr config to GIT repos
eval "$(zoxide init bash)"
