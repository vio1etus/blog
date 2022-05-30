---
title: shell 前后台作业控制 & nohup screen
comments: true
toc: true
tags:
    - shell
description: 本文主要涉及两个点:前、后台任务控制、避免挂断终端影响（尤其是远程 ssh 连接断开时），涉及命令：`&`，`nohup`，`screen` 以及 `^c, ^d, ^z` 快捷键以及原理。
summary: 本文主要涉及两个点:前、后台任务控制、避免挂断终端影响（尤其是远程 ssh 连接断开时），涉及命令：`&`，`nohup`，`screen` 以及 `^c, ^d, ^z` 快捷键以及原理。
categories:
    - programming
date: 2020-07-13 23:11:25
---

## 简介

在 Linux 执行任务时，如果键入 Ctrl+C 退出进行其他任务或者关闭当前 session 当前任务就会终止 要想不让进程停止或者让进程在后台运行，就需要一些命令： `&, nohup, screen`

## 任务控制

注意：作业控制机制是 shell 的功能，终端关了，就没有这个机制了。

fg、bg、jobs、&、ctrl + z 都是跟系统任务有关的，虽然现在基本上不怎么需要用到这些命令，但学会了也是很实用的

1. `&` 命令放到后台执行

2. `ctrl+z` 将一个正在前台执行的命令后台挂起

3. `jobs` 查看当前有多少在后台运行的命令

4. `fg` 将后台中的命令调至前台继续运行

    如果后台中有多个命令，可以用  `fg %jobnumbe`r 将选中的命令调出，`%jobnumber` 是通过 `jobs` 命令查到的后台正在执行的命令的序号(不是 pid)

5. `bg` 将一个在后台暂停的命令，变成继续执行

    如果后台中有多个命令，可以用 `bg %jobnumber` 将选中的命令调出，`%jobnumber` 是通过 `jobs` 命令查到的后台正在执行的命令的序号(不是 pid)

### 进程任务控制

下列命令可以用来操纵进程任务：

1. `ps`  列出系统中正在运行的进程；

2. `kill`  发送信号给一个或多个进程（经常用来杀死一个进程）；

3. `jobs`  列出当前 shell 环境中已启动的任务状态，若未指定 jobsid，则显示所有活动的任务状态信息；如果报告了一个任务的终止(即任务的状态被标记为 Terminated)，shell  从当前的 shell 环境已知的列表中删除任务的进程标识；
   fg  将进程搬到前台运行（Foreground），bg  将进程搬到后台运行（Background）；

    如果后台的任务号有 2 个，[1],[2]；如果当第一个后台任务顺利执行完毕，第二个后台任务还在执行中时，当前任务便会自动变成后台任务号码"[2]"的后台任务。所以可以得出一点，即当前任务是会变动的。当用户输入 "fg"、"bg" 和 "stop" 等命令时，如果不加任何引号，则所变动的均是当前任务。

    使用 jobs 或 ps 命令可以查看正在执行的 jobs。

    jobs 命令执行的结果，比如：`[1] + 6310 suspended python test.py < loop_num.txt > result.txt`

    ＋表示是一个当前的作业，减号表示是一个当前作业之后的一个作业，`jobs -l` 选项可显示所有任务的 PID, jobs 的状态可以是 suspended， running， continued， done, 但是如果任务被终止了（kill），shell  从当前的 shell 环境已知的列表中删除任务的进程标识；也就是说，jobs 命令显示的是当前 shell 环境中所起的后台正在运行或者被挂起的任务信息；

4. 进程的挂起

    后台进程的挂起：

    `kill -SIGTSTP PID`

    通过 stop 命令执行，通过 jobs 命令查看 job 号(假设为 num)，然后执行 stop %num；

    当要重新执行当前被挂起的任务时，通过 `bg %num` 即可将挂起的 job 的状态由 suspended 改为 running，仍在后台执行；当需要改为在前台执行时，执行命令 `fg %num` 即可

## 后台执行

当我们希望任务在后台执行，我们可以在命令的最后加上 `&`，然后就可以在前台做别的事情啦。而且这样也不会因为 Ctrl+C 发出 `SIGINT` 信号而终止前台进程啦。我们日常使用的 Ctrl+z 也是使程序后台挂起。

但是要是任务需要从 stdin 读取输入或者向 stdout 输出会怎么样呢？ 答案是：输出仍然会在前台输出，造成一种错乱的感觉（哈哈），而如果你将需要输入的任务直接放到后台，那它没办法在后台读取输入。

### 输出

案例： python 脚本循环输出

