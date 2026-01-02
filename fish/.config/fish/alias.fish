# List Directory
alias l='eza -la -1 --group-directories-first  --icons=auto' # long list
alias la='eza -a --group-directories-first --icons=auto' # long list
alias ls='eza -1 --group-directories-first --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias lta='eza --icons=auto --tree -a --sort name' # list folder as tree

# zoxide
alias zl='zi; l' # zoxide list folder
alias ze='zi; fe' # zoxide edit file to folder

alias t='tree --sort name'
alias ta='tree -aCsh --du --sort name'
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
alias slu='systemctl list-units'

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

# zypper
#alias z='sudo zypper'
#alias zup='sudo zypper refresh && sudo zypper update && sudo zypper dist-upgrade'
#alias zdup='sudo zypper refresh && sudo zypper dist-upgrade'
#alias i='sudo zypper install --no-recommends'
#alias r='sudo zypper remove -u'
#alias s='sudo zypper search'
#alias si='zypper search -i' # show installed Packages
#alias re='sudo zypper repos'
#alias rf='sudo zypper refresh'
#alias dr='sudo zypper mr -d' #disablerepo, dr - Wyłączenie wybranego repozytorium podać nazwę
#alias er='sudo zypper mr -e' #removerepo, er - Włączenie wybranego repozytorium podać nazwę
#alias rr='sudo zypper rr' #removerepo, rr - Usuwanie wybranego repozytorium
#alias ro='sudo zypper packages --unneeded' # Usówanie osieroconych pakietów
#alias rc='sudo zypper clean --all' # Clean repo, key repo, cache

# Snapper
alias sl='sudo snapper list'
alias sd='sudo snapper -c root delete --sync ' # usówanie migawek podać numer np. 55 lub przedział np. 55-65
alias sc='sudo snapper create --desc ' # podać opis np. "231227 UPDATE OS QEMU "
alias sr='sudo snapper rollback' # Polecenie wydawane tylko w momencie kiedy system uruchomiony jest z migawki do przywrócenia
alias sa='sudo btrfs-assistant' # Graficzne narzedzie snappera
alias sg='sudo snapper-gui' # Graficzne narzędie snapper

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

#search content with ripgrep
alias rg="rg --sort path"

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

#know what you do in these files
alias ngrub="sudo $EDITOR /etc/default/grub"
alias nconfgrub="sudo $EDITOR /boot/grub/grub.cfg"
alias upgrub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
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
alias fe='$HOME/.local/share/bin/fzf-nvim.sh'
alias fel='$HOME/.local/share/bin/fzf-nvim.sh $(pwd)/'
alias ffcp='cliphist list | fzf | cliphist decode | wl-copy'
alias ddm='if=/dev/sr0 of=cd.iso bs=4M status=progress' # cd.iso tworzy się w bierzącym katalogu
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
alias f='yazi'
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
alias ag="bat ~/.config/fish/alias.fish | sort | grep"
alias hg='history | grep '
alias pogoda='curl wttr.in/Swidnica'

# pacman
alias u='sudo pacman -Syyu && yay'
alias i='sudo pacman -S --needed'
alias s='pacman -Ss'
alias qe='pacman -Qe' # zainstalowane programy bez zależności i bibliotek
alias qi='pacman -Qei | grep' # zainstalowany program info
alias qp='pacman -Qqet' # pacman - zainstalowane pakiety
alias q='pacman -Q' # pacman - zainstalowane programy
alias qa='pacman -Qem'
alias ql='pacman -Sl | grep zainstalowano ' # wyswietla pakiety z info o repozytorium użyć ( | grep "nazwa repo") 
alias r='sudo pacman -Rns '
alias ro='sudo pacman -Rsn $(pacman -Qdtq)' # usówanie osieroconych pakietów
#alias clean='sudo pacman -Scc; yay -Scc; sudo pacman -Rns $(pacman -Qtdq);rm -rf ~/.cache/*; sudo journalctl --vacuum-time=2weeks; trash-empty; sudo trash-empty'
alias clean='~/.local/share/bin/clean.sh'
# alias refup='sudo reflector --latest 30 --protocol https --sort rate --number 10 --verbose --save /etc/pacman.d/mirrorlist'

# yay
alias y='yay'
alias yu='yay -Syyu'
alias yf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:50% | xargs -ro yay -S"

# paru
alias p='paru --bottomup'
alias pf="paru -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:50% | xargs -ro yay -S"

