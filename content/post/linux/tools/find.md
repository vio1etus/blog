---
title: find 命令
comments: true
toc: true
tags:
    - find
description: find 命令学习与使用
categories:
    - linux
    - tools
date: 2020-08-1 10:11:25
---

## 命令格式

```shell
find [where to start searching from] [expression determines what to find] [-options] [what to find]
```

### 示例

find 命令: `find . -name "?fs*"`

解释:

1. `.`，表示搜索位置从当前目录搜索，**如果你不指定搜索的位置，那么默认从当前目录搜索。**
2. `-name`， 选项指定搜索什么样文件名，后面跟 expression,可以使用元字符。
3. `"?fs*"`， 表示搜索第一个字母任意，第二三个字母为 `fs`，后面字母任意的文件名。

## Options

学习一下常用的选项。

-   `-exec CMD`: The file being searched which meets the above criteria and returns 0 for as its exit status for successful command execution.
-   `-ok CMD` : It works same as -exec except the user is prompted first.
-   `-size +N/-N[cwbkMG]` : Search for files of ‘N’ blocks;
-   timestamp： search for file of specific timestamp
    `-atime`、`-modify`、`change`
-   `-type TYPE`：The directory TYPE is `d`，The file TYPE is `f`
-   `-empty` : Search for empty files and directories.
-   `-newer file` : Search for files that were modified/created after ‘file’.

## empty，newer

`-empty` 测试

```shelll
$ find -empty
./hello

# violetv at manjaro in ~/test [10:40:33]
$ find ./ -empty
./hello
```

`-newer file` 测试

```shell
$ find -newer test2.py
.
./full
./hello
./world
./world/test
./world/test/test.txt
```

## `-size`

`-size +N/-N[cwbkMG]` : Search for files of ‘N’ blocks;

**Bear in mind that the size is rounded up to the next unit**. Therefore -size -1M is not equivalent to -size -1048576c.

`+N` means size > ‘N’ blocks and `-N` means size < 'N' blocks. No `+` or `-` means equal.

Unit:

-   `b`： for 512-byte blocks (this is the default if no suffix is used)
-   `c`： for bytes
-   `k`： for kibibytes (KiB, units of 1024 bytes)
-   `M`： for mebibytes (MiB, units of`1024 \* 1024 = 1048576 bytes`)
-   `G`： for gibibytes (GiB, units of `1024 * 1024 * 1024 = 1073741824 bytes`)

```shell
$ find . -size +2G
-rw-r--r-- 1 violetv violetv 2897272832 Aug  1 10:35 ./full

$ find . -type f  -size +1k -exec ls -hl {} \;
-rw-r--r-- 1 violetv violetv 1.8G Aug  1 11:14 ./full
```

## timestamp

Linux has 3 time stamps associated to a file:

1. Access - the last time the file was read
2. Modify - the last time the file was modified (content has been modified)
3. Change - the last time meta data of the file was changed

选项： `-amin, -atime, -cmin, -ctime, -mmin,-mtime`

选项开头为 3 种时间戳的首字母。
`-mtime n`：查找系统中最近 `n*24` 被修改的文件
`-amin n`： 查找系统中最近 n 分钟访问的文件
`+` 和 `-` 表示大于小于

```shell
$ find -atime +1
.
./dfs.py
./tempCodeRunnerFile.py
./test2.py
./self_print.py
./some.txt
./reversed_cls.py
./str_repr.py
./spoofing.py
./hashable.py
```

## `-exec` 和 `-ok`

`-exec` 后面的格式是： `命令+空格+{}+空格+\;`

-   花括号 `{}`，代表前面 find 命令查找出来的文件名。
-   以分号 ";" 作为结束标识符的，考虑到各个系统平台对分号的不同解释，我们在分号前再加个反斜杠，便于移植。

1. 使用 find 命令查找相关文件后，再使用 rm 命令将它们删除

    ```shell
    $ find . -size +1G -exec rm -i {} \;
    rm: remove regular file './full'? ^C
    ```

2. 搜索匹配到的文件中的关键内容

    ```shell
    $ find . -name "*.py" -exec grep "lambda" {} \;
    pkt = sniff(filter='tcp', prn=lambda pkt:pkt.show())
    ```

3. 查找文件并移动到指定目录

    ```shell
    # violetv at manjaro in ~/test [11:28:55]
    $ find . -name "*.py" -exec  mv {} ../test_tmp \;

    # violetv at manjaro in ~/test [11:29:13]
    $ ll ../test_tmp
    total 32K
    -rwxrwxrwx 1 violetv violetv 772 Jul 22 15:07 dfs.py
    -rwxrwxrwx 1 violetv violetv 728 Jul 20 21:20 hashable.py
    -rwxrwxrwx 1 violetv violetv 520 Jul 22 16:23 reversed_cls.py
    ```

4. 删除 n 天前的文件

    `find path -type f -mtime +n -exec rm -fi {} \；`

5. 查看当前目录下文件个数:

    `find ./ | wc -l`

6. find 与 xargs 配合
   类似于使用 `-exec`，但是 xargs 速度更快。
    - [ ] 关于 xargs 可以看我的另一篇博文：xargs 命令

## 参考资料

> 1. manual of find: `man find`
> 2. [Linux 下 find 与 exec 的联手干大事](https://mp.weixin.qq.com/s?__biz=MzU3NTgyODQ1Nw==&mid=2247485216&idx=1&sn=c6d972e5a09d1d60433d733c3b3e0365&=41#wechat_redirect)
> 3. [Linux - modify file modify/access/change time](https://stackoverflow.com/questions/40630695/linux-modify-file-modify-access-change-time)
