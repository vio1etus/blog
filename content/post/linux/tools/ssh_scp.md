---
title: ssh 和 scp 命令
comments: true
toc: true
tags:
description: ssh 和 scp 命令使用记录
summary: ssh 和 scp 命令使用记录
categories:
    - linux
date: 2022-07-02 23:24:25
---

# SSH

## SSH 常用命令

```shell
git init
git add .
git commit -m "  "
git push origin master # git push <远程主机名> [本地分支名]:<远程分支名>
git push -f master master # 强制推送本地master到远程master
```

## 问题

1. ssh 访问 github 超时

`ssh: connect to host Build software better, together port 22: Connection timed out` 在 fork 了别人的仓库，clone 到本地修改之后，push 不上去了，本来以为网络或者代理问题，但搞了半天都不行，最后解决了：
方法：Switching remote URLs from SSH to HTTPS，从 SSH 协议修改成了 HTTPS 协议

[Managing remote repositories - GitHub Docs](https://docs.github.com/en/get-started/getting-started-with-git/managing-remote-repositories)

## SCP

`scp 源文件 目的地`
服务器下载文件到本地（如果为目录加 `-r`）:`scp username@server_ip:/path/filename /tmp/local_destination`

本地上传本地文件到服务器:`scp /path/local_filename username@server_ip:/path`

如需指定 ssh 端口，在 scp 后跟`-P` 选项，`scp -P123 commands`

如果出现服务器拒绝，可能是服务器的文件权限问题; 如果出现本地拒绝，可能是本地用户以及文件权限问题。

如果出现 `not a regular file`， 源服务器上不存在该文件或者该文件不是正常文件,出错原因：

1. 源与目的整反了
2. 目录未加 `-r`

服务器相互拷贝文件

1. 首先将自己服务器的 ssh 开启，确保当前用户可以使用
2. 然后，将复制的目的文件夹在默认用户下的权限提高