alias oi="grep -i installed /var/log/pacman.log | bat | sort "
alias oiw="$HOME/.config/hypr/scripts/ostatnie-instalacje-wieksze.sh"
alias oim="$HOME/.config/hypr/scripts/ostatnie-instalacje-mniejsze.sh"
alias oip="$HOME/.config/hypr/scripts/ostatnie-instalacje-od-do.sh"
alias oiz="$HOME/.config/hypr/scripts/ostatnie-instalacje-z-dnia.sh"
alias power='powerprofilesctl' # Zarządzani power pc systemctl enable/start power-profiles-daemon.service
alias rk='du -sh *'
alias picker='hyprpicker -an'
alias cc='rm /home/hubert/.cache/cliphist/db' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias chwipe='cliphist wipe' # Clear list cliphist - historia kopiowania, numeracja elementów skopiowanych będzię kontynuowana 
alias chdel='rm /home/hubert/.cache/cliphist/db' # Cliphist usunięcie  bazy - numeracja skopiowanych będzię kontynuowana od nowa
alias umount='sudo umount -dflnrv' # Podaj ścieżkę zamontowanego katalogu
alias mocp='mocp -C $HOME/.moc/config'
alias ytd='yt-dlp --extract-audio --audio-format mp3 --audio-quality 0'
alias ff='fastfetch'
alias ffm='fastfetch -c $HOME/.dotfiles/fastfetch/.config/fastfetch/hw-config.jsonc'
alias ffn='fastfetch -l none - c $HOME/.dotfiles/fastfetch/.config/fastfetch/org-config.jsonc'
alias ffo='fastfetch -l small -c $HOME/.dotfiles/fastfetch/.config/fastfetch/omarchy-config.jsonc'
alias td='sudo hdparm -t' # test prędkości dysku użycie sudo hdparm -t /dev/sda

alias hom='cd ~/ && la'
alias dok='cd ~/Dokumenty/ && ls'
alias no='cd ~/Dokumenty/Hubert/Notes/ && ls'
alias ghu='cd ~/Dokumenty/GitHub/ && ls'
alias obr='cd ~/Obrazy/ && ls'
alias muz='cd ~/Muzyka/ && ls'
alias pob='cd ~/Pobrane/ && ls'
alias sha='cd ~/Shared/ && ls'
alias arc='cd ~/Archiwum/ && ls'
alias dro='cd ~/Dropbox/ && ls'
alias dot='cd ~/.dotfiles/ && l'
alias con='cd ~/.config && ls'
alias bin='cd ~/.local/share/bin/ && ls'
alias oma='cd ~/.local/share/omarchy/ && ls'
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

#### VOID LINUX #####
# XBPS - src > uruchamiać w ~/void-packages
alias xsbb='./xbps-src binary-bootstrap' # konfiguracja binary-bootstrap 
alias xsp='./xbps-src pkg' # Budowa pakietu 
alias xsi='sudo xbps-install -R hostdir/binpkgs/' # Instalacja pakietu 
alias xss='ls ~/void-packages/srcpkgs/ | grep' # Wyszukiwanie pakietu 
alias xsc='./xbps-src clean' # Czyszczenie
alias xsz='./xbps-src zap' # czyszczenie wraz z zależnościami

# Google-Chrome > install & update
alias igch='~/.local/share/bin/src-install_chrome.sh'
alias upgch='~/.local/share/bin/void_chrome_install_update.sh'
alias upgho='~/.local/share/bin/void_ghostty_install_update.sh'

# Power
alias vrb='loginctl reboot' # Potrzeba zainstalować i uruchomić usługę logind
alias vpo='loginctl poweroff' # Potrzeba zainstalować i uruchomić usługę logind

# Rsync
alias rs='rsync -av'
alias rsd='rsync -av --delete'
alias rsn='rsync -av --delete ~/Dokumenty/Hubert/Notes ~/Cloud/PCloud'
alias rsbg='rsync -av --delete ~/Obrazy/bg/ ~/.local/share/omarchy/themes/catppuccin/backgrounds/'
alias rswal='rsync -av --delete ~/Obrazy/Wallpaper/ ~/Cloud/PCloud/Obrazy/Wallpaper/'

# SSH
alias cpshh='scp -rv'
alias rsssh='rsync -avz -e ssh'
alias rsdssh='rsync -avz --delete -e ssh'

# GIT
alias mgc='$HOME/Dokumenty/Git/my-git-clone.sh'
alias gc='git clone --depth=1 ' # ssh > git@github.com:trebuhw/dwm.git | https > https://github.com/trebuchw/dwm.git 
alias mga='git add .'
alias mgs='git status'
alias mgcom='git commit -am'
alias mgup='mgs; mga .; mgcom "up"; mgpush'
alias mgpush='$HOME/Dokumenty/Git/my-git-push.sh'
alias mgpull='$HOME/Dokumenty/Git/my-git-pull.sh'
alias mgacp='$HOME/Dokumenty/Git/my-git-acp.sh'
alias gbf='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME fetch origin' # reset scalanie - merge 
alias nn='~/.local/share/bin/fzf-nn.sh'

# omarchy
alias ou='omarchy-update'