```Python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import time

# num = int(input("请输入循环次数："))
num = 4

for i in range(num):
   print("HelloWorld: ", i)
   time.sleep(1)  #每输出一行就休眠1秒
```

首先是只有输出的情况，会在前台输出：

```shell
# violetv at manjaro in ~/testsh [16:52:59]
$ python test.py &
[1] 30213
HelloWorld:  0

# violetv at manjaro in ~/testsh [16:53:07]
$ HelloWorld:  1
HelloWorld:  2
HelloWorld:  3

[1]  + 30213 done       python test.py

# violetv at manjaro in ~/testsh [16:53:11]
$
```

可以看出我们通过 `python test.py &` 将其放在后台执行，然而输出还是在前台，且和`# violetv at manjaro in ~/testsh [16:53:07]` 有些交叉混乱。因此，如果我们不想这样，我们可以将标准输出和错误输出重定向至（普通或者设备）文件。
例如：`python test.py &>/dev/null &` 或 `python test.py > result.txt &`

### 输入

```Python
import time

num = int(input("请输入循环次数："))

for i in range(num):
   print("HelloWorld: ", i)
   time.sleep(1)  #每输出一行就休眠1秒
```

#### 不常用操作

```shell
$ python test.py > result.txt &
[1] 30598
[1]  + 30598 suspended (tty input)  python test.py > result.txt
```

可以看到 `suspended (tty input)` 说明它在等待前台终端输入，然而它又在后台运行，它无法获取不到前台输入，因此它就在后台一直等着前台输入（挂着，相当于僵尸进程）。
这种情况，我们需要使用 `fg`(这里只有一个后台任务，所以没有加 `%n`)，再把它调到前台进行输入

```shell
# violetv at manjaro in ~/testsh [16:59:33]
$ fg
[1]  + 30598 continued  python test.py > result.txt
3

# violetv at manjaro in ~/testsh [17:04:02]
$ cat result.txt
请输入循环次数：HelloWorld:  0
HelloWorld:  1
HelloWorld:  2
```

#### 常用操作

重定向该任务的输入：

1. 重定向文件

    ```shell
    # violetv at manjaro in ~/testsh [17:10:50]
    $ cat loop_num.txt
    4

    # violetv at manjaro in ~/testsh [17:11:21]
    $ python test.py < loop_num.txt &>/dev/null &
    [1] 31297

    # violetv at manjaro in ~/testsh [17:11:26]
    $
    [1]  + 31297 done       python test.py < loop_num.txt &> /dev/null
    ```

2. 其他命令结果+管道

    ```shell
    # violetv at manjaro in ~/testsh [17:10:00]
    $ echo 3 |python test.py &>/dev/null &
    [1] 31159 31160

    # violetv at manjaro in ~/testsh [17:10:19]
    $
    [1]  + 31159 done       echo 3 |
        31160 done       python test.py &> /dev/null
    ```

## `&` 原理探究

我们常常用来终止任务的 `Ctrl+C` 快捷键，本质是向该任务发送 `SIGINT` 信号，然后任务收到该信号，终止。而 `&` 则忽略 `SIGINT` 信号，因此，对后台程序而言，我们无法通过该快捷键来终止。

我们日常使用的 Ctrl+z 和 `&` 可以达到相同的效果（只不过前者要人手动按快捷键，不利于自动化），二者都是通过向程序发送 `SIGTSTP` 信号，使其后台挂起的。

我们两种方法人为终止它：

1. 查找其 PID，使用 `kill` 命令人为发送终止信号。
2. 使用 `jobs` 查看其为第 n 个后台进程，确定 n， 使用 `fg %n` 将其调到前台，然后使用 `Ctrl+C` 将其终止。

## 不受终端挂断影响

`nohup`： 即 no hang up，不挂断的运行，通过在命令前加 `nohup`，就可以在断开终端的时候，不影响的继续了。这个在我们 ssh 远程连接服务器，在服务器上执行耗时任务的时候，极其有用。

例如：`nohup sleep 2000`,然后关闭终端。再打开使用 `ps aux|grep sleep` 查看, 它仍然运行。

注意：使用 `nohup` 时，如果不指定输出文件，默认输出到当前目录下的`nohup.out`文件

## `nohup` 原理探究

终端挂断的时候，会向之前终端启动的程序发送 `SIGHUP` 信号，使得这些任务终止。而
`nohup` 的意思就是忽略 `SIGHUP` 信号，因此当运行 `nohup sleep 2000` 的时候， 关闭 shell, 那么这个进程还是存在的。

## 综合

