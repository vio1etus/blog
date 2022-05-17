---
title: Python root 用户报错 ModuleNotFoundError
comments: true
toc: true
tags:
  - python
  - ModuleNotFoundError
description: Python 有一些模块或函数，只能在这里 root 权限下才能运行，但是，root 用户（sudo）运行，却报错 ModuleNotFoundError:No module named 'xxx'
categories:
  - python
  - issues
date: 2020-07-21 16:01:54
---

之前在 sudo 模式下，运行，Python 脚本文件时，也遇到这个问题，但那是遇到的模块文件都是可以在用户权限下运行的，我只是不小心在这里 root 下想运行而已。

## 问题

今天在学习 scapy 模块进行了 IP 欺骗的时候，我发现它必须在这里 root  权限下运行，否则报错  `PermissionError: [Errno 1] Operation not permitted`，但是 root 下用户还报错：

```python
$ sudo python spoofing.py
[sudo] password for violetv: 
Traceback (most recent call last):
  File "spoofing.py", line 3, in <module>
    from scapy.all import *
ModuleNotFoundError: No module named 'scapy'
```

## 解决方法

使用的 `sudo` 命令的 `-E` 选项, `sudo -E python spoofing.py`

## 原因

由于安全策略，默认情况下， root 用户不会加载普通用户的环境变量（这里指 Python 的环境变量），而我的 Python 包又是只安装在用户目录下的，因此报错。

可以通过使用 `sudo` 的 `-E` 选项告诉安全策略，用户想要在切换到 sudo 之后保留自己的环境变量。

通过了 `man sudo` 可得：

> -E, --preserve-env
        Indicates to the security policy that the user wishes to
        preserve their existing environment variables.  The secu‐
        rity policy may return an error if the user does not have
        permission to preserve the environment.
>
> --preserve-env=list
        Indicates to the security policy that the user wishes to
        add the comma-separated list of environment variables to
        those preserved from the user's environment.  The security
        policy may return an error if the user does not have per‐
        mission to preserve the environment.  This option may be
        specified multiple times.

## 参考资料

> [Cannot run Python script using sudo](https://stackoverflow.com/questions/50315645/cannot-run-python-script-using-sudo)
[PYTHONPATH not working for sudo on GNU/Linux (works for root)](https://stackoverflow.com/questions/7969540/pythonpath-not-working-for-sudo-on-gnu-linux-works-for-root)
[Python 之 新手安装详解 、安装目录说明 及 修改pip默认包安装位置](https://blog.csdn.net/ZCShouCSDN/article/details/84990674)