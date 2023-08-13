#!/usr/bin/env bash

sed -i 's/Prompt=LTS/Prompt=normal/i' /etc/update-manager/release-upgrades
apt update -y 
apt upgrade -y
apt dist-upgrade -y
do-release-upgrade -f DistUpgradeViewNonInteractive
dpkg --configure -a
apt-get install -f -y
apt-get autoremove -y
apt-get autoclean -y
apt clean -y
journalctl --vacuum-size=50M
old_kernels=$(dpkg --list | grep linux-image | awk '{ print $2 }' | sort -V | sed -n '/'$(uname -r)'/q;p')
if [ "$old_kernels" != "" ]; then
  sudo apt purge -y $old_kernels
fi
