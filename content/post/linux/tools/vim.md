---
title: vim 入门简单使用
comments: true
toc: true
tags:
    - vim
description: 入门 vim， 并掌握 vim 常用操作，并不涉及寄存器等高级技巧。
categories:
    - linux
    - tools
date: 2020-02-13 21:11:25
---

## 三种模式

-   **Insert mode** is where you insert i.e. write the text.
-   **Normal mode** is where you can run commands. This is the default mode in which  Vim starts up.
-   **Visual mode** is where you visually select a bunch of text, so that you can run a command/operation only on that part of the text.

### insert 模式

normal mode → insert mode：

1. 按下 `i` 表示 insert， 插入东西到光标前
2. 按下 `I` 表示 insert before line， 插入东西到当前行首
3. 按下 `a`，表示 append， 追加东西到光标后
4. 按下 `A`，表示 append， 追加东西到当前行尾
5. 按下 `o`， 表示 open a line below， 在下面新建一行。
6. 按下 `O`， 表示 open a line above， 在 上面新建一行。

Esc ：Insert mode → Normal mode

`:wq` 写入并退出( write and quit )

### Normal 模式

输入`:` 后，进入命令模式

`:vs` (vertical split)

`:sp` (split)

`:% s/foo/bar/g` 全局替换

`:set nu!` 设置行号

命令模式下，不小心按错命令，可以按 Esc 消除命令

复制一行：`yy`

复制 n 行：`nyy`

也可进入 visual 模式，选择多行，然后 `yy`

1. 选定文本块。使用 v 进入可视模式，移动光标键选定内容。
2. 复制的命令是 `y`，即 yank（提起） ，常用的命令如下：

    `y`: 在使用 v 模式选定了某一块的时候，复制选定块到缓冲区用；

    `yy`: 复制整行（`nyy` 或者 `yny` ，复制 n 行，n 为数字）；

    `y^`: 复制当前到行头的内容；

    `y$`: 复制当前到行尾的内容；

    `yw`: 复制一个 word （`nyw` 或者 `ynw`，复制 n 个 word，n 为数字）；

    `yG`: 复制至档尾（`nyG` 或者 `ynG`，复制到第 n 行，例如 1yG 或者 y1G，复制到档尾）

3. 删除的命令是 `d`，即 delete，`d` 与 `y` 命令基本类似，所以两个命令用法一样，包括含有数字的用法. d 删除选定块到缓冲区；

    `dd`: 剪切整行

    `ndd`: 向后剪切 n 行（包含所在行）

    `d^`: 剪切至行首

    `d$` 或 `G`: 剪切至行尾

    `dw`: 剪切一个 word

    `dG`: 剪切至文档尾

    删除的命令 `c` 跟 `d` 类似，但是删除完成后会进入插入模式

4. 粘贴的命令式 `p`，即 paste（放下）

    小写 `p` 向后粘贴, 代表贴至游标后（下），因为游标是在具体字符的位置上，所以实际是在该字符的后面.

    大写 `P` 向前粘贴,代表贴至游标前（上）

    整行的复制粘贴在游标的上一行，非整行的复制则是粘贴在游标的前

注： 在正则表达式中，`^` 表示匹配字符串的开始位置，`$` 表示匹配字符串的结束位置。 命令前面加数字表示重复的次数，加字母表示使用的缓冲区名称。使用英文句号"."可以重复上一个命令。 在复制粘贴时，另一组常用的命令是 `u`（撤销操作），`U`（撤销某一行最近所有修改），`Ctrl+R`（重做），这些功能主要是 vim 中的，vi 中略有差别

## 删除所有内容

命令为：`ggdG`

讲解：`gg` 为跳转到文件首行；`dG` 为删除光标所在行以及其下所有行的内容，其中 `d` 为删除，`G` 为跳转到文件末尾行；

### 移动

`home` 键 行首、`end` 键 行尾、

`h` 向左、`j` 向下、`k` 是向上、`l` 是向右

向下跳 10 行：`10j`

向上跳 10 行：`10k`

向上翻页：`pgup` 或者 `ctrl + b(backwad)`

向下翻页: `pgdn` 或者 `ctrl +f （forward）`

按单词向后移动 ： w (word)

按单词往回移动：b （back）

## Vim 快速移动光标至行首和行尾

1. 需要按行快速移动光标时，可以使用键盘上的编辑键 `home`，快速将光标移动至当前行的行首。除此之外，也可以在命令模式中使用快捷键 `^`（即 `Shift+6`）或 `0`（数字 0）。

2. 如果要快速移动光标至当前行的行尾，可以使用编辑键 End。也可以在命令模式中使用快捷键 `$（Shift+4）`。与快捷键 `^` 和 `0` 不同，快捷键 `$` 前可以加上数字表示移动的行数。例如使用"1\$"表示当前行的行尾，`2$` 表示当前行的下一行的行尾。

## vim 跳转到指定行

1. `ngg 或 nG`，其中 n 是想跳转到的行标，如 10gg，或 10G，但这种方式输入时不显示所输内容，个人感觉不够直观。

2. `:n`，在一般模式下按冒号进入命令模式，直接输行标，然后回车。这种方法直接显示所输内容。

3. 一般模式下直接输入`H`移动到当前屏幕第一行（home）；`M`移动到当前屏幕中间一行（middle）; `L`移动到当前屏幕最后一行（last）。

### 搜索

输入 `/`，然后输入要搜索的东西，**并回车**即可。

查看上一个匹配位置：`shift + n`

查看下一个匹配位置：`n`

[在 Vim 中优雅地查找和替换 Vim-Practice](https://harttle.land/2016/08/08/vim-search-in-file.html)
