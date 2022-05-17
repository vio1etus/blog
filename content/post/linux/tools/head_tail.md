---
title: head 和 tail 命令
comments: true
toc: true
tags:
    - head
    - tail
description: 本文主要介绍快捷查看文件首部或者尾部指定行数的命令：head 和 tail 命令
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## tail

### introduction

tail 命令显示一个或多个文件或管道数据的最后一部分(**默认为 10 行**)。它还可以用来实时监控文件的变化。

tail 命令最常见的用途之一是监视和分析随时间变化的**日志**和其他文件，通常与 grep 等其他工具结合使用。

head 和 tail 用法一致，只不过是显示头部前几行。

### Preparation

提前在 `ipython` 里面用 python 搞个测试文件：

```python
with open("test.log", "w") as fp:
    for i in range(1,51):
        fp.write(f"正数第{i} 行， 倒数第{51-i} 行\n")
```

然后下面如果可以显示行数少的，我就将测试结果放上来，行数多的，就不放了。

### Usage

`tail [OPTION]... [FILE]...`

`OPTION`: 后面介绍常用的几个
`FILE`： 零个或多个文件名。如果没有指定文件，或者当 `FILE` 为 `-` 时，tail 将读取标准输入。

1. 最简单的用法是不加 `OPTION`， 默认显示文件的最后 10 行
   `tail filename.txt`

2. 最常见的用法是 `-f` OPTION， 循环读取，实时显示文件的改变
   `tail -f filename.txt`。

3. 显示尾部的指定行数，使用 `-n` (`--lines`) 参数
   `tail -n <NUMBER> filename.txt`

    例如：显示最后 2 行：

    ```shell
    $ tail -n 2 test.log
    正数第49 行， 倒数第2 行
    正数第50 行， 倒数第1 行
    ```

    注意： `-n` 的 `n` 可以去掉，直接 `-<NUMBER>`,例如：

    ```shell
    $ tail -2 test.log
    正数第49 行， 倒数第2 行
    正数第50 行， 倒数第1 行
    ```

4. 显示尾部的指定字节数， 使用 `-c` (`--bytes`) 参数

    `tail -c <NUMBER> filename.txt`

    ```shell
    $ tail -c 15 test.log
    倒数第1 行
    ```

    此外，还可以指定倍数，例如：`b` 是 512， `K` 是 `1024`，不过目前来看，我没有发现指定字节这个参数的用处，因此，不详细学这里了，否则早晚要忘记。

5. 监控文件变化，使用 `-f` (`--follow`) 参数
   `tail -f filename.txt`， 此参数在检测日志文件时，尤其有用。
   例如：实时动态显示 `/var/log/nginx/error.log` 的后 10 行。
   `tail -f /var/log/nginx/error.log`

    为了在文件被删除后重新创建时，持续监控文件，使用 `-F` 参数：

    我测试时，先用 `tail -F test.log`，然后在另一个 shell 中，`rm test.log`，然后再用 python 写入，就是下面结果。

    ```shell
    $ tail -F test.log
    正数第41 行， 倒数第10 行
    正数第42 行， 倒数第9 行
    正数第43 行， 倒数第8 行
    正数第44 行， 倒数第7 行
    正数第45 行， 倒数第6 行
    正数第46 行， 倒数第5 行
    正数第47 行， 倒数第4 行
    正数第48 行， 倒数第3 行
    正数第49 行， 倒数第2 行
    正数第50 行， 倒数第1 行
    tail: 'test.log' has become inaccessible: No such file or directory
    tail: 'test.log' has appeared;  following new file
    正数第1 行， 倒数第50 行
    正数第2 行， 倒数第49 行
    正数第3 行， 倒数第48 行
    正数第4 行， 倒数第47 行
    正数第5 行， 倒数第46 行
    正数第6 行， 倒数第45 行
    ```

    至于为什么后面是从 `正数第1 行`开始显示，是因为 Python 逐行写入，然后 tail 在写入一行后，就读取导致的。
    你可以使用 Here document， 就可以看到正常的结果了。

    ```shell
    $ cat <<- EOF > test.log
    正数第41 行， 倒数第10 行
    正数第42 行， 倒数第9 行
    正数第43 行， 倒数第8 行
    正数第44 行， 倒数第7 行
    正数第45 行， 倒数第6 行
    正数第46 行， 倒数第5 行
    正数第47 行， 倒数第4 行
    正数第48 行， 倒数第3 行
    正数第49 行， 倒数第2 行
    正数第50 行， 倒数第1 行
    EOF
    ```

6. 显示多个文件， 空格分隔即可。
   为 `tail` 给予多个文件输入参数，它会展示每个文件夹的最后 10 行。
   `tail filename1.txt filename2.txt`
   例如：
   `tail filename1.txt filename2.txt`

    此外，你也可以使用和显示一个文件时，可用的相同参数。

7. tail 与其他命令搭配

    1. 与 grep 使用
       监控 apache 的访问日志文件，只显示那些包含 ip：192.168.42.12 的。
       `tail -f /var/log/apache2/access.log | grep 192.168.42.12`
    2. 与 ps 使用，查看 top n 的占用某一资源的进程
       `ps aux | sort -nk +3 | tail -5`
       显示 top 5 占用 CPU 资源的进程。

8. head 与其他命令使用
   head 命令可以与其他命令结合使用，通过管道将标准输出重定向到其他程序。
   例子：对环境变量 `$RANDOM` 取 sha512 摘要，然后输出前 24 个字符。
   `echo $RANDOM | sha512sum | head -c 24 ; echo`

## 参考资料

[Linux Tail Command](https://linuxize.com/post/linux-tail-command/)

[Linux Head Command](https://linuxize.com/post/linux-head-command/)
