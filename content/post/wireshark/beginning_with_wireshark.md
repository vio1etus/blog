---
title: 一. Wireshark初识
description: 本文简要介绍了Wireshark，并阐释了其抓包原理
summary: 本文简要介绍了Wireshark，并阐释了其抓包原理
toc: true
tags:
    - 渗透
    - 抓包
categories:
    - wireshark
date: 2019-07-01 16:51:58
---

# 简介

Wireshark 是目前全球使用最广泛的开源抓包软件(全平台支持)，用于网络分析。类似抓包软件： Fiddler、Burp Suite、Sniffer、Omnipeek、Httpwatch
国内类似 WireShark 的有[科来网络分析系统](http://www.colasoft.com.cn/)

相关学习网址：
[官方文档](https://www.wireshark.org/docs/)、 [书籍](https://www.chappell-university.com/books)、 [维基](wiki.wireshark.org)、[官方论坛](https://ask.wireshark.org/questions/)、[捕获过滤器](http://www.tcpdump.org/manpages/pcap-filter.7.html)、[捕获过滤器语法 wiki](https://wiki.wireshark.org/CaptureFilters)、[显示过滤器语法](https://www.wireshark.org/docs/dfref/)、[显示过滤器语法 wiki](https://wiki.wireshark.org/DisplayFilters)，[官网 wiki 各种协议的例子](https://wiki.wireshark.org/SampleCaptures)(后面分析协议，如果你自己抓不到或懒得抓，可以去这里下载)

# 抓包原理

## 一. 网络原理

### 1. 本机环境

#### 网卡的混杂模式

1. 是一种允许网卡能够查看到所有流经网络线路数据包的驱动模式。

2. 非混杂模式网卡，收到目的 MAC 不是自己的帧，不会向上传送，会直接丢弃。

3. 混杂模式的网卡，会把所有收到的数据包接收，向上传送，从而可以被数据包嗅探器捕获并进行分析。

4. 现在大多数网卡一般都支持混杂模式

5. Wireshark 软件自带混杂模式驱动，可以直接把网卡切换成混杂模式

6. 对于一个未配置混杂模式的网卡，假设 PC1 通过交换机与 PC2 相连，

    对于 PC1 来说，它可以接收三种流量：目的 MAC 为自己，广播以及组播

本家环境可以使用网卡的混杂模式进行抓取，目前所有 PC 的网卡都支持混杂模式，（但是要有驱动的），如果一个网卡没有配置混杂模式，可以收到的流量类型：

直接抓包，抓本机网卡的流量。如下图所示，在本机安装 Wireshark，绑定网卡，不需要借助交换机、集线器、路由器等第三方设备，抓取本机电脑网卡上进出的流量，这是一种最基本的抓包方式。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/host.png)

### 2. 集线器环境

同一个集线器的众多端口下的机器处于同一冲突域，如果不处于集线器环境，可以使用集线器接出的方式抓包，如果处于集线器环境，即：如下图所示，三台电脑 PC1、PC2、PC3 通信，PC1 装有 Wireshark，三台电脑连接到同一台集线器，集线器属于物理层产品，掌管物理比特传输，看不懂 MAC 地址和 IP 地址，因此三台电脑处于同一个冲突域，即这三台机器均处于

[^可视范围]: 在数据报嗅探器中能够看到通信流量的主机范围，也可以说是一个冲突域

一台电脑可以抓到同一集线器下其他电脑发送过来的数据包，这是一种比较典型的被淘汰的老网络拓扑结构。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/hub.png)

### 3. 交换机环境

交换机环境下的可视范围（冲突域）仅限于你所接入的端口，上一篇文章中已经讲过交换机会隔离冲突域，

#### 1) 端口镜像（Port mirroring）

PC2 与 PC3 通信，一般情况下（MAC 地址表中有对应的 MAC 表项），PC1 无法抓到二者之间的数据包。（非一般，即：没对应 MAC 表项时，可以抓到）。这种情况下，可以在交换机做端口策略（SPAN/SPAN）。

