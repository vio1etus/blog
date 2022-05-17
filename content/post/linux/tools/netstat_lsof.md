---
title: Check for Listening Ports
comments: true
toc: true
tags:
    - netstat
    - network
    - ss
    - lsof
description: 本文主要学习记录 netstat，ss， lsof 命令，通过它们确定端口等信息
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## netstat

### 简介

由 `man netstat` 得:

> netstat - Print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships

### 使用

常见参数

1. -a 选项会列出 tcp, udp 和 unix 协议下所有套接字的所有连接。

    `netstat -a`

2. 只列出 TCP 或 UDP 协议的连接

    使用 -t 选项列出 TCP 协议的连接，可和 -a 选项配合使用
    `netstat -at`
    使用 -u 选项列出 UDP 协议的连接
    `netstat -au`

3. 禁用反向域名解析，加快查询速度

    默认情况下 netstat 会通过反向域名解析查找每个 IP 地址对应的主机名，会降低查找速度。n 选项可以禁用此行为，并且用户 ID 和端口号也优先使用数字显示。
    `netstat -na`

4. 只列出监听中的连接
   `-l` 选项可以只列出正在监听的连接（不能和 a 选项同时使用）

    `netstat -nl`

5. 获取进程名、进程号以及用户 ID
   `-p` 选项可以查看进程信息（此时 netstat 应尽量运行在 root 权限之下，否则不能得到运行在 root 权限下的进程名）

    `netstat -np`

6. 显示路由信息
   使用 `-r` 选项打印内核路由信息，与 route 命令输出一样。
   `netstat -rn`

7. 网络接口信息
   `-i` 选项可以输出网络接口设备的统计信息，结合上 `-e` 选项，等于 `ifconfig` 命令的输出。

8. 获取网络协议的统计信息
   `-s` 选项可以输出针对不同网络协议的统计信息，包括 Ip、Icmp、Tcp 和 Udp 等。

### 应用

1. 查看网关路由器地址

    `netstat -rn` 相当于 `route -n`

2. 找出程序运行的端口与 PID

    在用户权限下，并不是所有的进程都能找到，没有权限的会不显示。需要使用 root 权限查看所有的信息。
    `sudo netstat -nap | grep ssh`

3. 解除端口占用（杀死占用端口的程序）
   `netstat -nap|grep 端口`
   `kill -9 PID`

## ss 命令

netstat 从 proc 文件系统获取所需要的信息，而 ss 利用 netlink 机制，与内核通信，通过 TCP 协议栈中 tcp_diag 模块获取第一手的内核信息。

ss 旨在替代 netstat， ss 更为强大和高效，而且从 netstat 迁移至 ss， 几乎不需要费力。

ss 的 `-t, -u, -a, -n, -l, -p, -e` 选项均与 `netstat` 一致（注：`-r` 在 ss 中是尽力进行域名解析的意思）

## lsof

Linux 一切皆文件，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。例如：传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符，无论这个文件的本质如何，该文件描述符为应用程序与基础操作系统之间的交互提供了通用接口。因为应用程序打开文件的描述符列表提供了大量关于这个应用程序本身的信息，因此通过 lsof 工具能够查看这个列表对系统监测以及排错将是很有帮助的。

lsof（list open files）是一个列出当前系统打开文件的工具

常用选项：`-i`

1. 列出所有的网络连接
   `lsof -i`

2. 列出所有 tcp 网络连接信息（udp 同样使用，只需将 tcp 改为 udp）

    `lsof -i tcp`

3. 列出谁在使用某个端口

    `lsof -i :3306`

4. 列出谁在使用某个特定的 tcp 端口（udp 同样使用，只需将 tcp 改为 udp）

    `lsof -i tcp:10808`

## 参考资料

> 1. [How to Check for Listening Ports in Linux (Ports in use)](https://linuxize.com/post/check-listening-ports-linux/)
> 2. [netstat 和 lsof 的区别](https://www.cnblogs.com/pc-boke/articles/10012112.html)
> 3. [netstat 的 10 个基本用法](https://linux.cn/article-2434-1.html)
