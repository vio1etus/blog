---
title: Pandas
comments: true
tags:
    - ml
    - python
    - pandas
    - basic
description: 本文主要入门学习 Pandas 的基本数据结构及其创建与csv文件数据读取
categories:
    - python
date: 2022-05-18 21:33:29
---

## Pandas 入门

Pandas 中两个核心对象/数据结构：`DataFrame` 和 `Series`，其中`DataFrame`为主要数据结构，它可以看做是 `Series` 对象的类字典结构的容器。`Series` 是数值的序列。`DataFrame` 是带有索引的 table-like 数据结构，`Series` 是带有索引的 list-like 数据结构，通过列表即可创 `Series`，而 `DataFrame` 则需要二维的数据结构，如：字典，多维列表等创建。

安装：`pip install pandas`
导入：`import pandas as pd`

## Series 创建

一个 Series 实际上是 DataFrame 的一列，而一个 DataFrame 实际上可以看做是由一系列 Series 组成。通过 index 参数可以对 Series 的列的 row 索引（即：通过 index 指定 row label），但是由于其只有一列，所以没有赋予 column label 的意义与功。而是其有一个整体的名字，通过 `name` 赋值。

```python3
# 不带 index, 默认递增索引
In [2]: a_list = [1,2,3]
   ...: pd.Series(a_list)
Out[2]:
0    1
1    2
2    3
dtype: int64

# 带 index 索引 row
In [3]: a_list = [1,2,3]
   ...: pd.Series(a_list, index=["2016 Sales", "2017 Sales", "2018 Sales"])
Out[3]:
2016 Sales    1
2017 Sales    2
2018 Sales    3
dtype: int64

# 带 index ，带 name
In [7]: pd.Series(a_list, index=["2016 Sales", "2017 Sales", "2018 Sales"], name="Production A")
Out[7]:
2016 Sales    1
2017 Sales    2
2018 Sales    3
Name: Production A, dtype: int64
```

## DataFrame 的创建

`class pandas.DataFrame(data=None, index=None, columns=None, dtype=None, copy=None)`
Two-dimensional, size-mutable, potentially heterogeneous tabular data
二维的数据结构，大小可变，可以容纳异构数据

> -   data: ndarray (structured or homogeneous), Iterable, dict, or DataFrame
>     Dict can contain Series, arrays, constants, dataclass or list-like objects. If data is a dict, column order follows insertion-order. If a dict contains Series which have an index defined, it is aligned by its index.
>
> -   index: The index (row labels) of the DataFrame.
> -   columns: The column labels of the DataFrame.
> -   dtype: Data type to force. Only a single dtype is allowed. If None, infer.

DataFrame 可以由很多数据结构创建而来，基础的分别有：Series, arrays,ndarray, constants, dataclass or list-like objects。

### 由文件读取

很多时候我们并不需要手动创建 DataFrame 或 Series，而是读取操作现有的数据，常见数据格式有 CSV

```python3
In [6]: product = pd.read_csv("./data/product.csv")

In [7]: product
Out[7]:
   Unnamed: 0  Product A  Product B  Product C
0           1         30         21          9
1           2         35         34         10
2           3         41         17         46
3           4         43         12         75
4           5         65         19         68
5           6         13         10         32

In [8]: product.shape
Out[8]: (6, 4)
```

当数据量较大的时候，可以使用 `head(), tail()` 查看前五行或者后五行:

```python3
In [9]: product.head
Out[9]:
<bound method NDFrame.head of    Unnamed: 0  Product A  Product B  Product C
0           1         30         21          9
1           2         35         34         10
2           3         41         17         46
3           4         43         12         75
4           5         65         19         68
5           6         13         10         32>

In [11]: product.tail
Out[11]:
<bound method NDFrame.tail of    Unnamed: 0  Product A  Product B  Product C
0           1         30         21          9
1           2         35         34         10
2           3         41         17         46
3           4         43         12         75
4           5         65         19         68
5           6         13         10         32>
```

