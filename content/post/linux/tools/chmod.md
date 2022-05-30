---
title: chmod（File Permissions）
comments: true
toc: true
tags:
    - chmod
description: 本文主要涉及 linux 的文件权限、 chmod 命令设置文件和目录权限
summary: 本文主要涉及 linux 的文件权限、 chmod 命令设置文件和目录权限
categories:
    - linux
    - tools
date: 2020-07-13 23:11:25
---

## Linux File Permissions

类 unix 系统上的所有文件系统对象都有三种主要的权限类型:read、write 和 execute 权限。这些权限被赋予给三类用户：the user(the file owner), the group, and the others.

要查看文件权限，可以使用 `ls` 的`-l` (long format) 选项：

```shell
$ ls -l
total 12K
-rw-r--r-- 2 violetv violetv  426  6月 14 16:40 batch.py
-rw-r--r-- 2 violetv violetv  426  6月 14 16:40 hard_link_batch.py
lrwxrwxrwx 1 violetv violetv    8  6月 29 10:02 soft_link_batch.py -> batch.py
drwxr-xr-x 2 violetv violetv 4.0K  6月 13 14:37 test1
```

```txt
-rw-r--r-- 12 linuxize users 12.0K Apr  8 20:51 filename.txt
|[-][-][-]-   [------] [---]
| |  |  | |      |       |
| |  |  | |      |       +-----------> 7. Group
| |  |  | |      +-------------------> 6. Owner
| |  |  | +--------------------------> 5. Alternate Access Method
| |  |  +----------------------------> 4. Others Permissions
| |  +-------------------------------> 3. Group Permissions
| +----------------------------------> 2. Owner Permissions
+------------------------------------> 1. File Type
```

我们主要研究每一行的第一部分，第一部分有 9 个字符，按照 1，3，3，3 分别四个部分，其含义如下：

| File type         | User  | Group | Others |
| :---------------- | :---- | :---- | :----- |
| `d` Directory     | `rwx` | `r-x` | `r-x`  |
| `-` Regular file  | `rw-` | `r--` | `r--`  |
| `l` Symbolic Link | `rwx` | `rwx` | `rwx`  |

1. 第一个字母代表文件类型，有三种类型分别为：`d` 目录、`-` 常规文件、`l` 符号链接（软链接）

2. 余下九个字母，分三组分别为 user(Owner)，group，others 的权限。

    1. `r`: **R**ead

        - 文件是否可读
        - 目录内容可看

        ```shell
        # violetv at manjaro in ~/test [12:49:17]
        $ ll |grep batch.py
        ---------- 2 violetv violetv  426  6月 14 16:40 batch.py
        ---------- 2 violetv violetv  426  6月 14 16:40 hard_link_batch.py
        lrwxrwxrwx 1 violetv violetv    8  6月 29 10:02 soft_link_batch.py -> batch.py

        # violetv at manjaro in ~/test [12:49:20]
        $ cat batch.py
        cat: batch.py: Permission denied

        # violetv at manjaro in ~/test [12:49:20]
        $ cd ..
        # violetv at manjaro in ~ [12:49:20]
        $ ll|grep test
        drwxr-xr-x  2 violetv violetv 4.0K  6月  9 17:00 py_tests
        d-wx--x--x  3 violetv violetv 4.0K  6月 29 12:44 test
        drwxr-xr-x  4 violetv violetv 4.0K  6月 26 12:45 testsh

        # violetv at manjaro in ~ [12:50:06]
        $ ll test
        ls: cannot open directory 'test': Permission denied
        ```

    2. `w`: **W**rite

        - 文件内容是否可以被修改
        - 目录里的内容是否可以被修改（创建新文件，删除文件，重命名文件）
          注意：目录的写权限不影响文件自身的写权限，文件如果自身有写权限，那么文件内的内容可以修改，即：目录权限和文件权限，即：本身的读写执行无关。

        ```python
        # violetv at manjaro in ~/test [13:37:41]
        $ ll ../ |grep test
        drwxr-xr-x  2 violetv violetv 4.0K  6月  9 17:00 py_tests
        dr-xr-xr-x  3 violetv violetv 4.0K  6月 29 12:44 test
        drwxr-xr-x  4 violetv violetv 4.0K  6月 26 12:45 testsh

        # violetv at manjaro in ~/test [13:37:53]
        $ rm batch.py
        rm: remove write-protected regular file 'batch.py'? y
        rm: cannot remove 'batch.py': Permission denied

        # violetv at manjaro in ~/test [13:38:06]
        $ mv batch.py batch_temp.py
        mv: cannot move 'batch.py' to 'batch_temp.py': Permission denied
        ```

    3. `x`: e**X**ecu 对应位置（r 或 w 或 x）的权限

        - 文件是否可执行（是否具有可执行权限）
        - 目录是否可以 `cd` 进入

        ```python
        # violetv at manjaro in ~ [13:43:36]
        $ ll| grep test
        drwxr-xr-x  2 violetv violetv 4.0K  6月  9 17:00 py_tests
        dr--r--r--  3 violetv violetv 4.0K  6月 29 12:44 test
        drwxr-xr-x  4 violetv violetv 4.0K  6月 26 12:45 testsh

        # violetv at manjaro in ~ [13:43:43]
        $ cd test
        cd: permission denied: test
        ```

    - `-`: 代表没有该权限

