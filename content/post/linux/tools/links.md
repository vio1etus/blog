---
title: 软硬链接
comments: true
toc: true
tags:
    - hardlink
    - softlink
description: 本文主要记录学习硬链接和符号链接（软链接）
categories:
    - linux
    - tools
date: 2020-07-23 23:11:25
---

## 文件

文件系统中的数据分为两类，分别是用户数据和元数据。
用户数据(user data)：指文件数据块 (data block)，数据块是记录文件真实内容的地方
元数据(metadata)：指文件的附加属性，如文件大小、创建时间、所有者等信息

在 Linux 中，元数据中的 inode 号（inode 是文件元数据的一部分但其并不包含文件名，inode 号即索引节点号）才是文件的唯一标识而非文件名。文件名仅是为了方便人们的记忆和使用，系统或程序通过 inode 号寻找正确的文件数据块。下图为展示了程序通过文件名获取文件内容的过程。

![filename_open_file](https://raw.githubusercontent.com/violetu/blogimages/master/20200723213341.png)

## 链接文件

为解决文件的共享使用，Linux 系统引入了两种链接：硬链接和符号链接，它们是两种不同的引用文件的方式。

### 软硬链接区别

![hard_softlink](https://raw.githubusercontent.com/violetu/blogimages/master/20200723213446.png)

![hard_softlink](https://raw.githubusercontent.com/violetu/blogimages/master/20200723220611.png)

## 符号链接

符号链接：是一个存储文件（夹）位置的快捷方式，操作系统找这个快捷方式（文件，目录名），然后再引用到

`ls -i` 查看 inode 号

创建： `ln -s filename soft_ln_nane`

1. 软链接有自己的文件属性及权限等；
2. 可对不存在的文件或目录创建软链接；
3. 软链接可交叉文件系统；
4. 软链接可对文件或目录创建；
5. 创建软链接时，链接计数 i_nlink 不会增加；
6. 删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

## 硬链接

硬链接是有着相同 inode 号，仅文件名不同的文件，因此硬链接存在以下几点特性：

1. 文件有相同的 inode 及 data block；
2. 只能对已存在的文件进行创建；
3. 不能交叉文件系统进行硬链接的创建；
   inode 号仅在各文件系统下是唯一的，当 Linux 挂载多个文件系统后将出现 inode 号重复的现象，因此硬链接创建时不可跨文件系统。
4. 不能对目录进行创建，只可对文件创建；
5. 删除一个硬链接，并不等于删除文件， 直到文件的引用计数为 0 时，文件才会被删除。

## 参考文章

[理解 Linux 的硬链接与软链接](https://www.ibm.com/developerworks/cn/linux/l-cn-hardandsymb-links/index.html)
