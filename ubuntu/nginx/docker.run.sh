#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ -v 1 ]; then
  org="$1/"
fi

docker run --rm -it ${org}nginx /bin/bash
