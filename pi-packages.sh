#!/bin/bash
#
# Tested with Raspbian Lite Buster
#

sudo apt update
sudo apt-get install -y psmisc
sudo apt-get install -y build-essential clang git cmake npm
sudo apt-get install -y libboost-all-dev valgrind
sudo apt-get install -y alsa-base alsa-utils
sudo apt-get install -y linuxptp libavahi-client-dev
sudo apt install -y raspberrypi-kernel-headers

# Raspbian has an outdated npm package
sudo npm i npm@latest -g
