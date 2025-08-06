#!/bin/bash

## QUEMU - VIRT-MANAGER - Install i config

# Sprawdzenie czy virtualizacja jest dostępna na omputerze
# LC_ALL=C lscpu | grep Virtualization

# Instalacja programów yay lub paru
paru -S --needed --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf swtpm guestfs-tools libosinfo iptables

# Włączenie usług
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd

# Dodanie user do grupy
sudo usermod -G libvirt -a hubert

# Status połączenie
# sudo virsh net-list --all

# autostart domyślnej sieci 
sudo virsh net-autostart default

# Status połączenie
# sudo virsh net-list --all

# Dodanie wpisu firewall_backend=iptables w /etc/libvirt/network.conf
echo "firewall_backend=iptables" | sudo tee -a /etc/libvirt/network.conf
# echo "firewall_backend=iptables" | sudo tee -a /etc/libvirt/libvirtd.conf # sprawdzić

# Ręczna metoda dodania wpisu
# sudo vim /etc/libvirt/network.conf
# firewall_backend=iptables
