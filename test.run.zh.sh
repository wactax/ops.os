#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

docker run -it --rm usertax/dev_ubuntu_zh /bin/zsh
