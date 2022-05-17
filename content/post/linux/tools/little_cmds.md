---
title: linux 一些实用小命令
comments: true
toc: true
description: 本文记录学习的一些 Linux 实用小命令
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## echo

1. echo 命令可用单引号或双引号来划定文本字符串。如果在字符串中用到了它们，你需要在
   文本中使用其中一种引号，而用另外一种来将字符串划定起来

2. 如果想把文本字符串和命令输出显示在同一行中，该怎么办呢？可以用`echo`语句的`-n`参数

    `-n：do not output the trailing newline`

    例如：

    ```shell
    #!/bin/bash
    echo -n "The time and date are:"
    date
    ```

## expr

### 介绍

expr 命令是一个手工命令行计数器，用于在 UNIX/LINUX 下求表达式变量的值，一般用于整数值，也可用于字符串。

`expr 表达式`

表达式说明:

-   **用空格隔开每个项**;
-   **用 `\` (反斜杠) 放在 shell 特定的字符前面**;
-   对包含空格和其他特殊字符的字符串要用引号括起来;
-   `expr` 会输出结果，所以不用再单独 `echo`

### 使用

1、计算字串长度 `expr length 字符串`

```shell
$ expr length "this  is a test"
14
```

2、抓取字串 `expr substr 字符串 start_index length`

```shell
$ expr substr "this  is a test"  3  5
is  is
```

3、抓取第一个字符数字串出现的位置 `expr index 字符串 字符`

```shell
> expr index "sarasara" a
2
```

4、整数运算
`%， *， /，+， -`

```shell
> expr 30 \* 3 (使用乘号时，必须用反斜线屏蔽其特定含义。因为shell可能会误解显示星号的意义)
90
> expr 30 * 3
expr: Syntax error
```

## more

more 命令用于在命令提示符中查看文本文件，每次显示一个屏幕，以防文件较大(例如日志文件)。

使用：

1. 直接加文件参数
   `more filename`
2. 管道
   例如：cat filename|nl|more

常用快捷键：

`q` 退出
`space` 显示后面 k 行文本，默认为当前屏幕大小。
`b 或者 ctrl+b` 回退一屏文字，**注意**： 此快捷键只在与文件使用时起作用，例如：`more filename`，而与管道使用时无作用。

## last

该命令用来列出目前与过去登录系统的用户相关信息。指令英文原义：show listing of last logged in users.

## time

执行命令，并测试给出特定指令执行时所需消耗的时间及系统资源等
time 指令可以显示的资源有四大项，分别是：

1. Time resources
2. Memory resources
3. IO resources
4. Command info

例如：

```shell
$ time date
Sat 01 Aug 2020 03:41:58 PM CST
date  0.00s user 0.00s system 80% cpu 0.001 total
```

## 参考资料

> 1. [Linux time 命令](https://www.runoob.com/linux/linux-comm-time.html)
