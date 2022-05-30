---
title: Python Object Reference
comments: true
toc: true
tags:
    - python
description: 本文通过介绍 Python 的内存管理、赋值与函数参数传递。对象可变性来深入解析：Python 的对象引用。
summary: 本文通过介绍 Python 的内存管理、赋值与函数参数传递。对象可变性来深入解析：Python 的对象引用。
categories:
    - programming
date: 2020-03-21 10:39:54
updated: 2020-07-21 16:01:54
---

## Objects: Identity, Type, and Value

作为一门面向对象的编程语言，Python 中的任何东西都是一个对象，包括内置数据类型（如：整型，字符串），函数，类，甚至模块。

但是，Python 中的对象到底是什么呢? 简而言之，对象相当于数据容器，它形成人与计算机之间的接口。程序员通过写代码来直接操作这些容器，从而以激素那几可以理解的方式实现一定的功能。

-   Identity
    对象是内存某个地方数据块。在大多数编程语言（包括：Python）中，我们使用这些数据块的内存地址来标识对象。也就是说，对象的内存地址表征一个对象的身份。
    在 CPython 实现中，内置函数 `id()` 返回对象的内存地址。

-   Type
    当对象被创建时，它的类型也在内存中被定义和设置了。
    从内存数据块的角度来说，当某个内存块被绑定到对象时，不仅仅它的标识符（身份）被创建了，而且他的类型(例如，整数，字符串)也被创建了。

    python 中提供内置函数的 `type()` 来判断对象的类型。

-   Value
    对象可以取的值由其类型决定。例如，如果一个对象的类型是整数，它就不能
    保存 dictionary 类型的数据，反之亦然。

## WHY？

首先，我们来看三段代码，并根据代码，尝试思考我提出的几个问题，如果你都能给出解答，那就不用看本文了，如果不理解，请继续往下看。

0. 分别创建两个具有相同值的对象与创建一个对象，然后采用赋值创建另一个对象有区别吗？
   即： 以下的 a, b c 一样吗？

    ```python
    In [3]: a=[1,2]
    In [4]: b=[1,2]
    In [5]: c=a
    ```

    知识点： 对 Python 中变量，对象及对象引用的理解

1. 分别创建两个具有相同值的对象，为什么对象的 `id` 时而相同，时而不同？
   知识点： Python 内存管理

2. 采用变量赋值的方式创建另一个对象情况下，为何有些数据类型， 改变另一个对象的值之后，另一个对象的，id 仍然不变，有的 id 却变了？
   知识点: 对象可变性与对象引用

```python
In [11]: a=257

In [12]: b=257

In [13]: id(a), id(b)
Out[13]: (140448785920880, 140448785920656)

In [14]: a=256

In [15]: b=256

In [16]: id(a), id(b)
Out[16]: (140448908007520, 140448908007520)
```

```python
## list 可变类型
In [1]: list_a = [1,2,"hello"]

In [2]: list_b = [1,2,"hello"]

In [3]: id(list_a), id(list_b)
Out[3]: (139867441284480, 139867441621120)

In [4]: list_c = list_a

In [5]: id(list_a), id(list_c)
Out[5]: (139867441284480, 139867441284480)

In [6]: list_c.append("World")

In [7]: id(list_a), id(list_c)
Out[7]: (139867441284480, 139867441284480)

In [8]: print(f"list_a: {list_a}\nlist_c: {list_c}")
list_a: [1, 2, 'hello', 'World']
list_c: [1, 2, 'hello', 'World']
```

```python
# int 不可变类型
In [9]: int_a = 3

In [10]: int_b = 3

In [11]: id(int_a), id(int_b)
Out[11]: (139867496413376, 139867496413376)

In [12]: int_c = int_a

In [13]: id(int_a), id(int_c)
Out[13]: (139867496413376, 139867496413376)

In [14]: int_c = 12

In [15]: id(int_a), id(int_c)
Out[15]: (139867496413376, 139867496413664)
```

## Memory Management

每次一个新的对象创建，它便会有一个新的内存地址，除非当它是

-   一个非常短的字符串
-   一个在 [-5，256] 之间的整型
-   一个空的不可变容器(例如: tuple))

### 示例

1. 新内存地址
   我们创建一个 L1 列表，然后再创建一个新的列表 L2 来引用和 L1 相同的值，那 L2 对应的对象将有一个新的内存。

    ```python
    >>> L1 = [1, 2, 3]
    >>> id(L1)
    3061530120
    >>> L2 = [1, 2, 3]
    >>> id(L2)
    3061527304
    ```

