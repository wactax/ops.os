#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if ! [ -x "$(command -v juicefs)" ]; then
  curl -sSL https://d.juicefs.com/install | sh -
fi

# juicefs format \
#   --storage oss \
#   --bucket https://myjfs.oss-cn-shanghai.aliyuncs.com \
#   --access-key ABCDEFGHIJKLMNopqXYZ \
#   --secret-key ZYXwvutsrqpoNMLkJiHgfeDCBA \
#   redis://tom:mypassword@myjfs-sh-abc.redis.rds.aliyuncs.com:6379/0 \
#   myjfs
