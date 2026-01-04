# =========================
# ALIASY HUBERT - ARCH / OMARCHY / HYPRLAND
# =========================

# -------------------------
# Listowanie plików (eza)
# -------------------------
alias l='eza -la -1 --group-directories-first --icons=auto' # lista szczegółowa
alias la='eza -a --group-directories-first --icons=auto' # lista z plikami ukrytymi
alias ls='eza -1 --group-directories-first --icons=auto' # krótka lista
alias ll='eza -lha --group-directories-first --icons=auto' # pełna lista
alias ld='eza -lhD --icons=auto' # tylko katalogi
alias lt='eza --tree --icons=auto' # drzewo katalogów
alias lta='eza --tree -a --sort name --icons=auto' # drzewo z ukrytymi

# -------------------------
# Nawigacja (zoxide + cd)
# -------------------------
alias zl='zi; l' # przejdź przez zoxide i pokaż katalog
alias ze='zi; fe' # zoxide + edycja pliku
alias cd..='cd ..' # literówka

# -------------------------
# Tree / system
# -------------------------
alias t='tree --sort name'
alias ta='tree -aCsh --du --sort name'
alias df='df -h'
alias free='free -mt'
alias hw='hwinfo --short'
alias ws='watch sensors'
alias userlist='cut -d: -f1 /etc/passwd | sort'

# -------------------------
# Audio / jasność
# -------------------------
alias am='alsamixer'
alias vs='amixer sset "Master"' # ustaw głośność (np. 50%)
alias vs4='amixer sset "Master" 40%' # głośność 40%

alias bs='brightnessctl set' # ustaw jasność
alias bs3='brightnessctl set 30%' # jasność 30%
alias bi='brightnessctl i' # info o jasności

# -------------------------
# Bezpieczne operacje na plikach (trash-cli)
# -------------------------
alias cp='cp -riv' # kopiowanie z potwierdzeniem
alias mv='mv -iv' # przenoszenie z potwierdzeniem
alias rm='trash-put -rfv' # przenieś do kosza

alias tl='trash-list' # lista plików w koszu
alias te='trash-empty' # opróżnij kosz
alias tr='trash-restore' # przywróć plik
alias trm='trash-rm' # usuń z kosza na stałe

alias mkdir='mkdir -vp' # tworzenie katalogów z rodzicami

# -------------------------
# Wyszukiwanie i logi
# -------------------------
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias rg='rg --sort path' # ripgrep
alias find='find -name'
alias locate='locate -b'
alias jctl='journalctl -p 3 -xb' # błędy systemu

# -------------------------
# Pacman / AUR (Arch)
# -------------------------
alias u='sudo pacman -Syyu && yay'
alias yu='yay -Syyu'

alias i='sudo pacman -S --needed'
alias s='pacman -Ss'
alias y='yay'

alias q='pacman -Q'
alias qe='pacman -Qe'
alias qi='pacman -Qei | grep'
alias qp='pacman -Qqet'
alias qa='pacman -Qem'

alias r='sudo pacman -Rns'
alias ro='sudo pacman -Rsn (pacman -Qdtq)'

alias clean='~/.local/share/bin/clean.sh'

# -------------------------
# Snapper
# -------------------------
alias sl='sudo snapper list'
alias sd='sudo snapper -c root delete --sync' # podać nr lub zakres
alias sc='sudo snapper create --desc' # podać opis
alias sr='sudo snapper rollback'
alias sa='sudo btrfs-assistant'
alias sg='sudo snapper-gui'

# -------------------------
# System / power / info
# -------------------------
alias e='exit'
alias ff='fastfetch'
alias ffm='fastfetch -c ~/.dotfiles/fastfetch/.config/fastfetch/hw-config.jsonc'
alias ffn='fastfetch -l none -c ~/.dotfiles/fastfetch/.config/fastfetch/org-config.jsonc'
alias ffo='fastfetch -l small -c ~/.dotfiles/fastfetch/.config/fastfetch/omarchy-config.jsonc'

alias po='systemctl poweroff'
alias rb='systemctl reboot'
alias rh='hyprctl dispatch exit'
alias logout='pkill -KILL -u hubert'
alias power='powerprofilesctl'

alias probe='sudo -E hw-probe -all -upload'
alias sysfailed='systemctl list-units --failed'
alias pcinfo="inxi -Fxz"

