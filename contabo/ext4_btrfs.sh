#!/usr/bin/env bash

btrfs-convert /dev/sda3

mount /dev/sda3 /mnt -t btrfs -o defaults,ssd,discard,noatime,compress=zstd:3,space_cache=v2
mount /dev/sda2 /mnt/boot -t ext4 -o defaults,noatime

mount -t proc /proc /mnt/proc

mount --rbind /dev /mnt/dev
mount --make-rslave /mnt/dev
mount --rbind /sys /mnt/sys
mount --make-rslave /mnt/sys

cp /etc/resolv.conf /mnt/etc
chroot /mnt /bin/bash
