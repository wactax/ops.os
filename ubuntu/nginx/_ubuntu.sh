#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

apt install -y cmake ninja-build g++ golang libunwind-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-dev libgeoip-dev
