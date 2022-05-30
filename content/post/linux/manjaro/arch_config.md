---
title: arch 配置
comments: true
toc: true
tags:
    - arch
description: fcitx5 框架，pinyin 输入法、rime 输入法，肥猫的维基百万词库以及fcitx5-rime 配置
summary: fcitx5 框架，pinyin 输入法、rime 输入法，肥猫的维基百万词库以及fcitx5-rime 配置
categories:
    - linux
date: 2020-08-07 20:11:25
---

## 剪切板

`yay -S xclip`

## 解压软件

添加对 7zip，rar， zip 的支持

`yay -S unarchiver p7zip rar unzip`

## 蓝牙

1. `sudo pacman -S bluez bluez-utils bluedevil`
2. Start/enable bluetooth.service.

-   bluez: 提供蓝牙协议栈
-   bluez-utils: 提供 bluetoothctl 工具
-   bluedevil: KDE's blutooth tool

## 蓝牙耳机

`sudo pacman -S pulseaudio-alsa, pulseaudio-bluetooth pavucontrol pulseaudio-alsa`

-   pulseaudio-bluetooth 则为 bluez 提供了 PulseAudio 音频服务,若没有安装则蓝牙设备在配对完成后,连接会失败,提示
-   pavucontrol 则提供了 pulseaudio 的图形化控制界面
-   pulseaudio-alsa(可选)则使 pulseaudio 和 alsa 协同使用，之后就可以用 alsamixer 来管理蓝牙音频了

## 自动挂载

1. 安装 ntfs-3g
   `sudo pacman -S ntfs-3g`

2. 确定要挂载的分区
   `fdisk -l`

    ```txt
    Device          Start        End   Sectors   Size Type
    /dev/sdb1        2048  652224504 652222457   311G Microsoft basic data
    /dev/sdb2   652224512 1302949805 650725294 310.3G Microsoft basic data
    /dev/sdb3  1302949808 1953525134 650575327 310.2G Microsoft basic data
    ```

    例如：我要挂载 `/dev/sdb1`、`/dev/sdb2`

3. 记住在 Windows 上对应该分区的名字
   例如：上面两个叫做 `notes，software`

4. 修改 fstab

    `sudo vim /etc/fstab`

    按照对应格式在文件末尾加上最后四句，其中 `<dir>` 字段根据自己的绝对路径写

    ```shell
    cat /etc/fstab
    # Static information about the filesystems.
    # See fstab(5) for details.

    # <file system> <dir> <type> <options> <dump> <pass>
    # /dev/sda5
    UUID=49ab84d9-8361-46f4-8f68-a18201dc105d       /               ext4            rw,relatime     0 1

    # /dev/sda1
    UUID=34DB-E5F7          /boot/efi       vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro       0 2

    # /dev/sda4
    UUID=236b02b4-f6b4-46ce-90c6-fff28b4a7a31       none            swap            defaults        0 0
    #/dev/sdb1
    /dev/sdb1               /run/media/vio1etus/notes       ntfs-3g         defaults        0       0

    #/dev/sdb2
    /dev/sdb2               /run/media/vio1etus/software    ntfs-3g         defaults        0       0
    ```

5. 完成，以后开机自动挂载

## 参考资料

> 1. [arch_wiki fstab](https://wiki.archlinux.org/index.php/Fstab)
> 2. [arch_wiki bluetooth](https://wiki.archlinux.org/index.php/bluetooth)
> 3. [arch_wiki Bluetooth headset](https://wiki.archlinux.org/index.php/Bluetooth_headset#Headset_via_Bluez5/PulseAudio)
> 4. [Archiving and compression](https://wiki.archlinux.org/index.php/Archiving_and_compression)
