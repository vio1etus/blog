---
title: 正确安装 Python 包
comments: true
toc: true
tags:
    - python
description: 如何在你的电脑上正确地安装 Python 的包，sudo pip？pip --user, 还是直接使用你的 Linux 自带的包管理器
categories:
    - python
    - issues
date: 2020-10-10 14:33:54
---

## sudo install vs pip install --user

先放结论：推荐使用`pip install --user package_name`

1. `sudo pip install`
   Both `sudo pip install` and its other common variant `sudo -H pip install` should not be encouraged because it is a security risk to use root privileges to use `pip` to install Python packages from PyPI (Python Package Index).

    当你使用 sudo 运行 pip 时，你以 sudo 权限运行`setup.py`。换句话说，你在以 sudo 权限运行一段从网络上下载的 Python 代码，存在极大的安全隐患。

2. `pip install --user`

    该命令将 python 包安装到本地用户目录，例如：`~/.local/lib/python`

## Arch Linux 上安装 Python 包

诸如 Arch Linux、Ubuntu 等发行版自带包管理器，例如： Arch Linux 的 pacman，而 Python 又常用 pip 作为其包管理器，那我们该使用哪一种呢？

一个原则：坚持用一种包管理器

建议：

1. 在可用的情况下，优先使用 pacman 包管理器安装 Python 包

    Python3: `sudo pacman -S python-'package'`

    例如：`pacman -S python-bs4`

    Python2: `sudo pacman -S python2-'package'`

    大多数包都可以通过 pacman 进行安装，当一些包既没有在 ArchLinux 仓库，又没有在 AUR 的时候，你需要下载 PKGBUILD 文件，编译然后使用 pacman 安装

    ```shell
    makepkg -s
    sudo pacman -U 'compiled-package'
    ```

1. pacman 安装不来（仓库里没有）的时候，使用 pip 安装

    当 AUR 中没有该包或者 PKGBUILD 不管用时，使用 pip 安装
    格式：`pip install --user package_name`

    Python3: `sudo pip install 'python-package'`
    Python2: `sudo pip2 install 'python-package'`

    注意：确保包只安装在你的家目录下，以避免与系统包混淆。

    > Never install anything with pip without --user, it will install files to the system and conflict with pacman

1. 对于 Python 项目(因为项目的依赖包不是常用)，所以一般使用虚拟环境

    例如：`virtualenv`

    `sudo pacman -S python-virtualenv`

## 参考资料

> 1. [Better to install PyPI packages using pacman or pip?](https://bbs.archlinux.org/viewtopic.php?id=139264)
> 2. [Pacman or pip?](https://www.reddit.com/r/archlinux/comments/dzbbgc/pacman_or_pip/)
> 3. [Is `sudo pip install` still a broken practice?](https://askubuntu.com/questions/802544/is-sudo-pip-install-still-a-broken-practice)
> 4. [sudo pip install VS pip install --user](https://stackoverflow.com/questions/29310688/sudo-pip-install-vs-pip-install-user)
> 5. [Recommended way of installing python packages on Arch](https://unix.stackexchange.com/questions/76389/recommended-way-of-installing-python-packages-on-arch)
