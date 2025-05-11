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

#list
#list
# alias ls='lsd --group-directories-first --color=auto -1'
# alias la='lsd -a --group-directories-first'
# alias ll='lsd -al --group-directories-first'
# alias l='lsd -a --group-directories-first -1'
# alias lt='lsd --tree --group-directories-first'
# alias l.="lsd -A --group-directories-first | egrep '^\.'"

# List Directory
alias l='eza -la -1 --group-directories-first  --icons=auto' # long list
alias la='eza -a --group-directories-first --icons=auto' # long list
alias ls='eza -1 --group-directories-first --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

alias tree='tree -aCsh --du --sort name'
alias df='df -h'
alias free="free -mt"
alias update-fc='sudo fc-cache -fv'
alias hw="hwinfo --short"
alias wget="wget -c"
alias userlist="cut -d: -f1 /etc/passwd | sort"
alias ws="watch sensors"
alias ns="nvidia-smi"
alias bt='blueman-adapters'
alias nma='nm-applet'
alias br='sudo systemctl restart bluetooth'
alias btinfo="bluetoothctl info"
alias think="bluetoothctl info | awk '/Name:/ || /Battery Percentage:/' | bat "
alias logout='pkill -KILL -u hubert'
alias vs='amixer sset "Master" ' #podać X%
alias bs='brightnessctl set' # podać X%
alias vs4='amixer sset "Master" 40%' #ustawia volume na 40%
alias bs3='brightnessctl set 30%' # ustawia brightness na 30%
alias bi='brightnessctl i'
alias am='alsamixer'

#fix obvious typo's
alias cd..='cd ..'
alias cp='cp -riv'
alias mv='mv -iv'
alias rm="trash-put -rfv" # trash-cli przenosi pliki do kosza
alias tl="trash-list" # lista plików w koszu
alias te='trash-empty' #opróżnianie kosza
alias tr='trash-restore' #przywracanie plików z kosza
alias trm='trash-rm' #usówa pojedyńcze pliki z kosza
#alias rm='rm -rdv' # usówa pliki całkowicie 
alias mkdir='mkdir -vp'
alias pdw='pwd'

# zypper
alias zyp='sudo zypper'
alias zup='sudo zypper refresh && sudo zypper update && sudo zypper dist-upgrade'
alias zdup='sudo zypper refresh && sudo zypper dist-upgrade'
alias zin='sudo zypper install --no-recommends'
alias zrm='sudo zypper remove -u'
alias zse='sudo zypper search'
alias zsi='zypper search -i' # show installed Packages
alias zre='sudo zypper repos'
alias zrf='sudo zypper refresh'
alias zdr='sudo zypper mr -d' #disablerepo, dr - Wyłączenie wybranego repozytorium podać nazwę
alias zer='sudo zypper mr -e' #removerepo, er - Włączenie wybranego repozytorium podać nazwę
alias zrr='sudo zypper rr' #removerepo, rr - Usuwanie wybranego repozytorium
alias zcd='sudo zypper packages --unneeded' # Usówanie osieroconych pakietów
alias zcl='sudo zypper clean --all' # Clean repo, key repo, cache

# Snapper
alias ssl='sudo snapper list'
alias ssd='sudo snapper -c root delete --sync ' # usówanie migawek podać numer np. 55 lub przedział np. 55-65
alias ssc='sudo snapper create --desc ' # podać opis np. "231227 UPDATE OS QEMU "
alias ssr='sudo snapper rollback' # Polecenie wydawane tylko w momencie kiedy system uruchomiony jest z migawki do przywrócenia
alias ssba='sudo btrfs-assistant' # Graficzne narzedzie snappera
alias ssg='sudo snapper-gui' # Graficzne narzędie snapper

## Tldr
# alias tldr='tldr -t ocean'
# alias tldr='tldr --color always' # Install OpenSuse tealdeer run tldr -h

## Search
alias find='find -name'
alias locate='locate -b'

## Shel change
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /usr/bin/fish && echo 'Now log out.'"

