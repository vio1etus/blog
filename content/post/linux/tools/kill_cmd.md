---
title: kill 命令
comments: true
toc: true
tags:
    - kill
description: 本文主要介绍 Linux 下的 kill 命令
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## `kill` Command

`kill` 是大多数 Bourne-derived shells，诸如：bash、zsh 等 shell 的内置命令。 shell 内置版和 `/bin/kill` 独立可执行文件版的 kill，在行为有些不同。

使用 `type` 命令显示你系统上包含 `kill` 的所有位置

```shell
$ type -a kill
kill is a shell builtin
kill is /usr/bin/kill
```

以上的输出说明 shell 内置命令比独立可执行文件具有较高的优先级。当你输入 `kill` 默认使用前者，如果你想要使用二进制版（后者），那你需要输入文件的全路径 `/usr/bin/kill` （/usr 目录下表明是用户的，否则是系统的）。本文将讨论默认用的 Bash 内置版的 kill

## syntax

`kill [OPTIONS] [PID]...`

`kill` 命令发送一个信号到制定的进程或者进程组，使它们根据信号来行动。当没指定信号时， 默认使用 `-15` （-TERM）

使用 `kill -l` 可以得到所有可用的信号的列表, 建议你使用 `kill -l|sed "s/ /\n/g"|nl` ， 这样我们可以看序号。

```shell
$ kill -l
HUP INT QUIT ILL TRAP ABRT BUS FPE KILL USR1 SEGV USR2 PIPE ALRM TERM STKFLT CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH POLL PWR SYS
```

信号可以通过 3 种方式指定：

1. Using number (e.g., `-1` or `-s 1`).
2. Using the "SIG" prefix (e.g., `-SIGHUP` or `-s SIGHUP`).
3. Without the "SIG" prefix (e.g., `-HUP` or `-s HUP`).

下面的指令是等价的：

```shell
kill -1 PID_NUMBER
kill -SIGHUP PID_NUMBER
kill -HUP PID_NUMBER
```

## 常见信号

linux 进程也有三种方式来处理收到的信号：

1. 忽略信号，即对信号不做任何处理，其中，有两个信号不能忽略：SIGKILL 及 SIGSTOP；
2. 捕捉信号。定义信号处理函数，当信号发生时，执行相应的处理函数；
3. 执行缺省操作，Linux 对每种信号都规定了默认操作。

Linux 进程对实时信号的缺省反应是进程终止。但是对于高性能服务器编程来说，这是致命的缺陷，对于这类服务器需要保证在收到各种信号后仍然可以可靠运行，所以我们需要在理解各种信号的缘由和正确的处理方式。

SIGHUP 和控制台操作有关，当控制台被关闭时系统会向拥有控制台 sessionID 的所有进程发送 HUP 信号，默认 HUP 信号的 action 是 exit，如果远程登陆启动某个服务进程并在程序运行时关闭连接的话会导致服务进程退出，所以一般服务进程都会用 nohup 工具启动(该命令就是让忽略该信号)或写成一个 daemon(利用 setsid 进行)。

0. `SIGHUP`

> The SIGHUP signal is sent to a process when its controlling terminal is closed. It was originally designed to notify the process of a serial line drop (a hangup). In modern systems, this signal usually means that the controlling pseudo or virtual terminal has been closed. Many daemons will reload their configuration files and reopen their logfiles instead of exiting when receiving this signal. `nohup` is a command to make a command ignore the signal.

1. `SIGINT` 终止进程，通常我们的 Ctrl+C 就发送的这个消息。Ctrl+C 终止前台进程

2. `SIGQUIT` 和 SIGINT 类似, 但由 QUIT 字符(通常是 Ctrl- / )来控制. 进程收到该消息退出时会产生 core 文件。

3. `SIGKILL` 消息编号为 9，我们经常用 kill -9 来杀死进程发送的就是这个消息，程序收到这个消息立即无条件终止，这个消息不能被捕获，封锁或者忽略，所以是杀死进程的终极武器。

4. `SIGTERM` 是不带参数时 kill 默认发送的信号，默认是 Gracefully stop a process.（先关闭和其有关的程序，再将其关闭）

5. `SIGTSTP`

    > The SIGTSTP signal is sent to a process by its controlling terminal to request it to stop (terminal stop). It is commonly initiated by the user pressing `Ctrl+z`. Unlike SIGSTOP, the process can register a signal handler for, or ignore, the signal.

    可以使用 `jobs` 查看后台命令，使用 `fg` 将对应序号挂起的进程调回前台.

6. SIGCONT

    > The SIGCONT signal instructs the operating system to continue (restart) a process previously paused by the SIGSTOP or SIGTSTP signal. One important use of this signal is in job control in the Unix shell.

    除了其他目的，`SIGSTOP` 和 `SIGCONT` 用于 Unix shell 中的作业控制，无法捕获或忽略 `SIGCONT` 信号。

## 使用 `kill` 终止命令

### kill 任意进程

要终止一个进程，首先需要它的进程 id， 也就是 PID。你可以使用 `top, ps, pidof，pgrep` 等诸多命令。

我一般常用三个： 1. 如果是看内存占用等，一般先运行 `htop`,然后找到 PID 2. 如果只是要杀死某谢特定的进程，使用(注意 可用 tab 键补全要找的名字) 1. `ps aux|grep firefox` 2. `pidof firefox`

然后再用 kill 通过发送 `TERM` 信号无条件杀死这些进程 `kill -9 PID`

### kill 后台任务进程

通过 `jobs` 命令查看 job 号（假设为 num），然后执行 `kill %num`.
如果只有一个后台任务的化，那就是 `kill %1` 直接上

## 总结

`kill` 命令通常用来向进程发送信号，最常用的信号是：`SIGKILL` 或 `-9` ,即：无条件终止进程。

## 参考资料

[Kill Command in Linux](https://linuxize.com/post/kill-command-in-linux/)

[Signal (IPC) wiki](<https://en.wikipedia.org/wiki/Signal_(IPC)>)
