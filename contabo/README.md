# contabo 配置备忘

## 测试磁盘性能

[disk.sysbench.sh](./disk.sysbench.sh)

## 如何把根分区从 ext4 转为 btrfs

mount /dev/sda3 /mnt -t btrfs -o defaults,ssd,discard,noatime,compress=zstd:3,space_cache=v2
mount /dev/sda2 /mnt/boot -t ext4 -o defaults,noatime

mount -t proc /proc /mnt/proc

mount --rbind /dev /mnt/dev
mount --make-rslave /mnt/dev
mount --rbind /sys /mnt/sys
mount --make-rslave /mnt/sys

cp /etc/resolv.conf /mnt/etc
chroot /mnt /bin/bash

apt install -y dnf

编辑 /etc/grub.d/00_header

注释掉

  # if [ -n "\${have_grubenv}" ]; then if [ -z "\${boot_once}" ]; then save_env recordfail; fi; fi

然后运行

update-grub
grub-install /dev/sda

然后重启，进入系统
apt install -y btrfs-progs
btrfs subvolume delete /ext2_saved
btrfs filesystem defrag -v -r -f /
btrfs filesystem defragment -r -v -czstd / > /dev/null
btrfs balance start -m /
