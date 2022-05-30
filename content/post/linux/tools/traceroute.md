---
title: traceroute & mtr
comments: true
toc: true
tags:
    - traceroute
    - network
description: 本文主要学习记录 traceroute 及其 mtr 的学习使用。
summary: 本文主要学习记录 traceroute 及其 mtr 的学习使用。
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## traceroute

> 'traceroute' prints a trace of the route IP packets are travelling to a remote host.

下面是我从 `man traceroute` 摘录出来的比较有价值的内容：

This program attempts to trace the route of an IP packet. it would follow to some internet host by launching probe packets with a small ttl (time to live), then listening for an ICMP "time exceeded" reply from a gateway.

We start our probes with a ttl of one and increase by one until we get an ICMP "port unreachable" (or TCP reset), which means we got to the "host", or hit a max (which defaults to 30 hops). **Three probes (by default)** are sent at each ttl setting and a line is printed showing the ttl, address of the gateway and round trip time of each probe.

If the probe answers come from different gateways, the address of each responding system will be printed. If there is no response within a certain timeout, an "\*" (asterisk) is printed for that probe.

We don't want the destination host to process the UDP probe packets, so the destination port is set to an unlikely value (you can change it with the -p flag). There is no such a problem for ICMP or TCP tracerouting (for TCP we use half-open technique, which prevents our probes to be seen by applica‐ tions on the destination host).

In the modern network environment the traditional traceroute methods can not be always applicable, because of widespread use of firewalls. Such firewalls filter the "unlikely" UDP ports, or even ICMP echoes. To solve this, some additional tracerouting methods are implemented (including tcp, udp), Such methods try to use particular protocol and source/destination port, in order to bypass firewalls (to be seen by firewalls just as a start of allowed type of a network session).

### 使用

`traceroute [-q nqueries][-M method] host`

`-q nqueries`: 指定 n 次查询，默认是 3 次。
`-M method`： 可以有 `-I`: Use ICMP ECHO for probes, `-T`:Use TCP SYN for probes

## mtr

`mtr` 是 my traceroute 的缩写。

-   > mtr combines the functionality of the traceroute and ping programs in a single network diagnostic tool.

### 使用

`mtr www.baidu.com`

结果的表头：`Host Loss% Snt Last Avg Best Wrst StDev`

表头参数解释：

-   主机 IP 地址
-   丢包率：Loss
-   已发送的包数：Snt
-   最后一个包的延时：Last
-   平均延时：Avg
-   最低延时：Best
-   最差延时：Wrst
-   方差（稳定性）：StDev

`-r, --report`
This option puts mtr into report mode. When in this mode, mtr will run for the number of cycles specified by the -c option, and then print statistics and exit.
