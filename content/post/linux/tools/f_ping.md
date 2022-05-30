---
title: ping 与 fping
comments: true
toc: true
tags:
    - ping
    - network
description: 本文主要学习记录 ping 命令及其升级版 fping 命令。
summary: 本文主要学习记录 ping 命令及其升级版 fping 命令。
categories:
    - linux
    - tools
date: 2020-07-18 21:11:25
---

## ping

### 简介

`info ping` 可得：

> 'ping' uses ICMP datagrams to provoke a response from the chosen destination host, **mainly intending to probe whether it is alive**.
>
> The used datagram, of type 'ECHO_REQUEST', contains some header information and some additional payload, usually a timestamp. By a suitable choice of payload, different host or router properties are detectable, as the emitted datagram travels to its destination.

### 命令

通过 `ping --help` 我学到几个有用的选项：

`ping [options] <destination>`

1. `<destination>` dns name or ip address
2. `-c <count>` stop after `<count>` replies
3. `-i <interval>` seconds between sending each packet
4. `-w <deadline>` reply wait `<deadline>` in seconds
5. `-f <deadline>` flood ping

## fping

### 简介

`man ping` 可得：

> fping is a program like ping which uses the Internet Control Message Protocol (ICMP) echo request to determine if a target host is responding.
>
> fping differs from ping in that you can specify any number of targets on the command line, or specify a file containing the lists of targets to ping. Instead of sending to one target until it times out or replies, fping will send out a ping packet and move on to the next target in a **round-robin** fashion.
>
> In the default mode, if a target replies, it is noted and removed from the list of targets to check; if a target does not respond within a certain time limit and/or retry limit it is designated as unreachable.
>
> fping also supports sending a specified number of pings to a target, or looping indefinitely (as in ping ). Unlike ping, **fping is meant to be used in scripts**, so its output is designed to be easy to parse.

### 命令

通过 `man ping` 我学到几个有用的选项：

1. `-a, --alive`
   Show systems that are alive.

2. `-f, --file`
   Read list of targets from a file. This option can only be used by the root user. Regular users should pipe in the file via stdin:
   `fping < targets_file`

3. `-g, --generate addr/mask`
   Generate a target list from a supplied IP netmask, or a starting and ending IP. Specify the netmask or start/end in the targets portion of
   the command line. If a network with netmask is given, the network and broadcast addresses will be excluded. ex. To ping the network
   192.168.1.0/24, the specified command line could look like either:
   `fping -g 192.168.1.0/24`
   or
   `fping -g 192.168.1.1 192.168.1.254`

4. `-s, --src`
   Print cumulative statistics upon exit.

练习（我的内网 IP 为 `192.168.43.79`）：

```shell
$ fping -s 192.168.43.76 192.168.43.79
192.168.43.79 is alive
ICMP Host Unreachable from 192.168.43.79 for ICMP Echo sent to 192.168.43.76
ICMP Host Unreachable from 192.168.43.79 for ICMP Echo sent to 192.168.43.76
ICMP Host Unreachable from 192.168.43.79 for ICMP Echo sent to 192.168.43.76
ICMP Host Unreachable from 192.168.43.79 for ICMP Echo sent to 192.168.43.76
192.168.43.76 is unreachable

       2 targets
       1 alive
       1 unreachable
       0 unknown addresses

       1 timeouts (waiting for response)
       5 ICMP Echos sent
       1 ICMP Echo Replies received
       4 other ICMP received

 0.05 ms (min round trip time)
 0.05 ms (avg round trip time)
 0.05 ms (max round trip time)
        4.076 sec (elapsed real time)
```

shell 上显示四部分：

1. 存活主机 `192.168.43.79 is alive`；
2. ICMP 差错报文， **标准错误输出信息**，可以用 `2>/dev/null` 去除；

    每个地址最多询问 四次

3. 不可达主机：`192.168.43.76 is unreachable`
   `-a` 选项便是去除这一部分

4. 累计数据
   `-s` 选项的作用便是在退出前，输出累计统计数据。

`-g` 选项，根据起、始 IP 生成列表，遍历。

```shell
$ fping -g 192.168.43.76 192.168.43.79 2>/dev/null
192.168.43.79 is alive
192.168.43.76 is unreachable
192.168.43.77 is unreachable
192.168.43.78 is unreachable
```

常用：`fping -ag IP 或起始IP 2>/dev/null`