2. 相同的内存地址

    我们来看一个整型对象的例子， x 和 y 都引用对象 10。在之前的例子中 L1 和 L2 内存地址不同，而 x 和 y 引用的对象共享相同的内存地址。

    ```python
    >>> x = 10
    >>> y = 10
    >>> id(x)
    2301840
    >>> id(y)
    2301840
    ```

    这是因为，在这三个情况中，Python 通过让第二个变量引用内存中相同的对象来优化内存，有的把它叫做 "shared object”

## Variables

-   变量和数据(对象)都是保存在内存中的
-   在 Python 中函数的参数传递以及返回值都是靠对象引用(object reference) 传递的

### Variable Assignment

> Assignment statements in Python do not copy objects, they create bindings between a target and an object.

That means when we create a variable by assignment, the new variable refers to the same object as the original variable does.

```python
>>> A = [1, 2, [10, 11], 3, [20, 21]]
>>> B = A
>>> id(A)
3061527080
>>> id(B)
3061527080
```

Because the new variable B and the original variable A share the same object (i.e. the same list), they also contain same elements。

```python
>>> id(A[2])
3061527368
>>> id(B[2])
3061527368
```

As illustrated in the figure below, A and B share the same id, i.e., they refer to the same object in memory. And they contain the same elements as well.

