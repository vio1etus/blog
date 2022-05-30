---
title: 数据链路层安全威胁
comments: true
toc: true
tags:
    - osi_sec
description: 数据链路层的安全威胁
summary: 数据链路层的安全威胁
categories:
    - network_sec
date: 2020-07-17 14:39:54
---

# 安全威胁

## MAC flooding

MAC 泛洪，也有一小部分资料称其为交换机毒化（Switch poisoning）

攻击方发送大量的具有不同的源 MAC 地址的帧， 由于交换机的自学习能力，这些新的 “MAC 地址-端口” 映射对会快速填充整个交换机表，导致之后合法的请求就没有了可用的空间， 结果交换机完全退化为广播模式，攻击者就可以用工具来嗅探这些被广播的帧，达到窃听数据的目的。

## MAC spoofing

MAC 地址欺骗

### 介绍

MAC 欺骗是一种用于使用指定 MAC 地址的技术。需要注意的是，网卡中已写死的 MAC 地址不可更改。另外，你可以使用一些工具来欺骗你的操作系统，使其认为网卡真的具有你指定的 MAC 地址。本质上来讲，MAC 欺骗就是更改计算机的身份。这在技术上是一件很容易的事情。

危害或者攻击目的： 使用 MAC 地址欺骗可对某个网络进行非授权访问。

局限：
MAC 地址欺骗技术的影响仅限于本地广播域。 与 IP 地址欺骗不同，发送者假冒其 IP 地址，以使接收者将响应发送到其他地方，而在 MAC 地址欺骗中，如果未配置交换机以防止 MAC 欺骗，则通常由欺骗方接收响应。

以上介绍主要来自于 [MAC 欺骗 Wikipedia](https://zh.wikipedia.org/wiki/MAC%E6%AC%BA%E9%AA%97)

### 操作方法

只要网卡的驱动程序支持修改网卡的物理地址，在 Linux 系统下修改 MAC 地址是非常方面的。

一般有以下两类方法：

#### 方法一，使用系统自带命令

基本步骤：

0. 查看记录你的原 MAC 地址，以便后面改回来
1. 禁用网卡
2. 设置网卡的 MAC 地址
3. 启用网卡

查看自己的网卡名称: `ifconfig`, `lo` 是本地回环，`wlo1` 是无线网卡， `eno1` 或者 `ethe0` 之类的就是你的网卡名。这里我的网卡名称为 `eno1`，所以下面演示的命令中的 `eno1` 表示网卡名称。

ether 表示是以太网类型的网卡，“bdcdaaabccff“ 是随机设置的一个地址，使用 “ifconfig eno1” 即可查看该网卡的详细信息，从而判断 MAC 地址修改是否生效。

使用该方法有几点不方便的是：

1. 用户需要自行保存原 MAC 地址，然后再用相同的方法恢复
2. 每次需要操作三个步骤
3. 不知道网卡销售商的前三个字节标志，如果随机改的话，有的网络或网站不认可。

工具一: `ifconfig`

`ifconfig` 三条命令：

```shell
ifconfig
## 根据上一步的结果查看你的原 MAC 地址，并记录
ifconfig eth0 down
ifconfig eth0 hw ether 0000aabbccff
ifconfig eth0 up
```

工具二： `iproute2`

该工具可能有的发行版没有，需要自己安装， Arch 系 Linux 安装命令: ``

```shell
ip link show eno1
## 根据上一步的结果查看你的原 MAC 地址，并记录
ip link set dev eno1 down
ip link set dev eno1 address XX:XX:XX:XX:XX:XX
ip link set dev eno1 up
```

#### 方法一，使用专门的 MAC 地址修改工具

专用工具: `macchanger`, 一键搞定

```shell
$ macchanger --help
GNU MAC Changer
Usage: macchanger [options] device

  -h,  --help                   Print this help
  -V,  --version                Print version and exit
  -s,  --show                   Print the MAC address and exit
  -e,  --ending                 Don't change the vendor bytes
  -a,  --another                Set random vendor MAC of the same kind
  -A                            Set random vendor MAC of any kind
  -p,  --permanent              Reset to original, permanent hardware MAC
  -r,  --random                 Set fully random MAC
  -l,  --list[=keyword]         Print known vendors
  -b,  --bia                    Pretend to be a burned-in-address
  -m,  --mac=XX:XX:XX:XX:XX:XX  Set the MAC XX:XX:XX:XX:XX:XX
```

首先，可以看一下当前电脑的 MAC 地址和网卡固件上的 MAC 地址:

```shell
$ macchanger -s eno1
Current MAC:   xx:xx:xx:xx:xx:xx (unknown)
Permanent MAC: xx:xx:xx:xx:xx:xx (unknown)
```

然后，使用特权用户设置随机设置一个同 vendor 的 MAC 地址，然后实施你进行 MAC 欺骗的目标操作。

使用非特权用户运行会报错:`[ERROR] Could not change MAC: interface up or insufficient permissions: Operation not permitted`

```shell
$ sudo macchanger -A eno1
[sudo] password for violetv:
Current MAC:   xx:xx:xx:xx:xx:xx (unknown)
Permanent MAC: xx:xx:xx:xx:xx:xx (unknown)
New MAC:       dd:dd:dd:dd:dd:dd (Alcatel-Lucent)
```

最后，恢复原 MAC，搞定。

```shell
$ sudo macchanger -p eno1
Current MAC:   dd:dd:dd:dd:dd:dd (Alcatel-Lucent)
Permanent MAC: xx:xx:xx:xx:xx:xx (unknown)
New MAC:       xx:xx:xx:xx:xx:xx (unknown)
```

## ARP spoofing

-   [ ] spoofing links

## VLAN Hopping

虚拟局域网跳跃攻击

VLAN Hopping 漏洞允许攻击者绕过为划分主机而构建的任何第 2 层（数据链路层）限制。如果网络管理员对交换机端口进行了正确配置，那么攻击者必须通过路由器或其他第 3 层设备才能访问其目标。然而，在许多网络中都没有合理的进行 VLAN 规划，或者对 VLAN 进行了错误配置，这样一来攻击者就能够进行该漏洞利用。

VLAN Hopping 的两种方法，分别是“交换欺骗”（Switched Spoofing）和“双重标记”（Double Tagging）

我们在这里并不是对设备存在的漏洞进行利用，而是针对于协议和配置存在的漏洞。

[VLAN Hopping: How to Mitigate an Attack](https://cybersecurity.att.com/blogs/security-essentials/vlan-hopping-and-mitigation)

[上文的中文翻译对照\_VLAN Hopping 攻击技术与缓解措施](https://www.4hou.com/posts/X5Qo)

## 参考资料

[MAC address spoofing](https://wiki.archlinux.org/index.php/MAC_address_spoofing)
[MAC 地址欺骗](https://www.cnblogs.com/Dio-Hch/p/11868758.html)
