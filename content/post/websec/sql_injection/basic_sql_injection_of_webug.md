---
title: webug之显错注入
toc: true
description: "通过 sql 显错注入,巩固加强 mysql 基础, 并熟悉常见的注入方式及流程."
summary: "通过 sql 显错注入,巩固加强 mysql 基础, 并熟悉常见的注入方式及流程."
categories:
    - websec
    - sql injection
date: 2019-07-24 20:54:01
tags:
---

# 基础知识

## mysql 注释

mysql 注释符有三种：

1. #...

2. "-- ..."

3. /\*...\*/

## mysql 常用函数

user() 当前登陆数据库的用户、version() mysql 的版本、database() 当前数据库、@@datadir 数据库的路径、@@version_compile_os 操作系统版本

@@version 和 version() 一样也是版本信息。

1. concat(str1,str2,...)——没有分隔符地连接字符串
2. concat_ws(separator,str1,str2,...)——含有分隔符地连接字符串
3. group_concat(str1,str2,...)——连接一个组的所有字符串，并以逗号分隔每一条数据

[MySQL 连接字符串函数 CONCAT，CONCAT_WS，GROUP_CONCAT 使用总结](https://my.oschina.net/MiniBu/blog/478342)

UNION 操作符用于合并两个或多个 SELECT 语句的结果集。

请注意，UNION 内部的每个 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。同时，每个 SELECT 语句中的列的顺序必须相同。

**order by 数字, 首先这个数字一定在 1-(select 查询的列的个数)之间, 数字是指按照你前面 select 的列的顺序, 从 1 开始排号, 你写几,对应几号,也就是哪个字段. 所以 order by 猜出的字段数,只是对应 sql 查询语句中 select 的字段数,并不一定是表的所有字段. 除非查询语句使用的 select \*, 而这种情况很常见, 所以网上很多互相抄袭的资料,就都说成了猜解表的字段. 我认为知道其中的区别还是很有必要的. **

以上知识肯定不够, 遇到一些细节性的, 不清楚的就去实验,实在不行谷歌.

# 显错注入

注意：万能密码中在用户名那里输入注释可以输入 --[空格] 或 #， 即：真实的 MySQL 注释即可，但是在 URL 地址栏要注意字符会经过 URL 编码，所以，你直接输入 --[空格] 或 # 是不管用的，你应该输入他们对应的 URL 编码。

| 原注释   | URL 编码      |
| -------- | ------------- |
| --[空格] | --%20 或者--+ |
| #        | %23           |

至于 --+ 为啥是--[空格] 的 URL 编码，咱也不知道呀，大家都这样用。

如果一开始记不住的话，可以使用 Hackbar 的 SQL 下拉菜单中的 URL encode，对你写的#或--[空格]进行编码。

## 检测注入点及注入类型

加一个单引号报错，根据报错语句，再加个注释，上面表格中三种 URL 编码都可以，然后页面回显正常，代表注入正确, 而且是字符注入,即:php 中数据库语句的 id 处是: id = '输入'

payload 1：

```php
?id=1' --%20
```

## 猜表的字段数

下面再在上面的基础上，使用 order by 猜字段, **这里猜的字段数是前面开发者对 id 这个 sql 查询语句中使用的字段数.** 因为一般该 sql 语句都是使用 select \* 查询, 所以一般情况下,你猜出的这个查询语句的字段数,也就是表的字段数.

二分法 order by 10 回显错误、 order by 5 回显错误、order by 3 回显错误、order by 2 回显正常，代表有两个字段。

## 确定显示位

下面找它的显示位（显示位指的是网页中能够显示数据的位置，这样才能利用 sql 语句将敏感信息显示给咱看呀，有的字段不显示在网页上，鬼知道是啥呀）。

下面让 id = -1 是为了让前面的查询结果为空，让它查不出数据来，不占用显示位，这样后面咱们使用 union select 查询出来的数据才能显示出来

payload 2：

```php
?id=-1' union select 1,2 --+
```

然后，看看页面上哪里有 1 或者 2，就知道哪个字段是显示位，显示位在那个位置。

这里的话，第二个字段是显示位，于是根据 MySQL 常用函数构造如下语句：

payload 3:

```php
?id=-1' UNION SELECT version(), concat_ws(', ', user(), version(), database(), @@datadir, @@version_compile_os) --+
```

事已至此, 然并软, 我的 flag 呢.emm..

## 爆表

爆表, Why? 为什么要先爆表, 不先爆库呢? 这里我们要知道我们使用的靶场,靶场作为一个库,你觉得它能把自己的 flag 放到别的库里吗? 很多时候, 先干什么, 后干什么,都是有一定的逻辑在的, 即使是经验, 也有为什么这么做的原因? 希望你在学习的时候,多问问自己为什么这样做?

这里就需要补充一点知识了, [mysql 中 information_schema.tables 字段说明](https://blog.csdn.net/qq_33326449/article/details/80405284), 首先你要对 mysql 数据库元数据 meta 的存放位置有一定的掌握.

information_schema 库存放着 mysql 数据的元数据. 其中 tables 表中存放着库名, 表名,表类型等信息. table_schema 字段 存放着所有的数据库名,table_name 存放着所有的表名.

首先从上面确定显示位中构造的 payload4 返回的数据得知, 当前使用的是 webug 数据库. 然后构造下面 payload 列出 webug 库中的表名

payload 4:

```php
 ?id=-1' UNION SELECT 1, concat(table_name,' , ') from information_schema.tables where table_schema = 'webug' --+
```

然后看返回的数据, 我的 flag 出现了, 然而 怎么让它显示出来了又是个问题.

首先, 不要忘记它是张表,然后, 接着**order by 猜字段数**

这里猜解字段数也是个问题.

[如何在不知道 MySQL 列名的情况下注入出数据？](https://nosec.org/home/detail/2245.html)

目前,我从这篇文章里得到启发,可以使用下面的 payload ,通过逐步递增括号内的 select 的数, 比如:select 1 union.. select 1,2 union..., 啥时候不报错了, 便是字段数. (一般字段数最多也就 10 来个吧, 要是有程序员建一张表用个 50/60 多个字段,我看他该被拿来祭天了! )

payload 5:

```php
?id=-1' UNION SELECT 1,2 from (select 1,2 union select * from webug.flag)tabl --+
```

才出来字段数,为 2 . 这就巧了, 系统 id 那个语句就是两个字段. 这不禁让人想入非非: 第一个字段不显示,只有第二个字段显示, 作为入门, 不会太坑,应该第二个字段, 就是 flag 的内容, 于是投机取巧的 payload 便产生了.(注: mysql 支持跨表联合查询)

payload 6:

```php
?id=-1' UNION SELECT * from webug.flag --+
```

然后 flag 就出来了,作为一道入门题, 现在它已经完成了自己的使命.

## 思考

作为要深入理解掌握 mysql 的人, 我们不禁思考, 万一字段数不是两个,该怎么办呢?

思路很容易就有了: 只有一个显示位, 那可以使用在 select 时, 使用 concat 函数将字段们都集中在第二个字段上显示.

根据以上知识, 构造 payload

payload 7:

```php
?id=-1' UNION SELECT 1, concat_ws('$',`1`,`2`)  from (select 1,2 union select * from webug.flag)tabl --+
```

显示位显示: 1\$21\$dfafdasfafdsadfa

刚开始我还纳闷怎么两个\$, 后来才想起来,这是两条记录. 下面的表格是以下语句的查询结果集. 其中第一行是表名,共两条记录.(因为第一条记录是我们 select 1,2 联合查询插入的.)

```sql
select 1,2 union select * from webug.flag;
```

| 1   | 2                |
| --- | ---------------- |
| 1   | 2                |
| 1   | dfafdasfafdsadfa |

其实我们控制显示位显示的并不完美,万一有多条记录,怎么办? 一堆都显示出来不好看.

我们可以使用 orde by 和 limit 来优化结果. 但是可能是语句太复杂(我测试比较简单的语句不报错), 我这边使用 order by 别名(给 concat_ws 的数据起一个别名) 时, 报错. 不过, 知道这个就好了, 万一以后用得到呢.

## 进一步爆库爆表

虽然 flag 已经拿到了,这里深入一下, 再做几个示例, 毕竟之前你都知道了, 这个是使用 root 登录的想看什么有什么, 这个要是在实战中,这个站已经可以被拿下了. 顺便深入学习一下 mysql 的 information_schema 库.

### 爆 webug 中的用户名以及密码

//猜列名 payload 8:

```php
?id=-1' UNION SELECT 1,2 from (select 1,2,3 union select * from webug.user)tabl --+
```

爆 webug 中的用户名以及密码 payload 9:

```php
?id=-1' UNION SELECT 1,concat_ws(' , ', `1`,`2`,`3`) from (select 1,2,3 union select * from webug.user)tabl --+
```

回显: 1 , 2 , 31 , admin , admin

下面为上面 payload 9 括号中 select 的结果集.

| 1   | 2     | 3     |
| --- | ----- | ----- |
| 1   | 2     | 3     |
| 1   | admin | admin |

虽然不知道字段名, 但是看着这表名 user, 看着这数据 admin, admin, 就算是菜鸡,咱也知道, 这是用户名和密码呀. (推断原表结构大致为: id username password)

### 爆 security 库的表名

security 为 sqli-labs 对应的数据库, 相信你们都有的

构造 payload 10:

```php
?id=-1' UNION SELECT 1, concat(table_name,' , ') from information_schema.tables where table_schema = 'security' --+
```

回显: emails , referers , uagents , users ,

作为菜鸟来说，这个注入就基本完成了，至于要是还有什么深入的理解，以后理解了再说吧 emm...

## 总结回顾

1. 要好好掌握数据库的元数据库, 对应 mysql 中 information_schema 库, 尤其是 tables 表. 以后学习 sqlserver 注入,也要这样学.
2. 如何爆字段名好像还没有学会, 有时间得学一下.
3. mysql 数据库命名规范有时间要看一看.
4. concat 和 concat_ws 可以用来分割不同字段/数据, 至于分隔符选什么,不要选 # , 分号等敏感字符(万一给转义了), 其他的自己看着来吧.
5. 不同版本数据库有些功能可能不同, 以后渗透的时候, 首先注入出数据库版本, 然后自己安装一个对应版本数据库, 这样在构造 paylaod 的时候就更有把握了, 出错也知道是为什么出错. (ps. 避免自己在自己电脑的版本上测试 payload 用到的的某些细节特性正常, 但是测试系统的版本不支持该特性).