> Note that access to files targeted by symbolic links is controlled by the permissions of the targeted file, not the permissions of the link object

## `chmod` 使用

`chmod [OPTIONS] MODE FILE...`

`chmod` (change mode) 命令允许你使用 3 种方式改变文件的权限：

1. Symbolic Method
2. Numeric Method
3. Reference Method

该命令可以接受一个或多个文件或目录（以空格分隔）作为参数

## Symbolic (Text) Method

当使用符号方法时，命令的格式大致为这样

`chmod [OPTIONS] [ugoa…][-+=]perms…,[…] FILE...`

第一个 flag（users flags）： `[ugoa…]` 定义要改变哪个用户类关于本文件的权限。
如果不指定此 flag， 默认为全部 users，也就相当于指定 flag `a`。

-   `u`： The **u**ser(the file owner).
-   `g`： The members of the **g**roup.
-   `o`： All **o**ther users.
-   `a`： **A**ll users, identical to ugo.

> If the users flag is omitted, the default one is a and the permissions that are set by umask are not affected.

第二个 flag（the operation flags）： `[-+=]` 定义哪些权限要被增加删除或者设置

-   `-`： Removes the specified permissions.
-   `+`： Adds specified permissions.
-   `=`： Changes the current permissions to the specified permissions.
    If no permissions are specified after the `=` symbol, all permissions from the specified user class are removed.

权限(perms...) 可以被明确地设定为 0 或者 `r,w,x` 中的一个或几个。此外，当你想要从一个用户类拷贝权限到另一个用户类时，也可以使用`u,g,o` 中的一个字符。

当设置为多个用户类别设置权限的时候，使用逗号（注意逗号前后不要空格，否则会报错）

例子：

`chmod a-x filename`、`chmod og-rwx filename`、`chmod og= filename`、`chmod u=rwx,g=r,o= filename`、`chmod g+u filename`

## Numeric Method

Octal Notation for File Permissions(文件权限的八进制表示法)

格式：`chmod [OPTIONS] NUMBER FILE...`

| column0       | column1  | column2  | column3                                                                                   |
| ------------- | -------- | -------- | ----------------------------------------------------------------------------------------- |
| 权限          | 权限数值 | 二进制   | 具体作用                                                                                  |
| r             | 4        | 00000100 | **r**ead，读取。当前用户可以读取文件内容，当前用户可以浏览目录。                          |
| w             | 2        | 00000010 | **w**rite，写入。当前用户可以新增或修改文件内容，当前用户可以删除、移动目录或目录内文件。 |
| x             | 1        | 00000001 | e**x**ecute，执行。当前用户可以执行文件，当前用户可以进入目录。                           |
| no permission | 0        | 00000000 | 无权限                                                                                    |

