#!/usr/bin/env bash

set -ex

DEVICE_ROOT="/dev/sda3"
DEVICE_BOOT="/dev/sda2"
MNT="/mnt"
OPTIONS_BTRFS="defaults,ssd,discard,noatime,compress=zstd:3,space_cache=v2"

btrfs-convert $DEVICE_ROOT

mount $DEVICE_ROOT $MNT -t btrfs -o $OPTIONS_BTRFS
mount $DEVICE_BOOT $MNT/boot -t ext4 -o defaults,noatime

for item in proc dev sys; do
  mount --rbind /$item $MNT/$item
  [[ "$item" == "dev" || "$item" == "sys" ]] && mount --make-rslave $MNT/$item
done

rm $MNT/etc/resolv.conf
cp /etc/resolv.conf $MNT/etc

backup_file="$MNT/etc/fstab.bak"
fstab_file="$MNT/etc/fstab"
cp $fstab_file $backup_file

awk '
{
  if ($2 == "/") {
    $1="'$DEVICE_ROOT'";
    $3="btrfs";
    $4="'$OPTIONS_BTRFS'";
    $5="0";
    $6="0";
  }
  print;
}' $backup_file >$fstab_file

wget https://raw.githubusercontent.com/wactax/ops.os/main/contabo/init.btrfs.sh -O $MNT/init.btrfs.sh
chmod +x $MNT/init.btrfs.sh

chroot $MNT /init.btrfs.sh
