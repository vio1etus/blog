---
title: 自己实现 python print 函数
comments: true
toc: true
tags:
    - fun
    - python
description: 自己实现了 python 的 print 函数，仅供练习与玩耍。
summary: 自己实现了 python 的 print 函数，仅供练习与玩耍。
categories:
    - programming
date: 2020-07-21 16:01:54
---

今天复习 Python 的输入输出，看到之前的笔记只写了 print 的底层是 sys.stdout， 而没有再细说。于是，心想它是怎么使用 sys.stdout 实现的呢？ 于是又仔细研究了一下 python 函数的各个参数，遂自己写了一个 print。 就当练习语法和玩耍了，哈哈。

## 知识点

1. 多值参数
   一个 `*`： 元组; 两个星 `*`: 字典

2. 列表推导式

3. `sys.stdout` 标准输出流

4. [Python 类型标注支持](https://docs.python.org/zh-cn/3.8/library/typing.html)

    - [ ] Python 类型标注

5. if-else 表达式，还是 `or`
   写的过程中， 我本来准备将 `file` 参数设置成 `None` 的， 因为按理说，可变对象参数需要使用 None 作为的默认值，从而避免对编译时生成的默认参数对象进行修改，造成意外事故。

    如果要使用 `file=None` 的话，那输出那里就需要判断一下

    ```python
    if file:
        file.write(output_content)
    else:
        sys.stdout.write(output_content)
    ```

    但是，感觉很不简洁，于是使用 `or` 进行条件判断，并好奇 if-else 和 or 的优劣，就搜索到了 [stackoverflow 的文章](https://stackoverflow.com/questions/51802974/if-else-vs-or-operation-for-none-check)，还是 `or` 性能好。

    ```python
    sys.stdout = file or sys.stdout
    sys.stdout.write(output_content)
    ```

    - [ ] [Python 陷阱：为什么不能用可变对象作为默认参数的值](https://foofish.net/python-tricks.html)

6. 最终我又换成了 `file=sys.stdout`，根据：

    1. [stackoverflow 一篇文章](https://stackoverflow.com/questions/42762120/sys-stdout-as-default-function-argument)

    2. [Python 官方文档 print 默认参数](https://docs.python.org/3.5/library/functions.html?highlight=built#print)

## 代码

```python
#!/usr/bin/env python
# coding=utf-8
import sys
import os


def my_print(*obj, sep: str = " ", end: str = "\n", file=sys.stdout, flush: bool = False) -> None:

    str_converted = [str(obj_item) for obj_item in obj]
    output_content = sep.join(str_converted)+end

    file.write(output_content)

    if flush:
        sys.stdout.flush()


def main():
    # 使用测试
    my_print("You", "Me", sep=" ^--^ ", end="\nGo!\n")
    my_print([1, 2, 3, 4], (1, 2, 3), {
             "name": "Violetu", "sex": "male"}, sep="\n", end="\nThis is the end!\n")
    print("-"*30)

    filename = "test.txt"
    with open(filename, "w") as fp:
        my_print(f"I'm the text written to {filename}", file=fp)

    os.system(f"cat {filename}")


if __name__ == "__main__":
    main()
```

## 参考资料

> 1. [sys.stdout as default function argument](https://stackoverflow.com/questions/42762120/sys-stdout-as-default-function-argument)
> 2. [if-else vs “or” operation for None-check](https://stackoverflow.com/questions/51802974/if-else-vs-or-operation-for-none-check)
