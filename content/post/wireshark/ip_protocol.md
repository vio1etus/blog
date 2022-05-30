---
title: IP协议
toc: true
tags:
    - 网络协议
description: 本文简单介绍了 IP 的 TTL 以及分片概念，并进行了抓包分析。
summary: 本文简单介绍了 IP 的 TTL 以及分片概念，并进行了抓包分析。
categories:
    - wireshark
date: 2019-07-07 16:41:07
---

目的：

1. IP 协议的基本概念以及它在 OSI 模型中的位置
2. 存活时间以及 IP 分片的基本概念
3. 学会利用 Wireshark 分析捕获文件中的 TTL 和 IP 分片
4. 掌握捕获 IP 数据包的方法

## 两个重要概念：

### TTL

TTL 是生存时间的意思，就是说这个 ping 的数据包能在网络上存在多少时间。当我们对网络上的主机进行 ping 操作的时候，本地机器会发出一个数据包，数据包经过一定数量的路由器传送到目的主机，但是由于很多的原因，一些数据包不能正常传送到目的主机，那如果不给这些数据包一个生存时间的话，这些数据包会一直在网络上传送，导致网络开销的增大。当数据包传送到一个路由器之后，TTL 就自动减 1，如果减到 0 了还是没有传送到目的主机，那么就自动丢失

TTL 的主要作用是避免 IP 包在网络中的无限循环和收发，节省了网络资源，并能使 IP 包的发送者能收到告警消息

### IP 分片

#### 原理

IP 协议理论上允许的最大 IP 数据报为 65535 字节（16 位来表示包总长）。但是因为协议栈网络层下面的数据链路层一般允许的帧长远远小于这个值，例如以太网的 MTU（即 Maximum Transmission Unit，最大传输单元）通常在 1500 字节左右。所以较大的 IP 数据包会被分片传递给数据链路层发送，分片的 IP 数据报可能会以不同的路径传输到接收主机，接收主机通过一系列的重组，将其还原为一个完整的 IP 数据报，再提交给上层协议处理。上图中的红色字段便是被设计用来处理 IP 数据包分片和重组的。

## 抓包分析

（这里使用其他旧版教程截图，因为我死活抓不到带多个分片的批数据包 emmm，注意：新版 Wireshark 的 偏移量 offset 在 Flags 的展开列表里，对，新版的 Flags 那里可以展开显示标志位及偏移）

控制标志：

> Bit 0: reserved, must be zero
> Bit 1:(DF) 0=May Fragment, 1=Don't Fragment.
> Bit 2:(MF) 0=Last Fragment, 1=More Fragments.

可以在显示过滤器中使用，下面给出几个常用功能语句示例：

ip.flags.mf == 1 过滤出一系列分片的数据帧除去最后一个的其他帧

ip.flags.mf == 0 过滤出一系列分片的数据帧的最后一个

ip.frag_offset > 0 过滤出分片数据帧中偏移量大于 0 的数据帧（即：除了第一个片帧之外的其他帧）

ip.frag_offset==0 过滤出第一片帧以及未分片的数据

ip.flags.mf== 1 && ip.frag_offset == 0 过滤出第一片帧

ip.flags.mf == 1 or ip.frag_offset > 0 过滤出出去第一片和最后一片的片帧

第一片：

![First Fragment](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/ip_fragment1.png)

Identification：用于片的重组，具有相同 idetification 的片重组为一个分组。

Flags 为 1，意味这后面还有更多片帧

Fragment offset 偏移为 0，意味着它是第一片帧

![Second Fragment](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/ip_fragment2.png)

Identification：与第一片相同

Flags 为 1，意味这后面还有更多片帧

Fragment offset 偏移为 1480，即：MTU（1500）- IP header（20），意味着它是第二片帧

![Third Fragment](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/ip_fragment3.png)

Identification：与第一片相同

Flags 为 0，意味这是一系列分片的最后一片帧

Fragment offset 偏移为 2960，即：1480 \* 2，意味着它是第三片帧，恰好分片分满结束。

大体完成，待完善...

参考资料:

> -   [IP 数据报分片——Fragmentation 和重组](https://my.oschina.net/xinxingegeya/blog/483138)
> -   [ip 相关显示过滤器语法](https://www.wireshark.org/docs/dfref/i/ip.html)
