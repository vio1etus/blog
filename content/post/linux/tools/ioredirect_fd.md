---
title: Linux IO 重定向，文件描述符
comments: true
toc: true
tags:
    - ioredirect
    - pipe
    - fd
description: 本文主要介绍 Linux 下输入输出重定向以及设备文件，文件描述符
summary: 本文主要介绍 Linux 下输入输出重定向以及设备文件，文件描述符
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## 输入重定向

### 管道

通过 `echo` 命令和管道传递

不要以为由管道串起的两个命令会依次执行。Linux 系统实际上会**同时运行**这两个命令，在
系统内部将它们连接起来。**在第一个命令产生输出的同时，输出会被立即送给第二个命令**。数据
传输不会用到任何中间文件或缓冲区。

`tee` 复制 pipe 文件流

命令作用：在管道中间复制一份标准输入，然后接着传递管道的标准输入（并不改变标准输入）。

> In computing, tee is a command in command-line interpreters (shells) using standard streams which reads standard input and writes it to both standard output and one or more files, effectively duplicating its input.It is primarily used in conjunction with pipes and filters. The command is named after the T-splitter used in plumbing.

`tee filename` 将标准输入的内容**覆盖**到文件一份
`tee -a filename`将标准输入的内容**追加**到文件一份

## 直接通过文件重定向

`python input_need.py < input_content.txt`

## 输出重定向

## 命令替换

shell 脚本中最有用的特性之一就是可以从命令输出中提取信息，并将其赋给变量。把输出赋
给变量之后，就可以随意在脚本中使用了。这个特性在处理脚本数据时尤为方便。

命令替换和重定向有些相似，但区别在于命令替换是将一个命令的输出作为另外一个命令的参数。

将命令输出赋给变量的两种方法：

1. 反引号 (`)
2. `$()` 格式

```shell
command1 `command2`
```

### 示例

1. 当你想统计某个目录下所有（或者一部分）文件的字数时，下面为统计当前目录下 `test` 相关文件的字数：

    ```shell
    $ wc `ls |grep test`
    5  13  61 test
    9  20 198 test.py
    3   4  26 test_subshell.sh
    ```

2. 提取日期信息来生成日志文件名

    `touch $(date +%y%m%d%H%M).log`

### 注意

命令替换会创建一个子 shell 来运行对应的命令。子 shell（subshell）是由运行该脚本的 shell
所创建出来的一个独立的子 shell（child shell）。正因如此，由该子 shell 所执行命令是无法
使用脚本中所创建的变量的。

## 设备文件

先了解一下设备文件，在 Linux 系统中一切皆可以看成是文件，文件又可分为：普通文件、目录文件、链接文件和设备文件。

设备文件：

[Linux 下的两个特殊的文件 -- /dev/null 和 /dev/zero 简介及对比](https://blog.csdn.net/longerzone/article/details/12948925)

## 文件描述符

文件描述符（file descriptor）是内核为了高效管理已被打开的文件所创建的索引，其是一个非负整数（通常是小整数），用于指代被打开的文件，所有执行 I/O 操作的系统调用都通过文件描述符。系统创建的每个进程默认会打开 3 个文件，标准输入(0)、标准输出(1)、标准错误(2)。如果此时去打开一个新的文件，它的文件描述符会是 3。POSIX 标准要求每次打开文件时（含 socket）必须使用当前进程中最小可用的文件描述符号码，因此，在网络通信过程中稍不注意就有可能造成串话。

| 文件描述符 | 用途     | POSIX 名称    | stdio 流 |
| ---------- | -------- | ------------- | -------- |
| 0          | 标准输入 | STDIN_FILENO  | stdin0   |
| 1          | 标准输出 | STDOUT_FILENO | stdout   |
| 2          | 标准错误 | STDERR_FILENO | stderr   |

Usage:

-   The general form of this one is M>/dev/null, where "M" is a file descriptor number. This will redirect the file descriptor, "M", to /dev/null.
-   The general form of this one is M>&N, where "M" & "N" are file descriptor numbers. It combines the output of file descriptors "M" and "N" into a single stream.

1. 将标准输出重定向到空设备文件
   `>/dev/null` 或者 `1>/dev/null`
   if a number isn't explicitly given, then number 1 is assumed by the shell (bash)
2. 将标准错误重定向到空设备文件
   `2>/dev/null`

3. 混合标准错误和标准输出到一个流
   `2>&1`， 即：将标准错误和标准输出混合在一个流，然后在进行重定向等，如：`cat file > /dev/null 2>&1`

4. 混合标准错误和标准输出到一个流(简写)
   `&>/dev/null` This is just an abbreviation for >/dev/null 2>&1. It redirects file descriptor 2 (STDERR) and descriptor 1 (STDOUT) to /dev/null.

个人习惯使用：`>/dev/null` 和 `2>/dev/null` 和 `&>/dev/null` 分别实现重定向标准输出、标准错误、混合 三种目的。

## 参考资料

[重定向 stdin stdout stderr](https://www.cnblogs.com/irockcode/p/6619049.html)
