---
title: __str__、__repr__ 和 __ascii__
comments: true
toc: true
tags:
    - python
description: 本文主要学习记录了四个知识点：str，repr 函数与类方法及其区别以及格式化输出二者的 `!r` 与 `!s`
summary: 本文主要学习记录了四个知识点：str，repr 函数与类方法及其区别以及格式化输出二者的 `!r` 与 `!s`
categories:
    - programming
date: 2020-07-22 22:16:58
---

当你直接输出一个自定义对象时，输出结果来自于：

1. 你重写的，`__str__` 的返回值
2. 如果你没有重写 `__str__`， 则使用你重写的 `__repr__` 的返回值
3. 如果你两个都没有重写，则不输出东西。

## `__repr__`

`__repr__`（representations of python object）的目的为了更加使意思清楚，消除歧义。它是给开发者准备的，用来调试。

功能：

1. 为了是 shi 该对象更容易被程序员理解。终端用户输出一些信息
2. 断点调试
   通过重写 “**repr**()”, 输出对象的时候，可以输出该对象的详细信息，为你 Debug 等提供帮助。

3. 建议为任何自定义的类重写 `__repr__`

4. Container’s `__str__` uses contained objects `__repr__`

```python
#!/usr/bin/env python
# coding=utf-8
class obj:
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return f"this is  __str__, it's value is {self.value}"

    def __repr__(self):
        return f"this is  __repr__, it's value is {self.value}"

a = obj("hello")
print("{!r}\n\n{!s}".format(a.__repr__, a.__str__))
```

## `__str__`

`__str__` 的目的为了可读性，是为（终端）用户准备的

`str()` 函数调用的就是对象的 `__str__` 方法。

如果你希望有一个字符串版本的可读性比较好的输出，那么再实现一下 `__str__`

!s (apply str()) and !r (apply repr()) can be used to convert the value before it is formatted.

##

It just calls the repr of the value supplied.

It's usage is generally not really needed with f-strings since with them you can just do repr(self.radius) which is arguably more clear in its intent.

!r (repr), !s (str) and !a (ascii) were kept around just to ease compatibility with the str.format alternative, you don't need to use them with f-strings.

## References

[String Representations in Python — Understand repr() vs. str()](https://medium.com/swlh/string-representations-in-python-understand-repr-vs-str-12f046986eb5)
[What does !r do in str() and repr()?](https://stackoverflow.com/questions/38418070/what-does-r-do-in-str-and-repr)
[In Python format (f-string) strings, what does !r mean?](https://stackoverflow.com/questions/44800801/in-python-format-f-string-strings-what-does-r-mean)
