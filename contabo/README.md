# contabo 配置备忘

## 测试磁盘性能

[disk.sysbench.sh](./disk.sysbench.sh)

## 如何把根分区从 ext4 转为 btrfs

如果不是干净的系统，可以先重装

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/LsAN4pZ.webp)

然后进入救援系统 (参考 [System Rescue CD: First Steps](https://contabo.com/blog/system-rescue-cd-first-steps))

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/XlYH1Je.webp)

系统选 Debian Rescue (recommended)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/Wa2HdD1.webp)

bash <(curl -s https://raw.githubusercontent.com/wactax/ops.os/main/contabo/ext4_btrfs.sh)

编辑 /etc/grub.d/00_header

注释掉

  # if [ -n "\${have_grubenv}" ]; then if [ -z "\${boot_once}" ]; then save_env recordfail; fi; fi

然后运行

update-grub
grub-install /dev/sda

然后重启，进入系统
apt install -y btrfs-progs
btrfs subvolume delete /ext2_saved
btrfs filesystem defragment -r -v -f -czstd / > /dev/null
btrfs balance start -m /
