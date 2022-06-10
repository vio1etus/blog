---
title: scp 命令使用
comments: true
toc: true
tags:
description: 本机与服务器 scp 复制
summary: 本机与服务器 scp 复制
categories:
    - linux
date: 2022-05-29 14:48:25
---

从服务器下载文件到本地 （如果为目录加 `-r`）: `scp username@server_ip:/path/filename /tmp/local_destination`

上传本地文件到服务器:`scp /path/local_filename username@server_ip:/path`

如需指定 ssh 端口，在 scp 后跟`-P` 选项，`scp -P123 commands`

如果出现服务器拒绝，可能是服务器的文件权限问题; 如果出现本地拒绝，可能是本地用户以及文件权限问题。

如果出现 `not a regular file`， 源服务器上不存在该文件或者该文件不是正常文件,出错原因：

1. 源与目的整反了
2. 目录未加 `-r`

服务器相互拷贝文件

1. 首先将自己服务器的 ssh 开启，确保当前用户可以使用
2. 然后，将复制的目的文件在默认用户下的权限提高

`scp 源 目的`