## Mount ntfs
alias mntfs='sudo mount -t ntfs-3g -o uid=hubert,gid=hubert ' # /dev/sdX1 /ścieżka/do/montażu

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
alias upgrub="grub-mkconfig -o /boot/grub/grub.cfg"
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
alias nv='nvim'
alias mi='/home/hubert/.config/suckless/scripts/make-install.sh'
alias fzf='fzf --preview "bat --color=always {}"'
alias fe='$HOME/.local/bin/fzf-nvim.sh'
alias fel='$HOME/.local/bin/fzf-nvim.sh $(pwd)/'
alias ffcp='cliphist list | fzf | cliphist decode | wl-copy'
alias ddm='if=/dev/sr0 of=cd.iso bs=4M status=progress' # cd.iso tworzy się w bierzącym katalogu
alias nbfcc='cd /opt/nbfc/Configs && ll'
alias nbfce='sudo nvim /opt/nbfc/Configs/Dell\ Vostro\ 7580.xml'
alias hwi='hyprprop' # hyprland wayland, info run program
alias app='hyprctl clients' # class i id window
alias wi='xprop' # info run program
alias wg='xwininfo' # geometry winows
alias bg='sxiv -t $HOME/Obrazy/Wallpaper/'
alias sbg='cd $HOME/Obrazy/Wallpaper && sxiv'
alias e="exit"
alias po="systemctl poweroff"
alias rb="systemctl reboot"
alias rh="hyprctl dispatch exit"
alias r='ranger'
alias rd='~/.config/suckless/scripts/ranger.sh'
alias y='yazi'
alias rs='ranger --confdir=$HOME/.config/ranger.st/'
alias sd='lpq' # ststus drukarki
alias b="btop"
alias c="cal -y"
alias pcinfo="inxi -Fxz"
alias batery='upower -i $(upower -e | grep battery)'
alias nm="nmtui"
alias nma='nm-applet'
alias nmap='nmap -sn 192.168.0.1/24'
alias nmarp='arp-scan --interface=wlan0 192.168.0.1/24' # skanowanie sieci lokalnej
alias nmdis='sudo netdiscover -r 192.168.0.1/24'
# alias nt='speedtest-cli'
alias nt='speedtest' # Ookla speedtest > paru ookla-speedtest-bin
alias dns='systemd-resolve --status' # Ookla speedtest > paru ookla-speedtest-bin
alias wcolor="$HOME/.config/scripts/grim-gcolor.sh"
alias cis="$HOME/.config/scripts/grim-copyimg.sh"
alias cl="clear"
alias ag="alias | grep"
alias hg='history | grep '
alias pogoda='curl wttr.in/Swidnica'
alias paru='paru --bottomup'
alias dup='yay -Syyu'
alias up='sudo pacman -Syyu'
alias spi='sudo pacman -S --needed'
alias sps='pacman -Ss'
alias pq='pacman -Q'
alias pqe='pacman -Qe' # zainstalowane programy bez zależności i bibliotek
alias pqi='pacman -Qei | grep' # zainstalowany program info
alias spr='sudo pacman -Rns '
alias spu='sudo pacman -Syyu'
alias yup='yay -Syyu'
alias pp='pacman -Qqet' # pacman - zainstalowane pakiety
alias pq='pacman -Q' # pacman - zainstalowane programy
alias oi="grep -i installed /var/log/pacman.log | bat"
alias oiw="$HOME/.config/hypr/scripts/ostatnie-instalacje-wieksze.sh"
alias oim="$HOME/.config/hypr/scripts/ostatnie-instalacje-mniejsze.sh"
alias oip="$HOME/.config/hypr/scripts/ostatnie-instalacje-od-do.sh"
alias oiz="$HOME/.config/hypr/scripts/ostatnie-instalacje-z-dnia.sh"
alias uo='pacman -Rsn $(pacman -Qdtq)' # usówanie osieroconych pakietów
alias power='powerprofilesctl' # Zarządzani power pc systemctl enable/start power-profiles-daemon.service
alias rk='du -sh *'
alias mpdf='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=' # Merge pdf. Podać nazwa po połączeniu potem nazwy złączanych plików.
alias sddmb='sudo cp $HOME/.background.jpg /usr/share/sddm/themess/arcolinux-simplicity/images/background.jpg'
alias picker='hyprpicker -an'
alias cc='rm /home/hubert/.cache/cliphist/db' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias chwipe='cliphist wipe' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias chdel='rm /home/hubert/.cache/cliphist/db' # Cliphist usunięcie  bazy - numeracja skopiowanych będzię kontynuowana od nowa
alias umount='sudo umount -dflnrv' # Podaj ścieżkę zamontowanego katalogu
alias mocp='mocp -C $HOME/.moc/config'
alias ytd='yt-dlp --extract-audio --audio-format mp3 --audio-quality 0'
alias ff='fastfetch'
alias ffm='fastfetch -c $HOME/.dotfiles/fastfetch/.config/fastfetch/config.jsonc'
alias ffn='fastfetch -l none'
alias td='sudo hdparm -t' # test prędkości dysku użycie sudo hdparm -t /dev/sda
alias hom='cd ~/ && la'
alias dok='cd ~/Dokumenty/ && ls'
alias n='cd ~/Dokumenty/Notes/ && l'
alias ghu='cd ~/Dokumenty/GitHub/ && ls'
alias obr='cd ~/Obrazy/ && ls'
alias muz='cd ~/Muzyka/ && ls'
alias pob='cd ~/Pobrane/ && ls'
alias arc='cd ~/Archiwum/ && ls'
alias dro='cd ~/Dropbox/ && ls'
alias pcd='cd ~/pCloudDrive/ && ls'
alias pno='cd ~/pCloudDrive/Notes/ && ls'
alias dot='cd ~/.dotfiles/ && la'
alias con='cd ~/.config && ls'
alias hyp='cd ~/.config/hypr/ && ls'
alias fis='cd ~/.config/fish/ && ls'
alias dwm='cd ~/.config/suckless/dwm/ && ls'
alias suc='cd ~/.config/suckless/ && ls'
alias dbg='cd ~/.config/dwm/bg/ && ls'
alias dsc='cd ~/.config/suckless/scripts/ && ls'
alias scr='cd ~/.config/hypr/scripts/ && ls'
alias brc='nvim ~/.bashrc'
alias ptt='pdftotext -layout'
alias mpdf='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=' # Merge pdf. Podać nazwa po połączeniu potem nazwy złączanych plików.

