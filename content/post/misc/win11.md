---
title: Windows 11 尝鲜
comments: true
tags:
    - misc
description: 看着各方都在炫耀 Win11，不得试试？
summary: S看着各方都在炫耀 Win11，不得试试？
categories:
    - misc
date: 2022-07-02 23:59:29
---

一开始希望直接原系统升级，就不用备份数据了，但是好像原 Win10 系统本来就更新不顺畅有问题，折腾了一天多，也没搞成。后来干脆，直接重装，世上无难事，只怕有心人。
相关工具及链接：

通过该工具修改 Win11 的 ISO 实现让过 TPM 使我的旧机子也能装上：

[AveYo/MediaCreationTool.bat: Universal MCT wrapper script for all Windows 10/11 versions from 1507 to 21H2!](https://github.com/AveYo/MediaCreationTool.bat)

重装 Win11 之后，更新还是检测你机子不满足要求，可直接用下面软件开始 Dev channel 预览版更新。
[abbodi1406/offlineinsiderenroll: OfflineInsiderEnroll - A script to enable access to the Windows Insider Program on machines not signed in with Microsoft Account](https://github.com/abbodi1406/offlineinsiderenroll)

鼠标，显卡之类的驱动，如果有不正常的，找到了我机子的官网下载:
[HP Pavilion Power 15-cb000 笔记本电脑 软件和驱动下载 | 惠普 ® 客户支持](https://support.hp.com/cn-zh/drivers/selfservice/hp-pavilion-power-15-cb000-laptop-pc/15551388)

据说 rufus 也支持直接写 Win11 no tpm 了，还可以制作 Win to go，真是装机小能手。
[Rufus - Create bootable USB drives the easy way](https://rufus.ie/en/)