SPAN 技术大体分为两种类型，本地 SPAN 和远程 SPAN. ----Local Switched Port Analyzer (SPAN) and Remote SPAN (RSPAN)，实现方法上稍有不同。 利用 SPAN 技术我们可以把交换机上某些想要被监控端口（以下简称受控端口）的数据流 COPY 或 MIRROR 一 份，发送给连接在监控端口上的流量分析仪（并不会影响[源端口](https://baike.baidu.com/item/源端口)的数据交换），比如 CISCO 的 IDS 或是装了 SNIFFER 工具的 PC. 受控端口和 监控端口可以在同一台交换机上（本地 SPAN），也可以在不同的交换机上（远程 SPAN）。该功能往往被用来实现故障定位、流量分析、流量备份等。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/port%20mapping.png)

#### 2) 网络分流器

网络分流器是一种专门为了网络分析而设计的特殊硬件，通常用于网络入侵检测系统 （IDS）。它是一个独立的硬件，它不会对已有网络设备的负载带来任何影响，这与端口镜像等方式相比具有极大的优势。

它是一种在线（in-line）的设备，简单一点说就是它需要串接到网络中。

#### 3) ARP 欺骗（ARP spoofing）

是一种在交换式网络中进行监听的高级技术，一般需要借助第三方工具软件来一起完成（Cain&abel 工具软件）

1） PC2 收到含有 PC3 的数据报，但是不知道其 MAC 地址，便通过 ARP 协议进行广播。

2）此时 PC1 做 ARP 欺骗，不断地向 PC2 回复：我是 PC3，对应的 MAC 是 XXX，就可以毒化 PC2 的 ARP 表（ARP 缓存表基于"后到优先"原则，IP 与 MAC 的映射信息能被覆盖），这样，PC2 的 ARP 表上便将表项上 PC3 的 MAC 地址处对应成了 PC2 的 MAC 地址。

3）从此时到该错误表项被更新正确之前，PC2 想与 PC3 通信，就要经过 PC1，再由 PC1 决定是否将数据包发给 PC3。PC2 和 PC3 的通信数据流被 PC1 拦截，形成了典型的"**中间人攻击**"。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/arp_spoofing.png)

#### 4) MAC 泛洪（MAC flooding）

MAC 泛洪并不是针对网络中任何主机的攻击方式，而是一种针对其中交换机的攻击方式。但是，受害的是网络中的主机。

原理：攻击者发送大量的具有不同地址的垃圾以太网帧，来消耗交换机用来存储 MAC 表的内存，直到正确合法的 MAC 表项被非法的垃圾以太网帧对应的 MAC 表项挤出 MAC 表，这样交换机就不能将到来的数据转发到指定的端口（即：还要使用 ARP 协议，将到来的数据包进行广播，即：到来的数据被发送到所有端口，也就是泛洪），这样攻击者就实现流量劫持了

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/mac_flooding.png)

使用网络分流器

小结：交换机环境的这三种方式，第一种可以说是维护安全的做法，后两种算是黑客攻击吧。

## 二. 底层原理

首先，我们简单了解一下网络嗅探器的工作原理

1. 收集

    数据包嗅探器从网络线缆上收集原始二进制数据。_通常情况下，通过将选定的网卡设置成混杂模式来完成抓包。在这种模式下，网卡将抓取一个网段上所有的网络通信流量，而不仅是发往它的数据包。_

2. 转换

    将捕获的二进制数据转换成可读形式。高级的命令行数据包嗅探器就支持到这一步骤。到这步，网络上的数据包将以一种非常基础的解析方式进行显示，而将大部分的分析工作留给最终用户。

3. 分析

    对捕获和转换后的数据进行真正的深入分析。数据包嗅探器以捕获的网络数据作为输入，识别和验证它们的协议，然后开始分析每个协议特定的属性。

下面我们介绍一下 Wireshark 的原理

首先，数据流动方向：网卡（接收） -> CPU (处理)-> Wireshark。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/principle.png)

1. libpcap（Packet Capture Library）数据包捕获函数库，是 Unix/Linux 平台下的网络数据包捕获函数库（对应 WinPcap 为 Window 下的）。它是一个独立于系统的用户层包捕获的 API 接口，为底层网络监测提供了一个可移植的框架。
2. Capture 为抓包引擎，利用 libPcap / WinPcap 从底层抓取网络数据包，libPcap / WinPcap 提供了通用的抓包接口，能从不同类型的网络接口抓取。
3. Wiretap 提供格式支持，从抓包文件中读取数据报，支持多种格式。
4. Core 是核心引擎，通过函数调用将其他模块连接在一起，起到联动调度的作用
5. GTK1/2 为图像处理工具，处理用户的输入输出显示

# 界面及功能简介

## 界面介绍

安装就不说了，一路默认下一步就行了。博主用的是 Windows 上最新版 3.0.2，打开软件，首先选择一个抓包的地址（好像是这么说 ☺️），我这里是 WiFi 上网，选择 WLAN 左键连续点击两下，进入抓包主界面，不多说了，一图胜千言。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/入门/region.png)
简要介绍一下重要的区域块吧，这里说一下，感觉要把 Wireshark 玩精，过滤器和统计是必须要好好掌握的。

### 其他

系统配置为菜单栏 -> 编辑 -> 首选项。首选项可以调整主界面的布局，不同协议包的配色，文件，过滤等各种设置。

