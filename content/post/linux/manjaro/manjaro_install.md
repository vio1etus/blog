---
title: UEFI+GPT win+manjaro 双系统安装
comments: true
toc: true
tags:
    - manjaro
description: 本文在虚拟机下完成 Windows+Manjaro 双系统的安装，与本人的实体双系统安装步骤无太大差异（多了些虚拟机的设置等）。仅仅作为个人回忆/重装的笔记使用。
summary: 本文在虚拟机下完成 Windows+Manjaro 双系统的安装，与本人的实体双系统安装步骤无太大差异（多了些虚拟机的设置等）。仅仅作为个人回忆/重装的笔记使用。
categories:
    - linux
date: 2020-09-29 10:11:25
---

首先安装好 Windows 系统，这儿就不说了。

## 最初看的安装教程

[UEFI 安装 Win10+Manjaro-Linux 双系统](https://www.bilibili.com/s/video/BV1eJ411P7NF)

## Windows

遇到的问题：

1. Windows 原版镜像安装时报错
   Virtualbox 使用百度网盘离线下载的 MSDN Itellyou 的镜像总是报错，本来以为是没下完整，后来又下载了一次无效。

    使用[俄罗斯狂人精简的 win10 专业版系统](https://www.52pojie.cn/thread-733425-1-1.html)

2. Virtualbox 默认不支持 USB 3.0
   安装扩展

    先命令行安装对应版本，然后在 File->Preference->Extension 中加载下载的文件
    路径我当时是使用 find 命令找的，大致在 `/usr/share/virtualbox/extensions`

    https://wiki.manjaro.org/index.php?title=VirtualBox

3. Virtualbox 默认使用 legacy bios,需要更改为 EFI

    `Mechine->Settings->System` 面板的 `Enable EFI(spectial OSes only)`

    > 注：该项周围的三个都可以勾选上

4. Vbox 共享文件夹设置

    ![shared_folder](https://raw.githubusercontent.com/violetu/blogimages/master/20200929105210.png)

    注意：勾选 Auto-mount 自动挂载（否则你还要去手动挂载），Maek Permanent 永久共享（否则重启之后又没了，还需要再次设置）

## Manjaro Gnome

首先，下载好 iso 镜像文件，然后在 win10 虚拟机，右键 `Settings->Storage`, 增加 manjaro linux 的 ISO,然后选择将其作为 Live CD/DVD 加载：

![configuration](https://raw.githubusercontent.com/violetu/blogimages/master/20200928213923.png)

启动 win10,然后不停地按 `Esc` 进入 UEFI,选择 `Boot Manager`，回车

![Boot Manager](https://raw.githubusercontent.com/violetu/blogimages/master/20200928214421.png)

然后选择第二个 CD/ROM， 也就是我们的 Manjaro GNOME CD/DVD:

![20200928214534](https://raw.githubusercontent.com/violetu/blogimages/master/20200928214534.png)

驱动改成闭源驱动: no-free ，然后回车，等待启动

![manajro_start](https://raw.githubusercontent.com/violetu/blogimages/master/20200928214614.png)

启动之后，点击 Install launcher，然后安装：

其中，以下界面，可以验证我们是 EFI+GPT, 并且我们选择 `Manual partitioning`：

![20200928214822](https://raw.githubusercontent.com/violetu/blogimages/master/20200928214822.png)

### 分区

我是直接将 manjaro 挂载在 windows 的 100m 的 EFI 分区上的

1. 分区

    1. EFI 分区

        直接打开 Windows 的 100M EFI 分区，文件系统 fat32，内容：**keep（保留）**，挂载点`/boot/efi`。

    2. 根目录

        挂载点：`/`，文件系统 `ext4`

        存储系统根用户的配置信息与软件，由于 Manjaro 的软件市场默认是安装在非 home 下，因此建议留足够的大小

        1. `/var` 目录

            存储变量数据例如 spool 目录和文件，管理和登录数据,它通常被用作缓存或者日志记录，因此读写频繁。将它独立出来可以避免由于大量日志写入造成的磁盘空间耗尽等问题。

        2. `/home`

            将 `/home` 目录独立使得 `/` 分区可以单独重新划分，但是请注意你可以在 `/home` 没有独立分区的情况下你仍然可以在不修改 `/home` 目录内容的情况下重装 Manjaro Linux.

    3. `swap`,文件系统 `linuxswap`

        一般和你物理内存大小相当。

    关于分区略详细的介绍，可以看[7.Manjaro 文件结构和分区方案](https://www.jianshu.com/p/f9413171cb11)

2. 重装的时候，删除 efi 引导以及格式化磁盘

    [删除 efi 引导](https://blog.csdn.net/mtllyb/article/details/78635757)

当然，建议你也直接重新分一个 512 M 的区域用来存放 Linux 的引导，这样重装也方便
