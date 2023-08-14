#!/usr/bin/env bash

apt-get update
#if ! curl --connect-timeout 2 -m 4 -s https://t.co > /dev/null ;then
#mirror="--mirror AzureChinaCloud"
#fi
#curl -fsSL https://get.docker.com | sudo bash -s docker $mirror
pip3 install --force-reinstall PyYAML==5.3.1
curl -fsSL https://get.docker.com | bash -s docker
systemctl start docker
systemctl enable docker
pip3 install docker-compose