可以看到 pandas 会自动生成索引，如果希望 pandas 使用某一列作为索引(而不是从头创建一个新索引)，可以使用 `index_col` 指定猎德使用第 0 行作为索引。

> `index_col`: int, str, sequence of int / str, or False, optional, default None
> Column(s) to use as the row labels of the `DataFrame`, **either given as string name or column index**.

```python3
In [12]: product = pd.read_csv("./data/product.csv", index_col=0)

In [13]: product
Out[13]:
   Product A  Product B  Product C
1         30         21          9
2         35         34         10
3         41         17         46
4         43         12         75
5         65         19         68
6         13         10         32
```

### 向文件写入

`DataFrame.to_csv(file_name, sep=',', encoding='utf-8', index=)`

将 DataFrame 对象写入逗号分隔的 CSV 文件中, file_name 必选参数，其余可选。

> `sep=','`: 默认输出文件以逗号分隔符,可以自行修改。
> `encoding='utf-8'`: 默认输出文件编码为 utf-8，可自行修改
> `index=True`: 默认将索引也写入文件，可以设置为 False 不写入索引。

```python3
animals = pd.DataFrame({'Cows': [12, 20], 'Goats': [22, 19]}, index=['Year 1', 'Year 2'])
animals.to_csv("cows_and_goats.csv")
```

### 由 Dict 创建

由字典创建，将字典值赋给 column labels，默认对索引进行递增（row），可以使用 index 自定义。

```python3
# 1. 无自定义 index，默认生成自然数作为索引
In [2]: pd.DataFrame({'Yes': [50, 21], 'No': [131, 2]})
Out[2]:
   Yes   No
0   50  131
1   21    2

# 2. 自定义行
In [3]: pd.DataFrame({'Bob': ['I liked it.', 'It was awful.'],
                'Sue': ['Pretty good.', 'Bland.']},
                index=['Product A', 'Product B'])
Out[3]:
                Bob           Sue
Product A    I liked it.  Pretty good.
Product B  It was awful.        Bland.
```

### 由包含 Series 的 Dict 创建

前面说到 Series 可以看做带索引的 List-like 数据结构，于是包含 Series 的 Dict 和一般的包含 List 的 Dict 都可以创建 DataFrame 不足为奇。不同之处在于，Series 是可以指定索引的，通过指定部分索引上的元素，可以实现部分指定元素，其余为缺失值，但此情况创建 DataFrame 时，需要指定 index，否则会报错。

```python3
In [19]: d = {"col1":[1, 2, 3,4], "col2":pd.Series([10,11], index=[1, 3])}

In [20]: pd.DataFrame(d, index=[0, 1, 2, 3])
Out[20]:
   col1  col2
0     1   NaN
1     2  10.0
2     3   NaN
3     4  11.0
```

## 由 numpy ndarray 创建

通过 ndarray 创建与通过字典创建的 DataFrame 不同之处：

1. 字典每个键值对应的列表/Series 是一列，而 ndaaray 二维数组，每个数组是一行。
2. 通过字典创建的 DataFrame 具有 column labels，不需要手动赋予，而 numpy 的 ndarray 便是 index /row labels 和 column labels 自动生成，因此均可以通过 `index` 赋予索引/row labels，也可以通过`columns` 赋予 column labels。

```python3
In [22]: data = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

In [23]: df2 = pd.DataFrame(data, columns=["a", "b", "c"])

In [24]: df2
Out[24]:
   a  b  c
0  1  2  3
1  4  5  6
2  7  8  9

In [25]: df3 = pd.DataFrame(data, index=["a", "b", "c"])

In [26]: df3
Out[26]:
   0  1  2
a  1  2  3
b  4  5  6
c  7  8  9
```

## 参考

1. [pandas.DataFrame — pandas 1.4.2 documentation](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html)

2. [Creating, Reading and Writing | Kaggle](https://www.kaggle.com/code/residentmario/creating-reading-and-writing)

3. [python - Writing a pandas DataFrame to CSV file - Stack Overflow](https://stackoverflow.com/questions/16923281/writing-a-pandas-dataframe-to-csv-file)