Appearance(外观)：这些选项决定了 Wireshark 列的显示数据以及是否显示某列、显示捕获数据的字体和特殊情况的颜色以及前景主窗口的布局。可以增加列，比如增加一列用来显示 TCP 窗口大小：tcp.window_size 或显示 TTL：ip.ttl
Capture（捕获）：对捕获数据包的方式进行特殊设置，比如默认使用的设备、是否默认使用混杂模式、是否实时更新 Pack List 面板等。
Expert（专家模式）：
Name Resolutions（名字解析）：这些设定可以开启 Wireshark 将地址（MAC、网络以及传输名字解析）解析成更加容易辨别的名字这一功能。
Filter Button（过滤按钮）：可以做过滤的标签，在过滤的时候直接使用此标签。
Protocols（协议）：列出部分能够被解码的所有数据包，这部分协议的选项可以被更改，除非有特殊的原因，否则不要去修改这些协议选项，保持默认值就好。
Statistics（统计）：提供了 Wireshark 统计功能的设定选项。
视图中可以调整界面的显示的区块，也可以在“着色规则”下查看/调整不同协议及特殊数据的配色方案。
跳转中是一些快捷键，常用的记住会用就好，记不住也没关系。
数据报列表的表项，在上面右键，可以自己调整和修改，一般默认，如果要查看一些详细的信息，比如 TTL 等可以加到列表上去
工具栏的话，把鼠标箭头移到某个图标上会显示描述功能的文字
Packet List（数据包列表区）：显示当前捕获的所有数据包，其中包括数据包序号、捕获相对
时间、源目标地址、协议、概况信息等。
Packet Details（数据包详细区）：显示数据包的内容，展开可以看到数据包捕获的全部内容。
Packet Bytes（数据包字节区）：显示一个数据包未经处理的原始样子（16 进制和 ASCII 码形式），也就是在链路上传播的样子。

### 捕获

1. 打开选项，默认处在“输入”选项卡

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/capture_option1.png)

这里讲一下，过滤器的分类：捕获过滤器与显示过滤器。

当你使用某个规则较多时，可以将其加入规则列表，以便后续使用

两种过滤器的目的是不同的。
捕捉过滤器是数据经过的第一层过滤器，它用于控制捕捉数据的数量，以避免产生过大的日志文件。一般在流量比较大的网络中，使用它可以避免抓到太多你不需要的包，使 Wireshark 卡死等，小的也可以用 emm。
显示过滤器是一种更为强大（复杂）的过滤器。它允许您在日志文件中迅速准确地找到所需要的记录。即：从你抓取的包中选择哪些包要显示在界面上，哪些包不显示。

你在主界面看到的数据报过滤栏是显示过滤器，你在捕获选项中看到的“捕获过滤器”以及打开选项后看到的“所选择接口的捕获过滤器”都是指捕获过滤器。

两种过滤器使用的语法是完全不同的。

注意：两种过滤器语法是有些不相同的，但是如果你学过任何一门编程语言，相信你会很容易上手这个，下面给出链接：[捕获过滤器语法](https://wiki.wireshark.org/CaptureFilters)、[显示过滤器语法](https://wiki.wireshark.org/DisplayFilters)

接着讲上面的界面，“在所有接口上使用混杂模式”是指一台机器的网卡能够接收所有经过它的数据流，而不论其目的地址是否是它。而非混杂模式，则只接受 MAC 地址为自己的数据流。一般开启它。

可以在这填写捕获过滤语句（语法正确会显示绿色，错误显示红色），然后点击确定，开始捕获符合你语法的包。

2）下面看看“选项”选项卡，输出选项卡自己试试，比较简单

![选项](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E5%85%A5%E9%97%A8/capture_option3.png)

显示选项：

1. 实时更新分组列表：Wireshark 抓包主窗口会实时显示抓取到的所有数据包
2. 实时捕获自动滚屏：Wireshark 抓包主窗口会在实时抓取数据包时滚动
3. 实时捕获期间显示捕获信息：选中之后，点击确认，会弹出一个显示各协议（ICMP，TCP，IP，UDP，其他）流量波动的线性波动图，可以在捕获的同时，看各协议大体趋势。

解析名称：

1. 解析 MAC 地址就是解析其所隶属的厂商名
2. 解析网络名称，就是解析 IP 向对应的主机名 / 域名，wireshark 会发大量的 DNS 请求（向 wireshark 所在主机的 DNS）去解析网络名称，因此如果网络较大，会耗费大量系统资源。
3. 解析传输层名称：解析 TCP/UDP 端口号相对应的应用程序名

### 统计

是很重要的模块，单独拿一篇文章讲一下

参考资料：

> -   [图解 ARP 协议（一）](https://zhuanlan.zhihu.com/p/28771785)

> -   [图解 ARP 协议（二）ARP 攻击篇](https://zhuanlan.zhihu.com/p/28818627)
