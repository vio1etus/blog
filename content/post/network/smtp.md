---
title: SMTP 协议
toc: true
description: 本文主要介绍 SMTP 协议，并通过使用命令行进行模拟以及实际的邮件发送来熟悉 SMTP 协议。
summary: 本文主要介绍 SMTP 协议，并通过使用命令行进行模拟以及实际的邮件发送来熟悉 SMTP 协议。
categories:
    - network
tags:
    - smtp
    - mail
date: 2020-09-14 15:58:50
---

## Introduction

本文将详细讲述 SMTP 的基础知识，并向你展示 SMTP 客户端与 SMTP 服务端之间的通信过程，最后，通过使用终端当作 SMTP 客户端，通过命令行的方式直接向 QQ 邮箱发送一封邮件。

如果你配置过邮件客户端的话，你应该了解 IMAP, POP 和 SMTP。 IMAP 和 POP 是用来从邮箱取回邮件的，而 SMTP 是用来发送邮件的。关于 IMAP 和 POP 协议，未来我会在另一篇文章中讲述。

SMTP（Simple Mail Transfer Protocol）是一个用来在互联网上高效可靠传输邮件的标准协议。它是一个面向连接的，基于文本的协议。它是基于 TCP/IP 协议的应用层协议，通常运行在 25 端口。理论上来讲，SMTP 可以被 TCP, UDP，甚至一些三方协议处理。RFC 定义如下：

> SMTP is independent of the particular transmission subsystem and requires only a reliable ordered data stream channel.

此外，互联网编号分配机构（IANA，Internet Assigned Numbers Authority）将 TCP 和 UDP 的 25 端口都分配给了 SMTP, 以便使用。然而，在实际中，大多数组织和应用仅选择实现 TCP 协议。

它采用 “存储转发”的方式来协调不同网络之间的邮件发送过程。在 SMTP 协议中，有一种更小的软件服务，叫做 Mail Transfer Agents (MTA, 邮件传输代理)。它帮助管理邮件的传输和最后向接收方邮箱的递送环节。SMTP 不仅定义了整个通信流，它还可以支持发送方站点、接收方站点或任何中继服务器上电子邮件的延迟发送。

SMTP 定义了一种通信协议，其规定了一封邮件如何从你的电脑的 MTA 到达目的 SMTP 服务器的 MTA（其中可能跨越多个网络）。

## Terminology

> **User Agent (UA)**: 用来发送和接收电子邮件的应用(Outlook, Mozilla Thunderbird, QQ 邮箱，Gmail etc.)
>
> **Mail Transfer Agent / Message Transfer Agent (MTA)**: 一个运行在 SMT P 服务器上的的进程，它将电子邮件转发给正确的收件人，并管理发送到用户邮箱的电子邮件。
> 通常情况下， MTAs 维护一个一个邮件队列，以便当远程服务器不可用时，可以安排重复交付尝试。MTA 通常包含一个专门的软件称为**mail delivery agent** 或 **message delivery agent (MDA)**。它负责将电子邮件传递到本地收件人的邮箱，而 MTA 更关注于 SMTP 服务器之间的邮件转发。

## Principle

当一个用户通过用户代理（例如：Thunderbird）发送邮件时， 客户端 SMTP 进程打开一个与在服务器（例如: smtp.gmail.com）的端口 25 上运行的 SMTP 进程的 TCP 连接。在最初的握手之后，客户端和服务器 SMTP 进程进行简短的请求-响应对话，以便发送电子邮件

## 反对

SMTP 是构建在端到端报文的传递之上。

1. 首先，SMTP 客户端通过目标主机的 SMTP 服务端的 25 端口与其联系。系统等待 `220 READY FOR MAIL` 消息报文
2. 一旦收到 200 报文，客户端发送 `HELO` 命令
3. 服务端返回报文：`250 Requested Mail Action OK`
4.

## References

> 1. [SIMPLE MAIL TRANSFER PROTOCOL](https://medium.com/team-rover/simple-mail-transfer-protocol-f55df5e2aebd)
> 2. [How Email Actually Gets Sent: A Look At SMTP](https://medium.com/@aryamansharda/how-email-actually-gets-sent-e1b2402b3a26)
> 3. [Is SMTP based on TCP or UDP?](https://stackoverflow.com/questions/16809214/is-smtp-based-on-tcp-or-udp)