对于 `sleep 2000 &` 后台命令，我们关闭 shell 的时候，向之前终端启动的所有程序发送 `SIGHUP` 信号，它也不例外，照样终止。

对于 `nohup sleep 2000` 不挂断命令，我们按 Ctrl+C 的时候，向该进程发送 `SIGINT` 信号，该进程照样终止。

总结，二者都只是对对应的一个信号进行了忽略，不能忽略其他的。

但是如果在远程 ssh 连接服务器，我们想在一个终端里面执行耗时任务的同时，干别的事情怎么办？

那就将二者结合起来，就可以实现在后台运行（可以让我们接着用前台，而且后台任务不会因为 `Ctrl+C` 终止），且不受终端挂断影响。

## screen

`screen` is good for interactive processes, where you might need to detach and reattach a session. `nohup` is best for unattended processes like userspace daemons or processes you will check on later.

`screen` 一般是我们交互，需要实时看结果的时候用的， `nohup` 一般是我们需要等最后看结果时用的。

screen 预装在大多数 linux 机器上，可以使用 `screen --version` 检查它是否被安装。

一般流程:

1. `screen -S session_name`
   创建一个名为 session_name 的 session 会话

2. 在终端里正常进行你的工作,甚至是进行一些占用前台终端带输出的耗时任务

3. 然后终端突然断开（ssh 断开或者电脑断电）

4. 你重连终端

    1. `screen -list` 或者 `screen -ls` 查看 screen 的列表，也就是 session 列表。

        ```shell
        VM-0-17-ubuntu% screen -list
        There are screens on:
            9408.test   (06/26/2020 10:28:03 AM)    (Detached)
            9256.pts-0.VM-0-17-ubuntu   (06/26/2020 10:27:41 AM)    (Detached)
            8127.test   (06/26/2020 10:21:17 AM)    (Detached)
            29226.pts-0.VM-0-17-ubuntu  (06/24/2020 10:45:18 AM)    (Detached)
        4 Sockets in /run/screen/S-ubuntu.
        ```

        detached(分离），说明你当前与该 session 分离，即：不处于该 session 中

        如果你在一个 screen session 里面运行该命令，则有类似结果

        ```shell
        VM-0-17-ubuntu% screen -list
        There are screens on:
                9408.test       (06/26/2020 10:28:02 AM)        (Attached)
                9256.pts-0.VM-0-17-ubuntu       (06/26/2020 10:27:40 AM)        (Detached)
                8127.test       (06/26/2020 10:21:16 AM)        (Detached)
                29226.pts-0.VM-0-17-ubuntu      (06/24/2020 10:45:17 AM)        (Detached)
        4 Sockets in /run/screen/S-ubuntu.
        ```

        其中 (Attached) 标识的便是你当前所在的 screen session。

        你可以使用快捷键 `Ctrl+a d`（这是先按 ctrl+a，再按 ctrl+d 的意思）在任何时候 detach 出一个 screen session。

    2. `screen -r [session]`
       一般`[session]` 我们写前面的数字即可，如：9408，当然如果 tab 补全写为 9408.test 也可，只要能唯一表示就行。
       例如： `screen -r 9408.test`

    3. `exit` 或者 `Ctrl+d` 终止一个 screen session

## 结论

使用 `&` 后台运行程序：

1. 结果会输出到终端
2. 使用 Ctrl + C 发送 SIGINT 信号，程序忽略
3. 关闭 session 发送 SIGHUP 信号，程序关闭

使用 `nohup` 运行程序：

1. 结果默认会输出到 nohup.out
2. 使用 Ctrl + C 发送 SIGINT 信号，程序关闭
3. 关闭 session 发送 SIGHUP 信号，程序忽略

使用 `nohup` 和 `&` 配合来启动程序，同时忽略 SIGINT 和 SIGHUP 信号

最佳实践方案：

不要将信息输出到终端标准输出，标准错误输出，而要用日志组件将信息记录到日志里

`nohup` 命令可以将日志输入到文件中

`screen` 适合交互实时, `nohup` 适合无交互非实时，自动化.

## 参考资料

[Re: AMBER: Suspended (tty input)](http://archive.ambermd.org/200501/0179.html)

[Linux 中 nohup 和&的用法和区别](https://www.cnblogs.com/mingyue5826/p/11572228.html)

[如何杀死，暂停，继续一个后台进程](https://blog.51cto.com/10808695/1841519)

[How To Use Linux Screen](https://linuxize.com/post/how-to-use-linux-screen/)

[Is “screen” better than “nohup”? [closed]](https://stackoverflow.com/questions/17072463/is-screen-better-than-nohup)
