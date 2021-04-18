#! /bin/bash -ex

# raspbian boot optimisations
# disable ipv6 and testing address with arp
sudo sed -ei 's/^slaac(.*)/#slaac\1/' /etc/dhcpcd.conf
cat - | sudo tee -a /etc/dhcpcd.conf << EOF

noipv6
noarp
ipv4only
EOF

# disable bluetooth and wifi
cat - | sudo tee -a /boot/config.txt << EOF
dtoverlay=disable-bt
dtoverlay=disable-wifi

# skip waiting in bootloader
boot_delay=0
disable_splash=1
EOF
sudo systemctl disable hciuart
sudo systemctl disable wpa_supplicant.service
sudo systemctl disable triggerhappy
sudo systemctl disable keyboard-setup.service
sudo systemctl disable bluetooth.service
sudo systemctl disable triggerhappy.socket
sudo systemctl disable raspi-config.service

# Reduce logging in startup
sudo sed -ei 's/$/ quiet net.ifnames=0/' /boot/cmdline.txt

# SD card write optimisations
cat - | sudo tee -a /etc/fstab << EOF
tmpfs           /tmp            tmpfs   defaults,noatime,nosuid         0       0
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,size=16m        0      0
EOF
# sudo systemctl disable dphys-swapfile  # disable swap
