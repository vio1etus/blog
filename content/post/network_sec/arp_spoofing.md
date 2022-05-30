---
title: ARP 欺骗
comments: true
toc: true
description: ARP 欺骗的原理与复现
summary: ARP 欺骗的原理与复现
categories:
    - network_sec
date: 2020-07-17 10:39:54
---

ARP 协议的有效性基于这样一个前提: 即： 网络上的节点是诚实的，节点不会响应与其不相关的 ARP 请求， 节点也不会发送不正确的 IP-MAC 映射的 ARP 响应。但实际上并不是这样。

## 简介

无论节点收到 ARP 请求还是响应，该节点均会更新其 ARP 表。若无对应表项，则添加该表项; 反之，则更新对应的表项。

ARP spoofing 攻击：攻击者通过发送不正确的 IP-MAC 映射信息， 结果导致局域网内被攻击主机发送给网关的流量信息实际上都发送给攻击者，这样就会造成窃听以及中间人攻击。

欺骗方式：

1. 欺骗主机作为“中间人”，定期发送 ARP 响应，被欺骗主机的数据都经过它中转一次，这样欺骗主机可以窃取到被它欺骗的主机之间的通讯数据；

2. 让被欺骗主机直接断网。
   通过 `arpspoofing` 对受害者主机进行 arp 欺骗到自己或者别的主机，但是不转发受害者主机发送来的流量，因此，实现断网的效果。

解决方案：

1. 由网关等设备或者软件定期发送正确的 ARP 信息（没啥用）
2. 静态绑定 ARP 条目，在网关和 PC 上双向绑定
3. DAI（彻底解决）

ARP 欺骗的双向性：

ARP 本质是重定向，即通过欺骗性的 MAC - IP 映射将数据引导到某个节点，而重定向不一定是一种攻击。
例如：使用两台服务器提供网络服务，其中一台作为备用机器。当主务器失败时，可以通过 ARP 欺骗将数据包定向到备份服务器，实现用户透明的切换。

## 实战

### 实验环境

### 本实验在虚拟机中完成（实际效果与真实主机效果无异）

1. 实验要求：两个主机的网络必须同在一个局域网内，否则无法实现。
   Manjaro Linux 系统主机一台（受害者的主机）, IP: 10.252.254.241/21
   Kali 系统主机一台（虚拟机，攻击者的主机）, IP: 10.252.252.250/21
   网关 IP：10.252.248.1/21

2. 攻击者主机开启流量转发

    ```shell
    sudo su
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```

    参考 [How to Disable/Enable IP forwarding in Linux](https://linuxconfig.org/how-to-turn-on-off-ip-forwarding-in-linux)

### 工具使用

工具要求： `fping`， `arpspoofing`, `ettercap`

1. `fping` 扫描查看内网在线主机

    `fping -asg 网关地址/子网掩码`
    具体命令含义可以见我的博客链接： - [ ] blog link

2. `arpspoof` 进行 ARP 欺骗
   arch linux 安装 `sudo pacman -S dsniff`
   查看使用办法 arpspoof -h
   Usage: arpspoof [-i interface][-c own|host|both] [-t target][-r] host
   对应： `arpspoof -i 网卡 -t 目标Ip 网关`

    攻击者向受害者主机发送的 ARP 响应，伪造网关 IP 为源 IP, 自己（攻击者的主机）的，MAC 地址为源 MAC 地址。这样受害者主机在访问网络时，就会误将攻击者作为网关，从而将数据帧转发到攻击者。此时如果攻击者不进行任何其他操作，受害者主机就会处于断网状态；如果攻击者转发查看流量包，就可以进行监听或者中间人攻击了。

3. `ettercap` 嗅探流量，中间人攻击
   `sudo ettercap -Tq -i 网卡`

### 演示

1. kali 作为攻击者，首先进行 arp 欺骗攻击
   命令：`arpspoof -i eth0 -t 10.252.254.241 10.252.248.1`
2. 然后我们发现被攻击者连不上网了
3. kali 攻击者，再打开 `ettercap` 进行嗅探转发，
   命令：`ettercap -Tq -i eth0`
4. 受害者可以上网，攻击者捕获受害者的所有数据包。

## 实验过程遇到的问题

1. arch linux 源的 `ettercap` 包本身有问题
2. 新版 kali 的变化
   默认非 root 用户， 普通用户名密码均变为了 `kali`， 导致很多工具在普通用户权限下运行，**直接显示命令不存在**， 只有拥有 root 权限时才能使用。
3. `arpspoof` 命令存在于 `dsniff` 包中

## 参考资料

> 1. [ARP 断网攻击和欺骗实现 kali](https://blog.csdn.net/qq_33936481/article/details/51286486)
> 2. [unable to locate package Arpspoof [closed]](https://security.stackexchange.com/questions/189203/unable-to-locate-package-arpspoof)
