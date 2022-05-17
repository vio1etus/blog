---
title: webug之post注入
toc: true
description: 本文通过介绍 webug 靶场的 post 注入来更深刻的了解常用注入语句的原理。
categories:
    - websec
    - sql injection
date: 2019-08-04 13:49:57
tags:
---

具体注入流程，不再讲解，下面帖子中有，这里主要探究以及记录自己的一点疑惑，即：为什么查不到结果，进行时间盲注时，就得用 or ，用 and 不行？

[webug 4.0 第四关 POST 注入](https://www.twblogs.net/a/5cba215abd9eee0eff45eeac/zh-cn)

# 基础知识

## and or 短路

首先，我们要知道 mysql 的 and 与 or 都有短路效果

and 和 or 都是操作符，但 and 的有优先级在 or 之前，
也就是在有 and 和 or 同时存在的情况，优先计算 and 操作符，然后再计算 or 操作符。

> OR
> MySQL uses short-circuit evaluation for the OR operator. In other words,
> MySQL stops evaluating the remaining parts of the statement when it can determine the result.

> AND
> When evaluating an expression that has the AND operator,
> MySQL stops evaluating the remaining parts of the expression whenever it can determine the result. This function is called short-circuit evaluation.

当前面条件满足时
AND 需要执行后边
OR 不需要执行后边
当前面条件不满足时
AND 不需要执行后边
OR 需要执行后边

## 函数返回值

mysql 函数执行成功，返回值为 0

```
mysql> select sleep(2);
+----------+
| sleep(2) |
+----------+
|        0 |
+----------+
1 row in set (2.00 sec)
```

# sql 语句详解

下面我们讲解几个 sql 语句的原理：

```
mysql> select * from tuser;
+------+----------+----------+
| id   | username | passwd   |
+------+----------+----------+
|    1 | admin    | basswd   |
|    1 | adam     | vassword |
|    1 | bob      | gasswd   |
|    2 | colin    | passwd   |
|    2 | doc      | passwd   |
|    3 | doctor   | passwd   |
|    3 | elite    | passwd   |
|    1 | NULL     | passw    |
|    1 | admin    | basswd   |
|    1 | adam     | vassword |
|    1 | bob      | gasswd   |
|    2 | colin    | passwd   |
|    1 | 0        | pass     |
|    1 |          | pas      |
|    1 |  dewe    | ds       |
|    1 |  3fd     | asd      |
+------+----------+----------+
16 rows in set (0.00 sec)
```

首先，可以看到 tuser 表中有 16 条数据，其中两条编号为 3 的数据。

```
mysql> select * from tuser where id=3 or sleep(3);
+------+----------+--------+
| id   | username | passwd |
+------+----------+--------+
|    3 | doctor   | passwd |
|    3 | elite    | passwd |
+------+----------+--------+
2 rows in set (42.01 sec)
```

上面这条语句 mysql 会遍历每一条记录，在遍历到一条记录时，它会依次执行 where 后面的条件。总共有两步操作：

先判断 id=3 与否，因为是 or 连接两种操作，所以如果 id=3，那么后面的操作便被短路，不再执行。如果 id 不等于 3，执行后面操作，这里就是执行函数 sleep(3)

上面执行时间计算：一共 16 条数据，14 条 id 不为 3，会执行 sleep(3)。因此是 14\*3=42，然后再加上 0.01 秒的其他时间。

```sql
mysql> select * from tuser where id=1 and sleep(3);
Empty set (33.01 sec)

mysql> select 3*count(*)`sleep的时间` from tuser where id=1;
+----------------+
| sleep的时间    |
+----------------+
|             33 |
+----------------+
1 row in set (0.00 sec)
```

上面，我们使用 id =1 and sleep(3)，即：当 id = 1 时，由于是 and 不能确定结果，所以还会执行 sleep() 函数。当 id =1 为假时，可以确定整个 and 表达式的值，就不会执行后面的语句。

小结：

当记录中 id 没有匹配条件时，使用 and sleep(3) 没用，因为前面就能确定表达式结果为假了。

当记录中 id 全部匹配条件时，使用 or sleep(3) 没用，因为前面就能确定表达式结果为真了。

下面测试一些报错的函数：

```sql
mysql> select * from tuser where id=10 and extractvalue(1,concat(0x23,version()));
ERROR 1105 (HY000): XPATH syntax error: '#8.0.12'

mysql> select * from tuser where id=1 or sleep(2) or extractvalue(1,concat(0x23,version()));
ERROR 1105 (HY000): XPATH syntax error: '#8.0.12'

mysql> select * from tuser where id=10 and pow(999,3241324);
ERROR 1690 (22003): DOUBLE value is out of range in 'pow(999,3241324)'

mysql> select * from tuser where id=1 and pow(999,32414);
ERROR 1690 (22003): DOUBLE value is out of range in 'pow(999,32414)'
```

注：从上面表的数据知道，tuser 表中没有 id =10 的记录。

测试发现不管记录中有没有匹配的 id，不管是用 and 或 or，都可以报错。这个的具体原理咱也不清楚，测试着就是这样。

当然，webug 的 post 注入这关，不显示报错信息，咱不能用报错盲注。

总结：

1. 在 where id=1 后面加 and/or 函数，不会影响筛选结果（当然，报错的除外，报错就没结果了。）

2. 养成习惯，使用时间盲注的时候，and sleep(3) 和 or sleep(3) 都试试。
3. 报错注入时，使用 and/or，对我们注入来说，没区别。