## Void Linux
# XBPS
alias xup='sudo xbps-install -Su' # Aktualizacja pakietów
alias xin='sudo xbps-install' # Instalacja paklietów  
alias xis='sudo xbps-install -S' # Instalacja paklietów i sync 
alias xqs='sudo xbps-query -s' # Wyszukiwanie zainstalowanych pakietów
alias xqr='sudo xbps-query -Rs' # Wyszukiwanie w repozytorium pakietów
alias xq='sudo xbps-query' # Info zainstalowany pakiet 
alias xr='sudo xbps-remove' # Usówanie pakietów
alias xrr='sudo xbps-remove -R' # Usówanie pakietów wraz z niepotzrebnymi zależnosciami
alias xro='sudo xbps-remove -O' # Usówanie osieroconych pakietów
alias xrc='xbps-remove -C' # Czyszczenie xbps /var/cache/

# XBPS - src > uruchamiać w ~/void-packages
alias xsbb='./xbps-src binary-bootstrap' # konfiguracja binary-bootstrap 
alias xsp='./xbps-src pkg' # Budowa pakietu 
alias xsi='sudo xbps-install -R hostdir/binpkgs/' # Instalacja pakietu 
alias xss='ls ~/void-packages/srcpkgs/ | grep' # Wyszukiwanie pakietu 
alias xsc='./xbps-src clean' # Czyszczenie
alias xsz='./xbps-src zap' # czyszczenie wraz z zależnościami

# Power
alias vrb='loginctl reboot' # Potrzeba zainstalować i uruchomić usługę logind
alias vpo='loginctl poweroff' # Potrzeba zainstalować i uruchomić usługę logind

# Rsync
alias rs='rsync -ravz'
alias rsd='rsync -ravz --delete'

# SSH
alias cpshh='scp -rv'
alias rsssh='rsync -avz -e ssh'
alias rsdssh='rsync -avz --delete -e ssh'

# Aliases GITBARE
alias gb='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # git --bare
alias gbs='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status'
alias gba='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add'
alias gbr='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME rm -r --cached'
alias gbc='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME commit -am'
alias gbpush='$HOME/Dokumenty/Git/gitbare-push.sh'
alias gbpull='$HOME/Dokumenty/Git/gitbare-pull.sh'
alias mgc='$HOME/Dokumenty/Git/my-git-clone.sh'
alias gc='git clone --depth=1 ' # ssh > git@github.com:trebuhw/dwm.git | https > https://github.com/trebuchw/dwm.git 
alias mga='git add .'
alias mgs='git status'
alias mgcom='git commit -am'
alias mgup='mgs; mga .; mgcom "up"; mgpush'
alias mgpush='$HOME/Dokumenty/Git/my-git-push.sh'
alias mgpull='$HOME/Dokumenty/Git/my-git-pull.sh'
alias mgacp='$HOME/Dokumenty/Git/my-git-acp.sh'
#alias gbp='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push'
#alias gbpull='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull'
alias gbf='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME fetch origin' # reset scalanie - merge 
alias nn='fzf-nn.sh'

eval "$(zoxide init bash)"