# -------------------------
# Bluetooth
# -------------------------
alias bt='blueman-adapters'
alias br='sudo systemctl restart bluetooth'
alias btinfo="bluetoothctl info"
alias think="bluetoothctl info | awk '/Name:/ || /Battery Percentage:/' | bat"

# -------------------------
# Sieć / diagnostyka
# -------------------------
alias nm='nmtui' # interfejs tekstowy NetworkManager
alias nma='nm-applet' # applet NetworkManager w trayu
alias nmap='nmap -sn 192.168.0.1/24' # skanowanie sieci LAN
alias nmarp='arp-scan --interface=wlan0 192.168.0.1/24' # ARP scan sieci lokalnej
alias nmdis='sudo netdiscover -r 192.168.0.1/24' # wykrywanie hostów w LAN
alias nt='speedtest' # test prędkości internetu
alias dns='systemd-resolve --status' # status DNS

# -------------------------
# Twoje programy / Hyprland
# -------------------------
alias nv='nvim'
alias f='yazi'
alias ag="bat ~/.config/fish/alias.fish | sort | grep"
alias hg='history | grep '

alias hwi='hyprprop'
alias app='hyprctl clients'
alias picker='hyprpicker -an'
alias bg='nsxiv -t /home/hubert/.dotfiles/backgrounds/.local/share/omarchy/themes/catppuccin/backgrounds/'
alias fzf='fzf --preview "bat --color=always {}"'
alias fe='~/.local/share/bin/fzf-nvim.sh'
alias fel='~/.local/share/bin/fzf-nvim.sh $(pwd)/'
alias ffcp='cliphist list | fzf | cliphist decode | wl-copy'
alias mocp='mocp -C $HOME/.moc/config'
alias ytd='yt-dlp --extract-audio --audio-format mp3 --audio-quality 0'
alias pogoda='curl wttr.in/Swidnica'
alias c='cal -y'
alias mpdf='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile='
alias ptt='pdftotext -layout'

# -------------------------
# Foldery / szybka nawigacja
# -------------------------
alias hom='cd ~/ && la'
alias dok='cd ~/Dokumenty/ && ls'
alias no='cd ~/Dokumenty/Hubert/Notes/ && ls'
alias ghu='cd ~/Dokumenty/GitHub/ && ls'
alias obr='cd ~/Obrazy/ && ls'
alias muz='cd ~/Muzyka/ && ls'
alias pob='cd ~/Pobrane/ && ls'
alias sha='cd ~/Shared/ && ls'
alias dot='cd ~/.dotfiles/ && l'
alias con='cd ~/.config && ls'
alias bin='cd ~/.local/share/bin/ && ls'
alias oma='cd ~/.local/share/omarchy/ && ls'
alias hyp='cd ~/.config/hypr/ && ls'
alias fis='cd ~/.config/fish/ && ls'

# -------------------------
# RSYNC / backup / SSH
# -------------------------
alias rs='rsync -av'
alias rsd='rsync -av --delete'
alias rsn='rsync -av --delete ~/Dokumenty/Hubert/Notes ~/Cloud/PCloud'
alias rsbg='rsync -av --delete ~/Obrazy/bg/ ~/.local/share/omarchy/themes/catppuccin/backgrounds/'
alias rswal='rsync -av --delete ~/Obrazy/Wallpaper/ ~/Cloud/PCloud/Obrazy/Wallpaper/'
alias backup='~/.local/share/bin/backup.sh'

alias cpshh='scp -rv'
alias rsssh='rsync -avz -e ssh'
alias rsdssh='rsync -avz --delete -e ssh'

# -------------------------
# GIT
# -------------------------
alias mgc='~/Dokumenty/Git/my-git-clone.sh'
alias gc='git clone --depth=1'
alias mga='git add .'
alias mgs='git status'
alias mgcom='git commit -am'
alias mgup='mgs; mga .; mgcom "up"; mgpush'
alias mgpush='~/Dokumenty/Git/my-git-push.sh'
alias mgpull='~/Dokumenty/Git/my-git-pull.sh'
alias mgacp='~/Dokumenty/Git/my-git-acp.sh'
alias gbf='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME fetch origin'
alias nn='~/.local/share/bin/fzf-nn.sh'

# -------------------------
# Omarchy
# -------------------------
alias ou='omarchy-update'