![variable assigment](https://raw.githubusercontent.com/violetu/blogimages/master/20203201584671290252.png)

## Object refernce

The professor, Lynn Andrea Stein — an award-winning computer science educator — made the point that **the usual “variables as boxes” metaphor actually hinders the understanding of reference variables in OO languages.**

Python variables are like reference variables in Java, so it’s better to think of them as **labels attached to objects**.

在 python 中

-   变量和数据是分开存储的
-   数据保存在内存中的一个位置
-   变量中保存着数据在内存中的地址
-   变量中记录数据的地址，叫做引用
-   变量没有类型，类型属于对象，变量是对象的标识符或名字
    `num = 12`， num 只是一个名字，12 才是整型的对象
-   使用 `id()` 函数可以查看变量中保存数据所在的内存地址
-   Assignment statements in Python do not copy objects, they create bindings between a target and an object.
    That means when we create a variable by assignment, the new variable refers to the same object as the original variable does
-   如果变量已经被定义，当给一个变量赋值时， 本质上是修改了对象的引用，是让对象左边的变量标识右边的对象。
    -   变量不再对之前的对象引用
    -   变量改为对新赋值的数据引用

示例：

![](https://raw.githubusercontent.com/violetu/blogimages/master/20203201584668728073.png)

Python is “pass-by-object-reference”, of which it is often said:

> “Object references are passed by value.”

### mutable vs. immutable objects

1. Immutable: objects whose value cannot change
   tuple，int, float, bool, string, complex

    Immutable means that the object, the top-level container for the item, cannot be changed. Note that this applies only to the top level; it may contain references to sub-objects that are mutable.

    Tuples are not always immutable in Python, because tuples may hold references to mutable objects such as lists or dicts. A tuple is only immutable if all of its items are immutable as well.

2. Mutable: objects whose value can change
    1. dict, list, set
    2. User-defined objects (unless defined as immutable)
    3. Mutable object define the operation what can be doen to them, such as append, pop, remove, clear and so on.

This distinction matters because it explains seemingly contradictory behavior

Notice

1. The assign operation is meant to **tag** the variable to the object in the right of equal sign.(identifier of the object)
2. The mutable or immutable attribute of objects have nothing to do with the reference or the relation between identifier and obejct, which can alway be changed by assigning action by us manually.

#### 自定义函数实现 string 可变

hackerrank 有一道题目提供了些思路: [hackerrank Mutations](https://www.hackerrank.com/challenges/python-mutations/problem)

1. One solution is to convert the string to a list and then change the value，finally, join it back.
2. Another approach is to slice the string and join it back.

```python
def replaceCharByIndex(string, index, new):
    """
    Method 1: covert string to list -> replace -> join it back
    """
    test_list = list(string)
    test_list[index] = new
    string = "".join(test_list)
    print(string)

def replacebyIndex(string, index, new):
    """
    Method2: slice the string, then join it back
    """
    string = string[:index] + new + string[index+1:]
    print(string)

def repalceStrbyIndex(string, index, new):
    """"
    Method 2 适用性更广，可以改造成在固定 index 开始替换,
    来弥补 built-in function: repalce 只能根据旧的字串替换的功能
    """
    string = string[:index] + new + string[index+len(new):]
    print(string)

def main():
    test_str = input()
    index, new = input().split()
    repalceStrbyIndex(test_str, int(index), new)


if __name__ == "__main__":
    main()
```

### Pass by object reference

1. python 中一切皆对象，要想对对象进行改变，就要通过方法。
2. python 中对象的可变与不可变属性。
   像可变对象，例如: list, dict 等 python 定义了改变他们的方法，比如: `append、pop、remove、clear` 等, 而对于不可变对象，如：number，string，tuple 等对象，python 并没有改变他们的方法。

    写到这里，突然发现我可以分清楚: 用的方法是直接改变原对象，还是返回改变后的值了。对于不可变对象来说，不可能直接改变原对象。
    例如: string 虽然 python 提供了诸如 title，capitalize，upper 等方法，但那也只是拷贝一份修改，返回而已，不能够不直接改变原对象(因为它是不可变的)

    ```python
    In [24]: test.upper()
    Out[24]: 'HELLO'

    In [25]: test
    Out[25]: 'hello'
    ```

    而像列表这种，提供的 sort 等方法就是直接改变原对象。

    ```python
    In [28]: lis = [2,9,1,0]
    In [29]: lis
    Out[30]: [0, 1, 2, 9]
    ```

而 C++ 中的整数，浮点数，数组并不是对象, 即使是 string，array 等对象，也没有可变不可变的概念(当然事实上他们是可变的).

![string_c++](https://raw.githubusercontent.com/violetu/blogimages/master/20203201584672425098.png)

导致了 Python 引用出现与 c++ 引用不一致的情况。

最终，Python 的参数传递，也和变量赋值一样顺理成章的使用了对象引用（pass-by-object-reference），即传递的是一个对象的内存地址。

## Funciton reference

具体的资料没找到, 我是从 hackrank 的一道题目的讨论区中学到的，不过从 C/C++ 过来的我，感觉也挺容易理解的。

[String Validators](https://www.hackerrank.com/challenges/string-validators/problem)

知识点:

1. function reference
2. any 函数 (拓展: all 函数) -- 此知识点见 function usage 那篇笔记。

在不会这两点之前，我的 writeup 是这样的:

```python
def validators(string):
    validator_list = [False, False, False, False, False] # 5 个长度的list 代表 5 种类型

    for char in string:
        if char.isalnum():
            validator_list[0] = True
        if char.isalpha():
            validator_list[1] = True
        if char.isdigit():
            validator_list[2] = True
        if char.islower():
            validator_list[3] = True
        if char.isupper():
            validator_list[4] = True
    return validator_list

def main():
    validated_results = validators(input())
    [print(i, sep="\n") for i in validated_results]

if __name__ == "__main__":
    main()
```

学了这两个知识点之后，答案是这样的:

```python
def main():
    string = input()
    # 或者先获取 t = type(string) ，然后使用 t.isalnum 调用，不过，没太大必要，毕竟本身 input() 就返回字符串
    for method in [str.isalnum, str.isalpha, str.isdigit, str.islower, str.isupper]:
        print(any(method for c in string))

if __name__ == "__main__":
    main()
```

1. 函数引用
   使用示例:

```python
In [89]: t = print

In [90]: t("Hello", "World", sep="\n")
Hello
World
```

## 参考推荐

> [Assignment, Shallow Copy, Or Deep Copy?](https://towardsdatascience.com/assignment-shallow-or-deep-a-story-about-pythons-memory-management-b8fad87bfa6c) > [Pass by Object Reference in Python](https://secon.utulsa.edu/cs2123/slides/pypass.pdf) > [Python tuples: immutable but potentially changing](http://radar.oreilly.com/2014/10/python-tuples-immutable-but-potentially-changing.html) > [Python 的函数参数传递：传值？引用？](http://winterttr.me/2015/10/24/python-passing-arguments-as-value-or-reference/) > [6 Things to Understand Python Data Mutability](https://medium.com/swlh/6-things-to-understand-python-data-mutability-b52f5c5db191) > [copy — Shallow and deep copy operations](https://docs.python.org/3/library/copy.html)
