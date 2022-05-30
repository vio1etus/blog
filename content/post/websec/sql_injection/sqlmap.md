---
title: sqlmap 基础命令
comments: true
toc: true
description: 本文记录常用的 Sqlmap 命令
summary: 本文记录常用的 Sqlmap 命令
categories:
    - websec
    - sql injection
date: 2019-10-05 16:29:22
tags:
---

# 大佬博文

[SQL 注入之 SQLmap 入门](https://www.freebuf.com/articles/web/29942.html)

[SQLMap 用户手册【超详细】](https://www.jianshu.com/p/4fb15a2c9040)

[使用 sqlmap 曲折渗透某服务器](https://www.jianshu.com/p/cf7f646b3448)

# 常用命令：

## 检测注入

sqlmap -u 你要测试的 url

当然，参数用不用引号包围都可以，使用单双引号也无所谓。

--start 指定从第几条记录开始读取; --stop 指定读取到第几条记录结束。

如果要跳过爆破数据表/字段等，直接脱裤，可以使用 --dump -D 数据库名

--dbs 猜解库名 -D 指定某个库

--tables 猜解表名 -T 指定表

--columns 猜解列名 -C 指定字段

--dump 根据指定的位置（可以与上面-大写字母连用）爆数据

## 补充

1. 大多数情况下，一个杠后面用单词首字母/缩写，两个杠后面用完整单词。

2. -b, --banner Retrieve DBMS banner 取回 DBMS 的 banner。

    banner 翻译为标题，旗帜，标识。一般有以下四项(下面是一个 banner 实例)

    > web server operating system: Windows
    > web application technology: Apache 2.4.23, PHP 5.3.29
    > back-end DBMS: MySQL >= 5.0
    > banner: '5.5.53'

3. F12 打开开发者工具，找到 console 页面，输入 document.cookie 可以一起查看所有 cookies。（意味着可以一起复制）

4. 测试过程中，询问你关于一些配置问题时，会出现 [Y/n]，大写的为默认的，即：按下回车便是大写的那个字母代表的意思，这里是 yes。

    （一般来说，不写--batch 的时候，遇到的一些选项都选默认没有问题，如果遇到重定向，可以选 n,虽然默认是 Y）

5. post 注入

    1. sql 与 burpsuite 配合：

        通过 burpsuite 抓包，然后将报文 copy to file，使用 sqlmap 的 -r 参数读取该文件

        比如：sqlmap -r get.txt

    2. --data=‘post 数据（与 hackbar 格式一样）’

    -p 参数名 指定要检测的参数的名字，可用可不用

6. --batch 参数 nerver ask for user input use default option

    不向用户请求一些参数，使用系统默认的，因为如果不加该参数，在扫描过程成功，你会发现它会暂停，询问如：DBMS 似乎是 mysql，是否使用一切 mysql 注入方式进行检测放弃其他数据库类型检测等。

# Sqlmp 与 BurpSuite

sqlmap 通过解析 burp suite 拦截的 http 报文，从而获取信息，然后进行检测。

sqlmap -r filename --batch -smart

sqlmap -l filename --batch -smart
