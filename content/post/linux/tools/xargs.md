---
title: xargs 命令
comments: true
toc: true
tags:
description: xargs 命令学习与使用
summary: xargs 命令学习与使用
categories:
    - linux
    - tools
date: 2020-08-01 14:11:25
---

> 本文主要翻译自 [Linux and Unix xargs command tutorial with examples](https://shapeshed.com/unix-xargs/)

## 简介

`xargs` 命令用于从标准输入中构建执行管道和执行命令行。像 `grep` 命令等可以从接受管道输入作为参数，而其他工具，像 `echo`, `rm`, `mkdir`, `ls` 等却不能。我们可以借助 xargs 来使他们接受管道输入作为参数。

## 使用

默认情况下，`xargs` 从由空格分隔的标准输入中读取项，并对每个参数执行一次命令。

下面例子中通过管道将标准输入传递给 `xargs`，然后它执行每个参数。

```shell
$ echo "one two three" | xargs mkdir
$ ls
one  three  two
```

## xargs 与 find 配合使用

`xrags` 最常见的用法就是和 `find` 一起使用。一般是使用 `find` 来搜索文件和目录，然后使用 `xargs` 来处理结果。典型的例子是改变所有权或者移动文件。

下面例子中，查找 2 周以前的文件，然后通过管道将结果传给 `xargs` 来进行删除操作。

`sudo find /tmp -mtime +10|xargs rm -f`

报错提示：

```shell
$ sudo find /tmp -mtime +10|xargs rm
rm: missing operand
Try 'rm --help' for more information.
```

原因： `find` 查找的结果集为空，导致 `rm` 接受到空参数

## xargs v exec

`find` 命令支持 -exec 选项来对结果执行任意的操作。

下面两个版本的效果是一致的：

```shell
find ./foo -type f -name "*.txt" -exec rm -f {} \;
find ./foo -type f -name "*.txt" | xargs rm -f
```

一些测试（见文末参考资料）表示 `xargs` 比 `exec {}` 快六倍

## 打印执行的命令

`-t` 选项打印每一条将会在终端执行的命令。

例如：

```shell
$ echo 'one two three' | xargs -t rm -rf
rm -rf one two three
```

## 打印并提示询问命令

`-p` 选项会打印要执行的命令，并提示用户是否执行

```shell
$ echo 'one two three' | xargs -p touch
touch one two three ?...y
```

## 参考资料

> 1. [Linux and Unix xargs command tutorial with examples](https://shapeshed.com/unix-xargs/)
> 2. [Error 'rm: missing operand' when using along with 'find' command](https://stackoverflow.com/questions/36617999/error-rm-missing-operand-when-using-along-with-find-command/36618260)
> 3. [find -exec vs. find | xargs](https://www.everythingcli.org/find-exec-vs-find-xargs/)
> 4. [xargs vs. exec {}](https://danielmiessler.com/blog/linux-xargs-vs-exec/)
