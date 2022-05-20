---
title: Pandas 中的索引与选择
comments: true
tags:
    - ml
    - python
    - pandas
    - basic
description: 本文主要学习 DataFrame 的索引与选择
categories:
    - python
date: 2022-05-19 16:33:29
---

##

loc iloc 主要区别两个：

1. 区间开闭
2. 多加的 i 是针对于列的，而不是针对于行的，选择整个行的话，二者都可以，选择列的话，用 loc 偏向于使用 column labels，用 iloc 偏向于使用 column number index

通过 numpy ndarray 生成 DataFrame 记住是每个列表是一行，而不是字典那样每个是一列
