---
title: Bash Here document
comments: true
toc: true
tags:
    - shell
description: 本文主要介绍可以是实现多行输入的重定向的 Here document
summary: 本文主要介绍可以是实现多行输入的重定向的 Here document
categories:
    - programming
date: 2020-07-13 23:11:25
---

## 场景

在编写 shell 脚本时，可能会遇到需要将 `多行文本块或代码` 传递给 `交互式命令(如tee、cat或sftp)` 的情况。在 Bash 和其他 shell(如 Zsh)中，**Here document(Heredoc) 是一种允许你向命令传递多行输入的重定向**。

here 文档常被 shell 脚本用来生成菜单或被用来多行注释

## 语法

HereDoc 语法如下：

```shell
[COMMAND] <<[-] 'DELIMITER'
  HERE-DOCUMENT
DELIMITER
```

1. 第一行以可选命令开头，后面跟重定向操作符 `<<` 和分隔符。
2. 可以使用任何字符串作为分隔标识符，最常用的是 `EOF` 或 `END`。
3. 如果分隔符没有被引号包围， shell 将会在解析 here-document 到命令前，替换解析所有变量、命令和特殊字符
   注：在字符串中，如果需要使用变量或者命令

    1. 对于环境变量，使用 `$环境变量名`， 如：`$PWD`、`$SHELL`
    2. 对于命令，使用 `$(pwd)`、

        ```shell
        # violetv at manjaro in ~/testsh [11:22:05]
        $ echo $PWD
        /home/violetv/testsh

        # violetv at manjaro in ~/testsh [11:22:10]
        $ echo "$(basename $PWD)"
        testsh
        ```

    举例：`$PWD`、`$(whoami)` 在使用没有被引号包围的分隔符的 heaeDoc 中，不会被当作变量解析，只当一般字符串。

    ```shell
    # 无引号包围分隔符，解析
    $ cat << EOF
    The current working directory is: $PWD
    You are logged in as: $(whoami)
    EOF
    The current working directory is: /home/violetv/testsh
    You are logged in as: violetv

    # 有引号包围分隔符，不解析
    # violetv at manjaro in ~/testsh [10:48:56]
    $ cat <<- "EOF"
    heredocd> The current working directory is: $PWD
    heredocd> You are logged in as: $(whoami)
    heredocd> EOF
    The current working directory is: $PWD
    You are logged in as: $(whoami)
    ```

4. here-document 块可以包含字符串，变量，命令和任何其他类型的输入。

5. 最后一行以分隔符结尾，**分隔符前面不允许有 Whitespace**，否则会报错。
   这也是为什么下面推荐当需要在 shell 编写 hereDoc ，然后希望与其他缩进对齐时，使用 `<<-` 的原因。

6. 在重定向运算符 `<<` 后面加上减号 `-` 将导致所有前导制表符被忽略。 这可以使你可以在 shell 脚本中编写 hereDoc 时使用缩进，而不报错。但是注意：**不允许使用前导 Whitespace 字符(即：第 5 条讲的分隔符前面不允许有 Whitespace)，只能使用制表符。**
   常见场景：如果在 shell 语句或循环中使用 heredoc，请使用 `<<-` 重定向操作是你的代码缩进时不报错。

    1. （推荐）使用减号，缩进结尾 EOF 不报错

        ```shell
        $ cat test
        if true; then
                cat <<- EOF
                Line with a leading tab
                EOF
        fi

        # violetv at manjaro in ~/testsh [10:54:34]
        $ ./test
        Line with a leading tab
        ```

    2. （错误）：不使用减号，缩进结尾 EOF， 报错

        ```shell
        # violetv at manjaro in ~/testsh [10:55:11]
        $ cat test
        if true; then
                cat << EOF
                Line with a leading tab
                EOF
        fi

        # violetv at manjaro in ~/testsh [10:55:17]
        $ ./test
        ./test: line 5: warning: here-document at line 2 delimited by end-of-file (wanted `EOF')
        ./test: line 6: syntax error: unexpected end of file
        ```

    3. （不推荐）不使用减号，不缩进结尾 EOF， 不报错, 但是有制表符输出

        ```shell
        # violetv at manjaro in ~/testsh [10:57:44]
        $ cat test
        if true; then
                cat << EOF
                Line with a leading tab
        EOF
        fi

        # violetv at manjaro in ~/testsh [10:57:46]
        $ ./test
                Line with a leading tab
        ```

    4. 分隔符前有前导 whitspace 报错

    ```shell
    # violetv at manjaro in ~/testsh [11:10:03]
    $ cat test
    if true; then
            cat << EOF
                    Line with a leading tab
            EOF
    fi

    # violetv at manjaro in ~/testsh [11:10:05]
    $ ./test
    ./test: line 5: warning: here-document at line 2 delimited by end-of-file (wanted `EOF')
    ./test: line 6: syntax error: unexpected end of file
    ```

## 常见使用

Here document 可以搭配这种命令使用，这里只介绍我常见的及我见过的

### 使用 cat 输出多行

1. 终端中：

    ```shell
    # violetv at manjaro in ~/testsh [11:11:45]
    $ cat << EOF
    The current working directory is $PWD
    So Who am I?, you are $(whoami)
    EOF
    The current working directory is /home/violetv/testsh
    So Who am I?, you are violetv
    ```

2. 脚本中

    ```shell
    if true; then
        cat <<- EOF
        Line with a leading tab.
        EOF
    fi
    ```

3. 重定向到文件

    ```shell
    # violetv at manjaro in ~/testsh [11:27:51]
    $ cat << EOF > test.txt
    heredoc> The current working directory is: $PWD
    heredoc> You are logged in as: $(whoami)
    heredoc> EOF

    # violetv at manjaro in ~/testsh [11:28:17]
    $ cat test.txt
    The current working directory is: /home/violetv/testsh
    You are logged in as: violetv
    ```

4. pipe heredoc

    通过管道，使用 sed、awk 等进行处理，然后也可以重定向或者追加到文件。

    ```shell
    $ cat << EOF | sed 's/e/QAQ/g'
    pipe heredoc> Hello World
    pipe heredoc> Linux Shell is powerful!
    pipe heredoc> EOF
    HQAQllo World
    Linux ShQAQll is powQAQrful!
    ```

### shell 使用 python 执行脚本

这个不常用，在 shell 脚本中使用 heredoc 达到执行 python 代码的目的。shell 可以使用识别 heredoc， python 不能识别。因此，不能再 pyhton 中直接使用 shell，需要通过一般操作，如：os 模块，subprocess 模块等。

一般我们都是 shell 和 expect 相互使用，不过 expect 我还没学 emm

heredoc 搭配 python 命令执行:

```shell
#!/usr/bin/sh
if ping -c1 $1 &>/dev/null; then
    python <<-EOF
        print("ip is up")
    EOF
else
    /usr/bin/python <<-EOF
        print("ip is down")
    EOF
fi
```

## 参考资料

[Bash Heredoc](https://linuxize.com/post/bash-heredoc/#disqus_thread)
