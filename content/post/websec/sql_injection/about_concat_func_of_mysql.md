---
title: mysql中concat相关函数详解
toc: true
tags:
    - mysql
description: mysql 中的 concat、concat_ws、group_concat 函数详解
categories:
    - websec
    - sql injection
date: 2019-07-25 18:32:59
---

## concat

1. 单纯连接字符串

    ```sql
    mysql> SELECT 'MySQL ' 'String ' 'Concatenation';
    +----------------------------+
    | MySQL                      |
    +----------------------------+
    | MySQL String Concatenation |
    +----------------------------+
    mysql> SELECT concat('MySQL ' 'String ' 'Concatenation');
    +--------------------------------------------+
    | concat('MySQL ' 'String ' 'Concatenation') |
    +--------------------------------------------+
    | MySQL String Concatenation                 |
    +--------------------------------------------+
    ```

2. select 查询时，连接字段的值。

    当然，如果你在字段中间再连接上空格或逗号，也就相当于加了分隔符。

    ```
    mysql> select concat(username, ',','passwd') from tuser;
    +--------------------------------+
    | concat(username, ',','passwd') |
    +--------------------------------+
    | admin,passwd                   |
    | adam,passwd                    |
    | bob,passwd                     |
    | colin,passwd                   |
    | doc,passwd                     |
    | doctor,passwd                  |
    | elite,passwd                   |
    | admin,passwd                   |
    | adam,passwd                    |
    | bob,passwd                     |
    | colin,passwd                   |
    +--------------------------------+
    ```

    concat 和 concat_ws 可以发挥差不多的功能，只是要连接的字段比较多时，使用 concat 你就要手写多个分隔符，使用 concat_ws 写一个就行了。

    注：你现在查询看着每一条记录都是有换行的，但是 sql 注入的时候，就没有了，那样上一行后面与这一行的前面就接上了，这样来看，group_concat 这个不仅可以分组连接字符串，还可以用来分隔每条记录数据的函数变很好了。三种函数具体使用自己体会吧。

## concat_ws

concat with separator 带有分隔符的字符串连接。

CONCAT*WS(\_separator*, _expression1_, _expression2_, \*...)

## group_concat 函数

这里将讲解如何使用几种选项来连接一个组中的字符串。（没事，相信你也不懂这句话，那就对了，要不看这篇文章干什么。）

### 简介

The MySQL `GROUP_CONCAT` function concatenates strings from a group into a single string with various options.

mysql 中的 group_concat 函数通过使用一些选项将一个组中的数据连接成一个默认以逗号分隔的字符串。

起初，感觉这个组是个什么东西，好抽象，难道 group_concat 只能和 group by 一起使用吗？直到写这篇文章查资料才清楚。

当你使用 group by 时， 这个组的概念，当然就是，按照你 group by 字段分的组了。当你未使用 group by 时， 也是可以使用 group_concat 的，而此时，这个组便是所有的记录，它就直接将所有记录中的这个字段，用指定的分割符，连接成一个字符串。

在 mysql 控制台输入命令：help group_concat;

> The full syntax is as follows:
>
> GROUP_CONCAT([DISTINCT] expr [,expr ...]ORDER BY {unsigned_integer | col_name | expr}
> [ASC | DESC][,col_name ...]]
> [SEPARATOR str_val])

注：[] 方括号是可选的，可写可不写，｛｝大括号是要写的，[] 中有｛｝的话，那就是如果你要使用 [] 中的那个选项，｛｝中的内容必须写。

可以看出，三个子句只有第一个子句是写的，也就是至少指定你要进行组字符串连接的字段名。

简单版：

```sql
GROUP_CONCAT(DISTINCT expression
    ORDER BY expression
    SEPARATOR sep);
```

注意：group_concat 中的三个子句/选项中间使用的是空格分隔符，不要加逗号什么的。

先看一下我们准备用来做例子的表的数据：

```sql
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
|    1 | admin    | basswd   |
|    1 | adam     | vassword |
|    1 | bob      | gasswd   |
|    2 | colin    | passwd   |
+------+----------+----------+
11 rows in set (0.00 sec)
```

单独使用 group_concat，不使用 group by 时，将每个记录中 username 字段的值都连接成一个字符串，并使用默认分隔符：逗号。

```php
mysql> select group_concat(username) from tuser;
+------------------------------------------------------------+
| group_concat(username)                                     |
+------------------------------------------------------------+
| admin,adam,bob,colin,doc,doctor,elite,admin,adam,bob,colin |
+------------------------------------------------------------+
1 row in set (0.00 sec)
```

### DISTINCT 子句

在 group_concat 将组中值连接成字符串之前，去除组中重复的值。

