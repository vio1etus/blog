---
title: iproute2
comments: true
toc: true
tags:
    - iproute2
    - network
description: 本文主要学习 iproute2 工具包中的 ip 工具使用。
summary: 本文主要学习 iproute2 工具包中的 ip 工具使用。
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## 简介

Linux 上管理网络的工具有两种，一个是 net-tools 中提供的 ifconfig，一个是 iproute2 提供的 ip addr。net-tools 起源与 BSD，自 2001 年起，Linux 社区就停止了对这个工具的维护，而 iproute2 旨在取代这个工具，并提供一些新功能。

iproute2 是 linux 下管理控制 TCP/IP 网络和流量控制的新一代工具包，旨在替代老派的工具链 net-tools，即大家比较熟悉的 ifconfig，arp，route，netstat 等命令。

虽然 net-tools 很早就不维护了，但是目前很多发行版还是默认安装着它，因此，我也没觉得怎么样。今天，由于需要测试 `ettercap`， 我怀疑是 Arch 官方仓库里面那个包打的有问题，我反馈了，还没修复，因此，直接上 kali， 看本机 IP 的时候，我发现 ifconfig 没了，于是一番查询，知道，kali 推荐使用的 `ip`， 弃用了 net-tools 了，因此我觉得有必要学习一波的 `ip` 命令了。

net-tools 通过 `procfs(/proc)` 和 `ioctl` 系统调用去访问和改变内核网络配置，而 iproute2 则通过 netlink 套接字接口与内核通信。

## 语法与使用

`man ip` 可得:

`ip [ OPTIONS ] OBJECT { COMMAND | help }`

`OBJECT` 是你要管理的对象类型，最常用的几个是：

-   `link(l)` 显示和修改网卡（例如启用/禁用某个网络设备。 修改 mac 地址）
-   `address(a)` 显示和修改 IP 地址
-   `route(r)` 显示和修改路由表
-   `neigh(n)` 显示和操作相邻对象（ARP 表）

`OBJECT` 可以以全名或者缩写的形式使用。可以通过 `ip OBJECT help`（将 OBJECT 更换为你要查询的对象） 来显示该对象的命令和参数列表。

注意：当配置网卡的时候，需要以 root 身份或者 `sudo` 权限来执行命令，否则会报错权限不足。

通过 `ip` 命令在终端进行的配置不是永久的，系统重启之后，所有的改变都将丢失。如果想要永久地配置，你需要编辑你所使用的发行版对应的特定的配置文件或者添加命令到开机脚本的方式。

## 显示和修改 IP 地址

命令格式： `ip addr [ COMMAND ] ADDRESS dev IFNAME`

`addr` 对象最常用的命令是 `show`, `add` 和 `del`。

### 显示所有 IP 地址的信息

显示所有的网卡以及 IP 地址类型列表：`ip addr show`（去掉 `show` 结果一样）
如果你想要只显示 IPv4 或者 IPv6 的地址，那么使用 `ip -4 addr` 或 `ip -6 addr`

### 显示单个网卡的信息

使用 `ip addr show dev` 后面跟着网卡名，例如： `eno1` 网卡

`ip addr show dev eth0`（去掉 dev 结果一样）

### 设置网卡 IP 地址

`ip addr add ADDRESS dev IFNAME`

`ADDRESS` 是你想要赋值给网卡的 IP
`IFNAME` 是网卡的名称

例如： 将子网掩码为 24 的 IP：`192.168.121.45` 赋值给网卡 `eno1`

`sudo ip address add 192.168.121.45/24 dev eno1`

### 赋值多个 IP 给同一个网卡

网卡和 IP 地址并不是一一对应关系。通过 ip 命令可以临时设置多 IP 同网卡，但是重启后设置也是会消失的。

1. 多网卡同 IP：
   通过绑定多个网卡作为一个逻辑网口并配置单个的 IP 地址，大幅提升服务器的网络吞吐性能。

2. 同网卡多 IP：

    在实施服务器虚拟化时，单个物理网卡往往是有多个 IP 地址，多个虚拟服务器在同一物理硬件上运行，每个虚拟服务器都需要自己的 IP 地址。

用法：直接为 网卡赋值多次不同 ip 即可，比如：

```shell
sudo ip address add 192.168.121.241/24 dev eno1
sudo ip address add 192.168.121.45/24 dev eno1
```

可以通过 `ip -4 addr show dev eth0` 或 `ip -4 a show dev eth0` 确认 IP 赋值操作已完成。

### 删除网卡的 IP 地址

语法： `ip addr dev ADDRESS dev IFNAME`

例如：移除 `eno1` 网卡的 `192.168.121.45/24` 地址：

`sudo ip address del 192.168.121.45/24 dev eno1`

## 显示网卡

命令: `ip link show`
该命令不会输出该网卡关联的 IP 地址。

获得某个网卡的信息：`ip link show dev`
例如：`ip link show dev eno1`

### 启用禁用网卡

命令： `ip link set dev {DEVICE} {up|down}`

例如：

```shell
ip link set dev eno1 down
ip link set dev eno1 up
```

### 修改网卡的 MAC 地址

命令：`ip link set dev eno1 address XX:XX:XX:XX:XX:XX`

## 显示路由表

命令： `ip route`

一般常用它来代替 `netstat -rn` 或 `route` 查看网关地址。
输出中 `via` 后面的地址即为网关地址（处于隐私考虑，我将其用 xxx 替换了）

```shell
$ ip route
default via xxx.xxx.xxx.xxx dev wlo1 proto dhcp metric 600
10.252.248.0/21 dev wlo1 proto kernel scope link src 10.252.254.67 metric 600
```

## 显示 ARP 缓存或者 ARP 表

`ip n` 或者 `ip neigh show`

可以用来代替

## MAC 欺骗的操作流程

```shell
ip link show eno1
## 根据上一步的结果查看你的原 MAC 地址，并记录
ip link set dev eno1 down
ip link set dev eno1 address XX:XX:XX:XX:XX:XX
ip link set dev eno1 up
```

## 参考资料

[Linux ip Command with Examples](https://linuxize.com/post/linux-ip-command/)
[一个网卡可以有 2 个 IP 地址吗？](https://www.it-swarm.asia/zh/ip/ %e4%b8%80%e4%b8%aa%e7%bd%91%e5%8d%a1%e5%8f%af%e4%bb%a5%e6%9c%892%e4%b8%aaip%e5%9c%b0%e5%9d%80%e5%90%97%ef%bc%9f/960518481/)
[多网卡同 IP 和同网卡多 IP 技术](https://www.jianshu.com/p/c3278e44ee9d)
