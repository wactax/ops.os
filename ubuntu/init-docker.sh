#!/usr/bin/env bash

sudo apt-get update
#if ! curl --connect-timeout 2 -m 4 -s https://t.co > /dev/null ;then
#mirror="--mirror AzureChinaCloud"
#fi
#curl -fsSL https://get.docker.com | sudo bash -s docker $mirror
pip3 install --force-reinstall PyYAML==5.4.1
curl -fsSL https://get.docker.com | sudo bash -s docker
sudo systemctl start docker
sudo systemctl enable docker
pip3 install docker-compose
