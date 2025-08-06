#!/bin/bash

#!/bin/bash

## QEMU - VIRT-MANAGER - Install i config

# Sprawdzenie czy wirtualizacja jest dostępna na komputerze
if ! LC_ALL=C lscpu | grep -i virtualization; then
    echo "Wirtualizacja nie jest dostępna na tym komputerze. Przerwanie instalacji."
    exit 1
else
    echo "Wirtualizacja jest dostępna. Kontynuowanie instalacji..."
fi

# Sprawdzenie czy paru jest zainstalowane
if ! command -v yay &> /dev/null; then
    echo "paru nie jest zainstalowane. Zainstaluj paru przed uruchomieniem tego skryptu."
    exit 1
fi

# Instalacja programów przez paru
yay -S --needed --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf swtpm guestfs-tools libosinfo iptables

# Włączenie usług
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl status libvirtd

# Dodanie użytkownika do grupy libvirt
# UWAGA: Zmień "hubert" na swoją nazwę użytkownika, jeśli jest inna
CURRENTUSER=$(whoami)
sudo usermod -G libvirt -a $CURRENTUSER
echo "Użytkownik $CURRENTUSER został dodany do grupy libvirt."

# Sprawdzenie statusu sieci
echo "Status sieci przed konfiguracją:"
sudo virsh net-list --all

# Autostart domyślnej sieci 
sudo virsh net-autostart default
sudo virsh net-start default 2>/dev/null || echo "Sieć default już uruchomiona"

# Sprawdzenie statusu sieci po konfiguracji
echo "Status sieci po konfiguracji:"
sudo virsh net-list --all

# Dodanie wpisu firewall_backend=iptables w /etc/libvirt/libvirtd.conf
if ! grep -q "firewall_backend=iptables" /etc/libvirt/libvirtd.conf; then
    echo "firewall_backend=iptables" | sudo tee -a /etc/libvirt/libvirtd.conf
    echo "Dodano konfigurację firewall_backend=iptables."
else
    echo "Konfiguracja firewall_backend=iptables już istnieje."
fi

# To do sprawdzenie który plik istnieje
# Dodanie wpisu firewall_backend=iptables w /etc/libvirt/network.conf
#if ! grep -q "firewall_backend=iptables" /etc/libvirt/network.conf; then
#    echo "firewall_backend=iptables" | sudo tee -a /etc/libvirt/network.conf
#    echo "Dodano konfigurację firewall_backend=iptables."
#else
#    echo "Konfiguracja firewall_backend=iptables już istnieje."
#fi

# Restart usługi libvirtd aby zastosować zmiany
sudo systemctl restart libvirtd

echo "Instalacja i konfiguracja zakończona pomyślnie!"
echo "Zalecane jest wylogowanie i ponowne zalogowanie, aby członkostwo w grupie libvirt zostało zastosowane."