---
title: Pandas 中的索引与选择
comments: true
toc: true
tags:
    - ml
    - python
description: 本文主要学习 DataFrame 的索引与选择
summary: 本文主要学习 DataFrame 的索引与选择
categories:
    - programming
date: 2022-05-19 16:33:29
---

## 简介

尽管用来选择和设置操作的标准的 Python/Numpy 表达式非常方便，但是官方推荐优化的 pandas 数据访问方法`.at`, `.iat`, `.loc`, `.iloc`。

Pandas 的数据基础索引方式主要分为两种： Index-based selection（index,`iat`, `iloc`），Label-based selection（column, `at`, `loc`）、，第三种是条件索引 Conditional indexing/Boolean indexing，即前两种+布尔等式、不等式实现条件索引。

`loc`和`iloc`的异同（看不懂没关系，后面会讲）：

1. `loc` 和 `iloc` 都是 row-first，column-second,这意味取 row 比取 column 容易
2. 区间开闭

    `iloc` 是常见的前闭后开 [a, b)， 而`loc[a:b]` **闭区间[a, b]**

## Start

1. 选择单独的一列，会生成 Series，相当于 `df.A`

    ```python3
    In [8]: product
    Out[8]:
    Product A  Product B  Product C
    1         30         21          9
    2         35         34         10
    3         41         17         46
    4         43         12         75
    5         65         19         68
    6         13         10         32

    In [9]: product["Product A"]
    Out[9]:
    1    30
    2    35
    3    41
    4    43
    5    65
    6    13
    Name: Product A, dtype: int64
    ```

2. 通过 `[]`,可以对 row 切片：

    ```python3
    In [10]: product[1:3]
    Out[10]:
    Product A  Product B  Product C
    2         35         34         10
    3         41         17         46
    ```

## Index-based selection

无论对于那种 selection, index 都是 numerical 的，区别在于 column 是 numerical 的，还是 label。

`iloc`operator ：index-based selection: selecting data based on its numerical position in the data. `iloc` follows this paradigm。

注意：

1. 对于 `iloc` 而言，取列就需要提供列的 numeric indexers，提供 column label 便会报错。
2. 索引切片的规则都可以使用：前闭后开的范围[),负索引 -1，全索引 ：。

示例（`df` 是读取了数据的名为 `df` 的 DataFrame）：

-   取倒数第一行：`df.iloc[-1]`
-   取第一列：`df.iloc[:, 0]`, the `:` operator 切片指所有元素。
-   取：`reviews.iloc[[0, 1, 2], 0]`

### Label-based selection

`loc` operator: label-based selection，对列进行索引的时候使用 label/索引的值，而不是索引。

示例：

取第一行 country 列：`df.loc[0, 'country']`
取每一行的'taster_name', 'taster_twitter_handle', 'points'三列：`reviews.loc[:, ['taster_name', 'taster_twitter_handle', 'points']]`

## loc 与 iloc 异同

`loc`和`iloc`的异同：

1. `loc` 和 `iloc` 都是 row-first，column-second,这意味取 row 比取 column 容易
2. 区间开闭
   `iloc` uses the Python stdlib indexing scheme,所以是常见的前闭后开 [a, b)，`[1,3]`,则是 `1 2` 两个元素。

    而`loc[a:b]` 为闭区间[a, b]，`[1, 3]`,则是 `1, 2, 3`三个元素。

3.`iloc` 相比 `loc`多加的 `i` 是即是针对列，也是针对行的，只不过 index label 比较少见。

    行一般只有 index，而 `loc`, `iloc` 对行的 index 都支持，因此都可。如果行有index label，可使用 `loc`。

    列两种：
    要使用 column number index 选择，用 `iloc`
    要使用 column labels 选择，用 `loc`

4. `loc` 可以索引任何 stdlib type: strings

    如果索引（默认就说行索引）的索引值为 `Apples, ..., Potatoes, ...`，则可以岁该索引进行切片，`df.loc['Apples':'Potatoes']`:all the alphabetical fruit choices between Apples and Potatoes.当然，此时食用

    ```python3
    In [21]: df = pd.DataFrame({'Bob': ['I liked it.', 'It was awful.', 'good.', 'very good'],
        ...:                    'Sue': ['Pretty good.', 'Bland.', 'Just so so', 'Bad.']},
        ...:                   index=['Product A', 'Product B', "Product C","Product D"])
        ...: df.loc["Product B":"Product C"]
    Out[21]:
                        Bob         Sue
    Product B  It was awful.      Bland.
    Product C          good.  Just so so

    ...: df.iloc[1:3]
    Out[22]:
                        Bob         Sue
    Product B  It was awful.      Bland.
    Product C          good.  Just so so
    ```

`df.set_index("title")` 可以把 title 列设置成 label-based index

## Conditional selection

1. reviews 的 country 列是否等于'Italy'：`reviews.country == 'Italy'`
   返回 a Series of True/False booleans based on the country of each record.

2. 使用位与、位或操作符在两个 bool 表达式之间

`reviews.loc[(reviews.country == 'Italy') & (reviews.points >= 90)]`
`reviews.loc[(reviews.country == 'Italy') | (reviews.points >= 90)]`

内置选择器：`isin`、`isnull`、`notnull`

```python3
reviews.loc[reviews.country.isin(['Italy', 'France'])]
reviews.loc[reviews.price.notnull()]
```

## 赋值

可以赋单个值，也可以赋一个序列值：

`reviews['critic'] = 'everyone'`: 将 critic 列的值全部赋为 everyone
`reviews['index_backwards'] = range(len(reviews), 0, -1)`:为 index_backwards 赋予一个逆序列值。

## 参考

1. [Indexing, Selecting & Assigning | Kaggle](https://www.kaggle.com/code/residentmario/indexing-selecting-assigning#Manipulating-the-index)
2. [10 minutes to pandas — pandas 1.4.2 documentation](https://pandas.pydata.org/pandas-docs/stable/user_guide/10min.html#viewing-data)
