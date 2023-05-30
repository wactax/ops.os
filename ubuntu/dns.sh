#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

git clone --depth=1 https://github.com/mokeyish/smartdns-rs.git
cd smartdns-rs
cargo build --release
cp $DIR/dns.conf /etc
