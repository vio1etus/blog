---
title: 网络层
comments: true
toc: true
description: 网络层内容学习
summary: 网络层内容学习
categories:
    - network_sec
date: 2020-07-17 10:39:54
---

## IP Address Spoofing

根据 IP 协议， 路由器只是根据 IP 分组的目的 IP 地址来确定该 IP 分组从哪一个端口发送的，而不关心该 IP 分组的源 IP 地址。基于该原理，任意节点均可以构造 IP 分组。

IP 欺骗攻击主要用于两种网络攻击方式: 拒绝服务攻击和基于 IP 地址认证的网络服务中。

### 实现

1. scapy（依赖于 tcpdump）工具或者 Python 的 scapy 模块，轻易地伪造 IP
   [利用 Linux scapy 伪造数据包攻击](https://www.jianshu.com/p/cc7fa0d64c15)
    - [ ] scapy 学习
2. 可以直接自己通过 raw socket 编程进行伪造 IP。

### 合法用途

使用具有错误源 IP 地址的数据包并不总是用于恶意企图。例如，在网站性能测试，成百上千的“用户”（虚拟用户）可能被创建，每个都在执行测试网站的测试脚本，以模拟当系统上线和大量用户立刻登录时会发生什么事。

由于每个用户都会有自己的 IP 地址，商业测试产品（如 HP LoadRunner、WebLOAD 等）可以使用 IP 欺骗，同样允许每个用户自己的“返回地址”。

-   [ ] 未完待续

## 参考资料

[IP 地址欺骗](https://zh.wikipedia.org/wiki/IP%E5%9C%B0%E5%9D%80%E6%AC%BA%E9%AA%97#%E5%BA%94%E7%94%A8)

[Packet Sniffing and Spoofing Lab](http://www.cis.syr.edu/~wedu/seed/Labs_16.04/Networking/Sniffing_Spoofing/Sniffing_Spoofing.pdf)
