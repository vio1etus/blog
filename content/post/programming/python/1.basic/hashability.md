---
title: Hashability in Python
comments: true
toc: true
tags:
    - python
description: Python 对象的 hashable 和 unhashable
categories:
    - programming
    - intermediate
date: 2020-03-21 10:39:54
updated: 2020-07-21 16:01:54
---

## Introduction

> hashable
>
> An object is hashable if it has a hash value which never changes during its lifetime (it needs a `__hash__()` method), and can be compared to other objects (it needs an `__eq__()` method). Hashable objects which compare equal must have the same hash value.
>
> Hashability makes an object usable as a **dictionary key and a set** member, because these data structures use the hash value internally.
>
> Most of Python’s immutable built-in objects are hashable; mutable containers (such as lists or dictionaries) are not; **immutable containers (such as tuples and frozensets) are only hashable if their elements are hashable**. Objects which are instances of **user-defined classes are hashable by default**. They all compare unequal (except with themselves), and **their hash value is derived from their `id()`**.
>
> --From the [Python glossary](https://docs.python.org/3/glossary.html)

## Which Objects Are Hashable and Which Are Not

我们知道 `set` 的元素和 `dict` 的键 key 要求是 hashable 的，因此我通过了 `set` 测试，得出如下结果：

Hashable data types: int, float, str, tuple, and NoneType.
Unhashable data types: dict, list, and set.

测试过程：

```python
In [1]: test_set=set()
In [2]: test_set.add(None)
In [3]: test_set.add(1)
In [4]: test_set.add(2.1)
In [5]: test_set.add(True)
In [6]: test_set.add("hello")
In [7]: test_set.add(("name", "tel"))

In [8]: test_set.add({"name": 123})
-------------------------------------------------------------------
TypeError                         Traceback (most recent call last)
<ipython-input-8-9df12f1bbe21> in <module>
----> 1 test_set.add({"name": 123})

TypeError: unhashable type: 'dict'

In [9]: test_set.add([1,2])
-------------------------------------------------------------------
TypeError                         Traceback (most recent call last)
<ipython-input-9-951f4013eb98> in <module>
----> 1 test_set.add([1,2])

TypeError: unhashable type: 'list'

In [11]: test_set.add({1,2,3})
-------------------------------------------------------------------
TypeError                         Traceback (most recent call last)
<ipython-input-11-fa63e6bfd44d> in <module>
----> 1 test_set.add({1,2,3})

TypeError: unhashable type: 'set'
```

## What Does Hashable Mean

Hashable: A characteristic of a Python object to indicate whether the object has a hash value, which allows the object to serve as a key in a dictionary or an element in a set.

Python 实现了内置的 hash 函数：`hash()`，来生成的对象的 hash。例如：

```python
In [13]: hash("Hello")
Out[13]: 4478279774205738605

In [14]: hash([1,2])
-------------------------------------------------------------------
TypeError                         Traceback (most recent call last)
<ipython-input-14-9ce67481a686> in <module>
----> 1 hash([1,2])

TypeError: unhashable type: 'list'
```

## Customize Hashability

By default, all instances of custom classes will have a hash value defined at creation and it will not change over time. Two instances of the same class will have two different hash values.

You will see that the hash value that you get from your objects changes every time you run the code. **This is because the hash is derived from the object's id**. Python, as expected, allows you to define your own hash value.

By default, custom class instances are compared by comparing their identities using the built-in id() function. That's why two object with the same attribute value isn't the same one from the set or dictionaries perspective.

结论： Dictionaries and set check two things: **the hash value**(The return value of `self.__hash__`) and **the equality**(`self.__eq__`)

实验：

```python
#!/usr/bin/env python
# coding=utf-8
class Person:

    def __init__(self, name ,ssn):
        self.name = name
        self.ssn = ssn

    def __repr__(self):
        return f"name: {self.name}, ssn: {self.ssn}"

    def __hash__(self):
        print("__hash__ is called")
        return hash((self.name, self.ssn))

p0 = Person("Jon Smith", "123456")
p1 = Person("Jon Smith", "123456")

persons = set()

persons.add(p0)
print(persons)
print("-"*20)

persons.add(p1)
print(persons)
print("-"*20)
```

无论有无 `__hash__()` 时，结果都为：集合将两个相同属性值的对象看作是不同的对象。

从下面结果可以看出。 `set` 通过执行 `__hash__()` 检查了对象的 hash

```python
# violetv at manjaro in ~/test [21:03:54]
$ python hashable.py
__hash__ is called
{name: Jon Smith, ssn: 123456}
--------------------
__hash__ is called
{name: Jon Smith, ssn: 123456, name: Jon Smith, ssn: 123456}
--------------------
```

当我们在上述代码的对象中添加了 `__eq__()` 函数之后，我们可以看到了 set 已经将两个对象识别为一个了。

```python
def __eq__(self, other):
    print("__eq__ is called")
    return (
        self.__class == other.__class__ and
        self.name == other.name and
        self.ssn == other.ssn
    )
```

```python
$ python hashable.py
__hash__ is called
{name: Jon Smith, ssn: 123456}
--------------------
__hash__ is called
__eq__ is called
{name: Jon Smith, ssn: 123456}
--------------------
```

## 参考资料

> [What are Hashable Objects](https://www.pythonforthelab.com/blog/what-are-hashable-objects/) > [What the difference between hash-able and immutable](https://stackoverflow.com/questions/56154702/what-the-difference-between-hash-able-and-immutable) > [3 Essential Questions About Hashable in Python](https://medium.com/better-programming/3-essential-questions-about-hashable-in-python-33e981042bcb) > [Python Glossary](https://docs.python.org/3/glossary.html)
