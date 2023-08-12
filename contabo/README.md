# contabo 配置备忘

## 测试磁盘性能

[disk.sysbench.sh](./disk.sysbench.sh)

## 如何把根分区从 ext4 转为 btrfs

如果不是干净的系统，可以先重装

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/LsAN4pZ.webp)

重装的话，请先等待 Status 变为 finish，否则可能会导致错误。

然后进入救援系统 (参考 [System Rescue CD: First Steps](https://contabo.com/blog/system-rescue-cd-first-steps))

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/XlYH1Je.webp)

系统选 Debian Rescue (recommended)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/Wa2HdD1.webp)

```
bash <(curl -s https://raw.githubusercontent.com/wactax/ops.os/main/contabo/ext4_btrfs.sh)
```

即可