```sql
mysql> select group_concat(distinct username) from tuser;
+---------------------------------------+
| group_concat(distinct username)       |
+---------------------------------------+
| adam,admin,bob,colin,doc,doctor,elite |
+---------------------------------------+
1 row in set (0.00 sec)
```

### ORDER BY 子句

这个你应该比较清楚，就是按照指定的字段（必须指定字段），递增或递减排序，默认是递增的，也可以手动设置，跟 sql 语句中学的 order by 没什么区别。

The `SEPARATOR` specifies a literal value inserted between values in the group. If you do not specify a separator, the `GROUP_CONCAT` function uses a comma (,) as the default separator.

SEPARATOR 子句

指定字符串连接各值时的分隔符，如果不写此子句，默认分隔符是逗号（comma）

```sql
mysql> select group_concat(distinct username separator ';') from tuser;
+-----------------------------------------------+
| group_concat(distinct username separator ';') |
+-----------------------------------------------+
| adam;admin;bob;colin;doc;doctor;elite         |
+-----------------------------------------------+
1 row in set (0.00 sec)
```

GROUP_CONCAT 函数忽略 NULL 值，如果没有匹配的行或者所有的值都是 NULL，它将会返回 NULL。

GROUP_CONCAT 根据变量/值来返回二进制/非二进制字符串。（这句话的意思就是咱不用管它），默认情况下，返回字符串的最大长度为 1024. 如果要需要返回更长的话，可以通过在 会话级（session） 或 全局（global）设置系统变量：group_concat_max_len 来增大长度。

### 常见错误

group_concat 函数 返回的是一个字符串，而不是一个数组或链表，这就意味着你不能够在子查询时，通过 in 运算符使用 group_concat 的结果。

# group_concat 与 group by 搭配

```sql
mysql> select group_concat(distinct username order by id desc separator ';') from tuser group by id;
+----------------------------------------------------------------+
| group_concat(distinct username order by id desc separator ';') |
+----------------------------------------------------------------+
| bob;adam;admin                                                 |
| doc;colin                                                      |
| elite;doctor                                                   |
+----------------------------------------------------------------+
3 rows in set (0.00 sec)
```

当然，你也可以使用

```sql
select id group_concat(distinct username order by id desc separator ';') from tuser group by id;
```

这样的结果，更直观，我使用没有 id，就是想让你知道，order by 字段名的话，可以根据没有查询的字段名进行排序，但是 order by 数字（即：用数字代替字段）的话，数字对应前面 select 查询的列（从 1 到列的个数）。

# GROUP_CONCAT 与 CONCAT_WS 搭配

在进行 sql 查询时，二者搭配食用最佳。适用于你需要字符串连接多个数据时，使用 concat_ws 使用一种分隔符将一条记录中的不同字段对应数据项分隔开，然后 group_concat 使用另一种分隔符，将不同记录的数据分隔开。

```sql
mysql> select group_concat(concat_ws(',',username,passwd) order by id desc separator '; ') from tuser group by id;
+----------------------------------------------------------------------------------+
| group_concat(concat_ws(',',username,passwd) order by id desc separator '; ')     |
+----------------------------------------------------------------------------------+
| bob,gasswd; adam,vassword; admin,basswd; bob,gasswd; adam,vassword; admin,basswd |
| colin,passwd; doc,passwd; colin,passwd                                           |
| elite,passwd; doctor,passwd                                                      |
+----------------------------------------------------------------------------------+
3 rows in set (0.00 sec)
```

记一个自己犯的小错误：

mysql insert 的时候报错，ERROR 1054 (42S22): Unknown column 'admin' in 'field list'

一般是字段类型与你插入的不一致造成的，而这又常常是因为，字符串没有加单引号造成的。

此外，三者还有一个不太一样的地方：concat 和 group_concat 函数在连接字符串时，只要其中有一个是 null，那么就返回 null。而 concat_ws 函数则不会这样，他会忽略 null。

测试：

```
mysql> select concat('hello',null,'null');
+-----------------------------+
| concat('hello',null,'null') |
+-----------------------------+
| NULL                        |
+-----------------------------+
1 row in set (0.00 sec)

mysql> select concat_ws(';','hello',null,'world');
+-------------------------------------+
| concat_ws(';','hello',null,'world') |
+-------------------------------------+
| hello;world                         |
+-------------------------------------+
1 row in set (0.00 sec)

mysql> select group_concat('hello',null,'world');
+------------------------------------+
| group_concat('hello',null,'world') |
+------------------------------------+
| NULL                               |
+------------------------------------+
1 row in set (0.00 sec)
```

# 参考资料

> -   [MySQL GROUP_CONCAT Function](http://www.mysqltutorial.org/mysql-group_concat/)
> -   [MySQL CONCAT Function](http://www.mysqltutorial.org/sql-concat-in-mysql.aspx)
