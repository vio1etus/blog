---
title: mysql注入小技巧
toc: true
description: 本文不成体系的介绍一些 sql 注入的小的好玩的点，希望对你有用。
categories:
    - websec
    - sql injection
date: 2019-08-04 09:00:16
tags:
---

# 判断当前表中是否有某个字段

假设后台语句为：select \* from tuser where id=1

假设我们要判断有没有 flag 字段，我们可以构造 payload：?id=1 or(flag)

通过报错与否来判断有无该字段。

原理）（我自己测试出来的..）：where 后面可以直接加字段名，在判断 where 条件时，mysql 会对每条数据的该字段进行 atof/atod 函数操作（但实际的数据不变，只是这样判断），即：将其转换为浮点型，然后通过判断该字段是否为 0，若非零，则满足条件。

给出测试证明：

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

mysql> select * from tuser where username;
+------+----------+--------+
| id   | username | passwd |
+------+----------+--------+
|    1 |  3fd     | asd    |
+------+----------+--------+
1 row in set, 13 warnings (0.00 sec)

mysql> select * from tuser where id
    -> ;
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

mysql> select * from tuser where passwd;
Empty set, 16 warnings (0.00 sec)

mysql> show warnings;
+---------+------+-----------------------------------------------+
| Level   | Code | Message                                       |
+---------+------+-----------------------------------------------+
| Warning | 1292 | Truncated incorrect INTEGER value: 'basswd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'vassword' |
| Warning | 1292 | Truncated incorrect INTEGER value: 'gasswd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passwd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passwd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passwd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passwd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passw'    |
| Warning | 1292 | Truncated incorrect INTEGER value: 'basswd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'vassword' |
| Warning | 1292 | Truncated incorrect INTEGER value: 'gasswd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'passwd'   |
| Warning | 1292 | Truncated incorrect INTEGER value: 'pass'     |
| Warning | 1292 | Truncated incorrect INTEGER value: 'pas'      |
| Warning | 1292 | Truncated incorrect INTEGER value: 'ds'       |
| Warning | 1292 | Truncated incorrect INTEGER value: 'asd'      |
+---------+------+-----------------------------------------------+
16 rows in set (0.00 sec)
mysql> select * from tuser where passwe
    -> ;
ERROR 1054 (42S22): Unknown column 'passwe' in 'where clause'
```

当然，如果自己构造的话，也可以在 information_schema 里面判断有没有某库，某表等。

# limit 下的字段数判断

使用 where 条件时，我们可以使用 order by 判断字段数，而 limit 后可以利用 `1,into @,@` （@为字段数）判断字段数

注：@为 mysql 的 User-Defined Variables，即：用户定义变量，也就是我们可以使用 @ 在 mysql 中定义变量，类似 php 中使用 \$ 定义变量。

比如：

```sql
mysql> set @var = 1;
Query OK, 0 rows affected (0.00 sec)

mysql> select @var;
+------+
| @var |
+------+
|    1 |
+------+
1 row in set (0.00 sec)
```

下面展示 limit 0,1 猜字段数，

```
mysql> select * from tuser where id=1 limit 0,1 into @a,@b,@c;
Query OK, 1 row affected (0.05 sec)

mysql> select * from tuser where id=1 limit 0,1 into @a,@b;
ERROR 1222 (21000): The used SELECT statements have a different number of columns
mysql> select @a;
+------+
| @a   |
+------+
|    1 |
+------+
1 row in set (0.00 sec)
```

原理：

使用 select into 语句将查询的一条（注意：@a，@b，@c 等只是一个变量，不能接受多条数据，所以 limit by x，1，第二个参数只能为 1），前后字段数不一致，放不进去当然就报列数不一样的错误。

未完待续....
