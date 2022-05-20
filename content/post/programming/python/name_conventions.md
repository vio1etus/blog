---
title: Python 命名规范
comments: true
toc: true
tags:
    - python
description: 本文主要记录 Python 命名规范，以便自己在项目开发与合作过程中，写出规范 Python 的代码。
categories:
    - programming
date: 2019-07-25 15:18:25
---

## Introduction

代码规范是一系列用来产生可维护， 可扩展代码的指南。你编写的代码的规范程度决定了你在软件开发领域的职业生涯的寿命。我从 Python PEP8 文档中获取了这些代码命名规范信息，并尝试用简单明了的语言讲述，以便使得读者更容易理解与消化。通过本文的信息，你可以确保代码的质量，可读性和重用性。

你可以通过查阅 [**Python code optimization**](https://www.techbeamers.com/python-code-optimization-tips-tricks/) 来提高你所编写的 Python 应用程序的代码性能与健壮性。此外，Github 上的 python-guide 项目中关于代码实践的部分 [Writing Great Python Code](https://docs.python-guide.org/#writing-great-python-code)，你也不能错过。

请记住：命名规范只是许多 Python 编码标准的一个方面。你可以在[**PEP8 documentation**](https://www.python.org/dev/peps/pep-0008/) 读到其他的方面。

-   [ ] Python 其他方面的编码标准

## 应该避免的名称

-   单字符名称, 除了计数器和迭代器.
-   包/模块名中的连字符(`-`)
-   双下划线开头并结尾的名称(Python 保留, 例如`__init__`)

## 命名约定

-   所谓”内部(Internal)”表示仅模块内可用, 或者, 在类内是保护或私有的.
-   用单下划线(`_`)开头表示模块变量或函数是 protected 的(使用 `from module import *` 时不会包含).
-   用双下划线(`__`)开头的实例变量或方法表示类内私有.
-   将相关的类和顶级函数放在同一个模块里. 不像 Java, 没必要限制一个类一个模块.
-   对类名使用大写字母开头的单词(如 `CapWords`, 即 Pascal 风格), 但是模块名应该用小写加下划线的方式(如 `lower_with_under.py`). 尽管已经有很多现存的模块使用类似于 `CapWords.py` 这样的命名, 但现在已经不鼓励这样做, 因为如果模块名碰巧和类名一致, 这会让人困扰.

## Python 之父 Guido 推荐的规范

| Type                       | Public               | Internal                                                              |
| -------------------------- | -------------------- | --------------------------------------------------------------------- |
| Modules                    | `lower_with_under`   | `_lower_with_under`                                                   |
| Packages                   | `lower_with_under`   |                                                                       |
| Classes                    | `CapWords`           | `_CapWords`                                                           |
| Exceptions                 | `CapWords`           |                                                                       |
| Functions                  | `lower_with_under()` | `_lower_with_under()`                                                 |
| Global/Class Constants     | `CAPS_WITH_UNDER`    | `_CAPS_WITH_UNDER`                                                    |
| Global/Class Variables     | `lower_with_under`   | `_lower_with_under`                                                   |
| Instance Variables         | `lower_with_under`   | `_lower_with_under` (protected) or `__lower_with_under` (private)     |
| Method Names               | `lower_with_under()` | `_lower_with_under()` (protected) or `__lower_with_under()` (private) |
| Function/Method Parameters | `lower_with_under`   |                                                                       |
| Local Variables            | `lower_with_under`   |                                                                       |

## References

> 1. [Python Naming Conventions — The 10 Points You Should Know](https://medium.com/@dasagrivamanu/python-naming-conventions-the-10-points-you-should-know-149a9aa9f8c7)
> 2. [Python 风格规范](https://zh-google-styleguide.readthedocs.io/en/latest/google-python-styleguide/python_style_rules/#id16)