例如：`chmod 754 filename`

依照上面的表格，权限组合就是对应权限值求和，如下：

7 = 4 + 2 + 1 读写运行权限
5 = 4 + 1 读和运行权限
4 = 4 只读权限

即：将 filename 文件的读写运行权限赋予文件所有者，把读和运行的权限赋予群组用户，把读的权限赋予其他用户。

## Using a Reference File

格式： `chmod --reference=REF_FILE FILE`

The `--reference=ref_file` option 允许你参照指定文件设置相同的权限。

示例：

```shell
# violetv at manjaro in ~/test [14:54:48]
$ chmod 754 batch.py

# violetv at manjaro in ~/test [14:55:13]
$ ll
total 12K
-rwxrwxrwx 1 violetv violetv    0  6月 29 14:24 1.py
-rwxr-xr-- 2 violetv violetv  431  6月 29 13:45 batch.py


# violetv at manjaro in ~/test [14:55:14]
$ chmod --reference=batch.py 1.py

# violetv at manjaro in ~/test [14:55:26]
$ ll
total 12K
-rwxr-xr-- 1 violetv violetv    0  6月 29 14:24 1.py
-rwxr-xr-- 2 violetv violetv  431  6月 29 13:45 batch.py
```

## Recursively Change the File’s Permissions

对给定目录下的所有文件和目录进行递归操作，使用 `-R`（`--recursive`） 参数

格式：`chmod -R MODE DIRECTORY`

## Operating on Symbolic Links

符号链接（软链接）的权限总是为 777。当你要改变符号链接（软链接）的权限，实际上改变的是链接指向的文件的权限。

示例：batch.py 及其软链接

```shell
# violetv at manjaro in ~/test [14:57:54]
$ ll
total 12K
-rwxr-xr-- 1 violetv violetv    0  6月 29 14:24 1.py
-rwxr-xr-- 2 violetv violetv  431  6月 29 13:45 batch.py
-rwxr-xr-- 2 violetv violetv  431  6月 29 13:45 hard_link_batch.py
lrwxrwxrwx 1 violetv violetv    8  6月 29 10:02 soft_link_batch.py -> batch.py
drwxr-xr-x 2 violetv violetv 4.0K  6月 13 14:37 test1

# violetv at manjaro in ~/test [14:57:55]
$ chmod 777 soft_link_batch.py

# violetv at manjaro in ~/test [14:59:53]
$ ll
total 12K
-rwxr-xr-- 1 violetv violetv    0  6月 29 14:24 1.py
-rwxrwxrwx 2 violetv violetv  431  6月 29 13:45 batch.py
-rwxrwxrwx 2 violetv violetv  431  6月 29 13:45 hard_link_batch.py
lrwxrwxrwx 1 violetv violetv    8  6月 29 10:02 soft_link_batch.py -> batch.py
drwxr-xr-x 2 violetv violetv 4.0K  6月 13 14:37 test1
```

## Changing File Permissions in Bulk

1. 对某一个文件夹下所有的文件夹都赋予执行权限:
   例如：对 `~/foldername/` 文件都赋予执行权限：`chmod +x ~/foldername/*`

2. 使用 `find` 命令，例如：

    ```shell
    find /var/www/my_website -type d -exec chmod 755 {} \;
    find /var/www/my_website -type f -exec chmod 644 {} \;
    find /var/www/my_website -type d -exec chmod u=rwx,go=rx {} \;
    find /var/www/my_website -type f -exec chmod u=rw,go=r {} \;
    ```

## 参考资料

[Chmod Command in Linux (File Permissions)](https://linuxize.com/post/chmod-command-in-linux/)

[Modify File Permissions with chmod](https://www.linode.com/docs/tools-reference/tools/modify-file-permissions-with-chmod/)
