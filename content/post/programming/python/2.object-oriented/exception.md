---
title: Python exception handling
comments: true
toc: true
tags:
    - python
description: Python 中异常处理
categories:
    - programming
date: 2020-03-22 22:12:48
---

## 概念

-   程序在运行时，如果 Python 解释器**遇到**一个错误，**会停止程序的执行，并且提示一些错误信息**，这就是**异常**
-   **程序停止执行并且提示错误信息**这个动作，我们通常称之为：**抛出（raise）异常**

![exception](https://raw.githubusercontent.com/violetu/blogimages/master/20203211584756455085.png)

程序开发时，很难将**所有的特殊情况**都处理的面面俱到，通过**异常捕获**可以针对突发事件倣集中的处理，从而保证程序的**稳定性和健壯性**

## 捕获异常

在程序开发中，如果 **对某些代码的执行不能确定是否正确**，可以增加 `try(尝试)` 来 **捕获异常**

-   `try` **尝试**，下方编写要尝试代码，不确定是否能够正常执行的代码
-   `except` **如果不是**，下方编写尝试失败的代码

### 错误类型捕获

-   在程序执行时，可能会遇到 **不同类型的异常**，并且需要 **针对不同类型的异常，做出不同的响应**，这个时候，就需要捕获错误类型了
-   programming 根据引发异常的原因，将异常分为了很多种不同类别，在 except 子句中可以分别捕获指定类别的异常。
-   语法如下：

```python
try:
    # 尝试执行的代码
    pass
except 错误类型1:
    # 针对错误类型1，对应的代码处理
    pass
except (错误类型2, 错误类型3):
    # 针对错误类型2 和 3，对应的代码处理
    pass
except Exception as result:
    print("未知错误 %s" % result)
```

-   当 `Python` 解释器 **抛出异常** 时，**最后一行错误信息的第一个单词，就是错误类型**

### 异常捕获完整语法

-   在实际开发中，为了能够处理复杂的异常情况，完整的异常语法如下：

```python
try:
    # 尝试执行的代码
    pass
except 错误类型1:
    # 针对错误类型1，对应的代码处理
    pass
except 错误类型2:
    # 针对错误类型2，对应的代码处理
    pass
except (错误类型3, 错误类型4):
    # 针对错误类型3 和 4，对应的代码处理
    pass
except Exception as result:
    # 打印错误信息
    print(result)
else:
    # 没有异常才会执行的代码
    pass
finally:
    # 无论是否有异常，都会执行的代码
    print("无论是否有异常，都会执行的代码")
```

-   `else` 放在 except: 后面只有在没有异常时才会执行的代码，有异常发生时，就不会再执行（即使你进行了异常捕获）
-   `finally` 无论是否有异常，都会执行的代码

#### 捕获未知错误

-   在开发时，**要预判到所有可能出现的错误**，还是有一定难度的
-   如果希望程序 **无论出现任何错误**，都不会因为 `Python` 解释器 **抛出异常而被终止**，一般在最后增加一个 `except`

语法如下：

```python
except Exception as result:
    print("未知错误 %s" % result)
```

#### 异常类型捕获演练 —— 要求用户输入整数

**需求**

1. 提示用户输入一个整数
2. 使用 `8` 除以用户输入的整数并且输出

**完整捕获异常** 的代码如下：

```python
try:
    num = int(input("请输入整数："))
    result = 8 / num
    print(result)
except ValueError:
    print("请输入正确的整数")
except ZeroDivisionError:
    print("除 0 错误")
except Exception as result:
    print("未知错误 %s" % result)
else:
    print("正常执行")
finally:
    print("执行完成，但是不保证正确")
```

# 异常传递

-   **异常的传递** —— 当 **函数/方法** 执行 **出现异常**，会 将**异常传递** 给 函数/方法 的 **调用一方**
-   如果 **传递到主程序**，仍然 **没有异常处理**，程序才会被终止

提示：

-   在开发中，可以在主函数中增加 **异常捕获**
-   而在主函数中调用的其他函数，只要出现异常，都会传递到主函数的 **异常捕获** 中
-   这样就不需要在代码中，增加大量的 **异常捕获**，能够保证代码的整洁

**需求**

1. 定义函数 `demo1()` **提示用户输入一个整数并且返回**
2. 定义函数 `demo2()` 调用 `demo1()`
3. 在主程序中调用 `demo2()`

## 抛出 `raise` 异常

### 应用场景

-   在开发中，除了 **代码执行出错** `Python` 解释器会 **抛出** 异常之外
-   还可以根据 **应用程序** **特有的业务需求** **主动抛出异常**

### 抛出异常

BaseException 是所有异常的基类
Exception 是常规错误的基类

如果我们不太明确异常的类型，只知道可能出现常规错误，那么可以使用 `Exception` 基类创建对象。如果我们清除异常类型，那就可以创建一个对应类型的异常队形，比如： `TypeError` 异常对象

比如：在开发时，如果满足特定业务需求时希望抛出异常，可以:

1. **创建** 一个 `Exception` 的 **对象**，传入错误信息参数
2. 使用 `raise` **关键字** 抛出 **异常对象**
   这里有 raise 语句和 raise 函数两种选择

### 抛出 TypeError 异常

```python
## raise 语句
raise TypeError("参数类型不正确")

## raise 函数
raise(TypeError("参数类型不正确"))

## 更可以
ex = Exception('密码长度不够')
raise (ex)
```

### 示例 2

-   提示用户 **输入密码**，如果 **长度少于 8**，抛出 **异常**

注意

-   当前函数 **只负责** 提示用户输入密码，如果 **密码长度不正确，需要其他的函数进行额外处理**
-   因此可以 **抛出异常**，由其他需要处理的函数 **捕获异常**

**需求**

-   定义 `input_password` 函数，提示用户输入密码
-   如果用户输入长度 < 8，抛出异常
-   如果用户输入长度 >=8，返回输入的密码

```python
def input_passwd():
    # 1. tell user to input password
    pwd = input("请输入密码:")

    # 2. 判断密码长度 >= 8, 返回用户密码
    if len(pwd) >= 8:
        return pwd

    # 3. 如果 < 8, 抛出异常
    print('raise an exception')

    # create Exception object
    ex = Exception('密码长度不够')

    # raise an exception actively
    raise (ex)

try:
    print(input_passwd())
except Exception as result:
    print(result)
```

## 断言

The simple form, assert expression, is equivalent to

```python
if __debug__:
    if not expression: raise AssertionError
```

The extended form, assert expression1, expression2, is equivalent to

```python
if __debug__:
    if not expression1: raise AssertionError(expression2)
```

Assignments to **debug** are illegal. The value for the built-in variable is determined when the interpreter starts.

示例：

```python
In [54]: assert 1==2,"1 不等于 2"
---------------------------------------------------------------------------
AssertionError                            Traceback (most recent call last)
<ipython-input-54-4e6a0102cb72> in <module>
----> 1 assert 1==2,"1 不等于 2"

AssertionError: 1 不等于 2
```

### 常见 Python 异常类型

FileNotFoundError：找不到指定文件的异常
NameError：未声明 or 未初始化对象（没有属性）
BaseException：所有异常的基类（父类），即包含所有的异常

参考文章:

[python 中异常捕获的完整语法和常见的异常类型](https://blog.csdn.net/weixin_45459224/article/details/97487245#python_77)
