#! /bin/bash -ex
sudo apt update
sudo apt install -y git

sudo mkdir /opt/aes67
sudo chown $USER:$USER /opt/aes67
cd /opt/aes67
git clone https://github.com/bondagit/aes67-linux-daemon.git
cd aes67-linux-daemon

if grep 'ID=raspbian' /etc/os-release > /dev/null; then
    # starting w/ raspbian lite buster
    $(dirname $0)/pi-packages.sh
    $(dirname $0)/pi-optimise.sh
else
    ./ubuntu-packages.sh
fi

./build.sh

# in daemon.conf, set "interface_name" to "eth0"
# use an absolute path for "status_file"
# set "rtp_mcast_base" to "239.69.0.1" for connection to symetrix DSPs
# set "tic_frame_size_at_1fs" to 192 to prevent audio glitches when using alsaloop to external audio devices
mkdir /opt/aes67/config
python -c '
import sys, json
print(json.dumps({
    **json.load(sys.stdin),
    "interface_name": "eth0",
    "status_file": "/opt/aes67/config/status.json",
    "rtp_mcast_base": "239.69.0.1",
    "tic_frame_size_at_1fs": 192,
}, indent=2))' <daemon/daemon.conf >/opt/aes67/config/daemon.conf

# install kernel module and set to auto-load
cd 3rdparty/ravenna-alsa-lkm/driver
sudo make module_install; sudo depmod -A
sudo modprobe MergingRavennaALSA
echo MergingRavennaALSA | sudo tee -a /etc/modules

cd "$(dirname $0)"

# copy stream-configs to streams
cp -r stream-configs/ /opt/aes67/config/streams/

# copy dhcpcd hook
sudo cp dhcpcd-hook /usr/lib/dhcpcd/dhcpcd-hooks/99-aes67.conf

# copy systemd service files
sudo sed "s/User=.*/User=$USER/" aes67-daemon.service >/lib/systemd/system/aes67-daemon.service
sudo sed "s/User=.*/User=$USER/" aes67-stream@.service >/lib/systemd/system/aes67-stream@.service

sudo systemctl daemon-reload
sudo systemctl enable --now aes67-daemon
