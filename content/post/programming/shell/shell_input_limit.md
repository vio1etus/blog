---
title: shell input 4096-limit
comments: true
tags:
    - shell
description: 学习并记录一下 shell 命令行输入的大小限制
summary: 学习并记录一下 shell 命令行输入的大小限制
categories:
    - programming
date: 2020-07-23 19:11:25
---

## 问题

Linux shell 命令行每次收取 4096 个字符的输入(4kB)，输入的字符个数超过该数字后面的被丢弃。原因是 shell 的输入是为人设计的，而人不会手动输入那么多。如果想要在 shell 里面运行 shell、python 脚本获取大于 4096 个字符的输入时，可以使用**读取文件或者文件输出重定向的方式**。

这个问题是我在 hackerrank 上刷一道 python 题目的时候，调试大量输入的时候发现的。在网上查找了半天发现的，加油，学呀。

## 参考链接

> 1. [Why is there a 4096 character limit on text input in the shell](http://blog.chaitanya.im/4096-limit)
> 2. [bash: read discards terminal line input after 4096 bytes 这个是关于 read 的，也可以看一下](https://stackoverflow.com/questions/52250059/bash-read-discards-terminal-line-input-after-4096-bytes)
