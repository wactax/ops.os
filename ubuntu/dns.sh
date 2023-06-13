#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd /tmp

if [ -d "smartdns-rs" ]; then
  cd smartdns-rs
  git pull
else
  git clone --depth=1 https://github.com/mokeyish/smartdns-rs.git
  cd smartdns-rs
fi

cargo build --release

CONF=/etc/smartdns/smartdns.conf
if [ ! -f "$CONF" ]; then
  mkdir -p /etc/smartdns
  cp .$CONF $CONF
  sed -i -e "s/^# server https.*/server 1.0.0.1\nserver 8.8.4.4\nserver 1.1.1.1\nserver 8.8.8.8/" $CONF
fi

cp target/release/smartdns /usr/local/bin/smartdns
smartdns service install

sed -i 's/127.0.0.53/127.0.0.1/g' /etc/resolv.conf
systemctl disable --now systemd-resolved
systemctl enable smartdns-rs --now
systemctl restart systemd-networkd
