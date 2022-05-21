---
title: Manjaro KDE 使用
comments: true
toc: true
tags:
    - manjaro
description: 记录 Manjaro KDE 中一些软件的使用技巧
categories:
    - linux
date: 2020-08-07 21:11:25
---

> 遇到什么，随时更新

## Konsole

Konsole 快捷键：

`Ctrl+Alt+t`: 打开 Konsole

`Ctrl+ (`: 左/右分割视图

`Ctrl+ )`: 拆分视图顶部/底部

`Shift+ Tab`: 在拆分视图之间循环

`Ctrl + Shift+ Left Arrow/ Right Arrow`: 在拆分视图窗格之间切换

`Shift+ Left Arrow/ Right Arrow`: 在选项卡/视图之间循环显示当前视图

`Ctrl + shift+w`: 关闭当前视图

`Ctrl + shift +Tab` 或者 `Ctrl + w`: 创建新标签页

`Ctrl +shift+c`： Copy

`Ctrl +shift+v`： Paste （File path）

`Shift+Ctrl+F` 打开 Find 窗口，提供待搜索文本的搜索选项

`reset` 命令：初始化（重置）终端

`Ctrl+Shift+q` 退出 Konsole Terminal 仿真应用

## 开机自动挂载 NTFS 格式分区

1. 安装 ntfs-3g

    `sudo pacman -S ntfs-3g`

2. 修改`fstab`

    sudo vim /etc/fstab

    ```shell
    #
    # /etc/fstab: static file system information
    #
    # <file system> <dir> <type> <options> <dump> <pass>

    /dev/sdb1 /run/media/vio1etus/notes ntfs-3g defaults 0 0
    /dev/sdb2 /run/media/vio1etus/software ntfs-3g defaults 0 0
    ```

    说明，把/dev/sdb1 挂在到 `/run/media/vio1etus/notes` 目录下，type 为 `ntfs-3g`
    以后每次开机，Manjaro 都会自动挂载分区。

## 参考资料

> 1. [fstab](https://wiki.archlinux.org/index.php/Fstab)
