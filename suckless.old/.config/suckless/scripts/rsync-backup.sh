#!/bin/bash

notify-send "Archiwum / backup - rozpoczęty" ;

rootDir='/run/media/hubert/Archiwum/Linux/Backup/240907_OpenSuse/root/'
homeDir='/run/media/hubert/Archiwum/Linux/Backup/240907_OpenSuse/hubert'

#root files
sudo rsync -av /root/.config $rootDir
sudo rsync -av /root/.local $rootDir

#home files
#rsync -av --exclude={.cache,.cargo,.dotfiles,.dotnet,.gnupg,.log,.moc,.mozilla,.npm,.pki,.rust,.ssh,.tldr,.vim,bin,Cloud,go,Pobrane/iso} ~/ $homeDir
rsync -av \
  --exclude=.cache \
  --exclude=.cargo \
  --exclude=.dotfiles \
  --exclude=.dotnet \
  --exclude=.gnupg \
  --exclude=.log \
  --exclude=.moc \
  --exclude=.mozilla \
  --exclude=.npm \
  --exclude=.pki \
  --exclude=.rustup \
  --exclude=.ssh \
  --exclude=.tldr \
  --exclude=.vim \
  --exclude=Cloud \
  --exclude=go \
  --exclude=Pobrane/iso \
~/ $homeDir

notify-send "Archiwum / Backup - zakończony" ;

exit
