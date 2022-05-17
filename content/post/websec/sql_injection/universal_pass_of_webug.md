---
title: webug之万能密码
toc: true
description: "开启靶场练习之旅,本文介绍通过小白看起来最牛的万能密码来迈进 sql 注入的大门."
categories:
    - websec
    - sql injection
date: 2019-07-24 20:54:13
tags:
---

暑假闲来无事，想找个靶场练练手，找到了 Webug 4.0 靶场。

下面开始菜鸡之旅, 首先,从入门, 注入分类下开始练习.

# Webug 靶场安装

没啥说的，老铁。去[Webug Github](https://github.com/wangai3176/webug4.0) 下载完整 2003 虚拟机，自带环境，直接启动 phpstudy，便可以愉快的玩耍了。

webug 中有个乌云知识库,虚拟机中好像没有自带,需要我们去下载.

[**wooyun-drop-fork**](https://github.com/S0urceC0der/wooyun-drop-fork)

下一个压缩包, 解压后把里面的 drop 文件夹放到 C:\phpStudy\WWW\control\more 下面就好了.

**注意：**请务必在 phpstudy 切换版本那里将环境切换至 PHP-5.3.29-nts + Apache。(否则等你对着注入入门题，死活注入不成功，查一下数据库日志，才发现默认版本对你的单引号做了转义时，就知道什么是绝望了。)

然后，主机访问虚拟机 IP 即可。用户名与密码都是 admin，成功进入。

在实战之前，先在 Chrome 上整个 Hackbar，现在收费了，大家要支持正版呀。（我看见美刀就感觉贵了。于是，求助广大网友，Google 关键字：hackbar 破解教程）

sql 注入使用 hackbar 会很方便

1. load URL 将当前 URL 加载到 hackbar，可以使用 Encoding 中的 URL encode 与 URL decode 进行编码或解码
2. split URL 将目录与查询语句分开，便于更改，而且 hackbar 中的 URL 不会被转义。
3. 当遇到登陆框注入等 post 请求时，可以使用 Post data 自己写 post 数据，避免地址栏转义，一次次改麻烦还眼花。

下面来一个万能密码。

首先，我们要知道登录这种东西，必然是使用 post 提交的，所以右键查看网页源码，找到用户名与密码的两个字段，username 、password。

猜测大致 sql 语句：

```php
select * from user where name=$name and passwd=$passwd
```

通过判断查询结果是否存在（大于 1 条记录）来判断是否正确。

当然，一般 $passwd 是 md5 加密后的数据。比如：$passwd = md5(\$\_POST['passwd']);

下面，F12 上 hackbar 勾选 Post data，然后输入 username=你要输入的用户名&password=你要输入的密码

这里举个例子：username=admin'#&password=dewc 然后 Exxcute flag 出现。

两种注释方式：#与--[空格] (注: 这里是两个横线)

这个很简单啦。猜测存在用户名 admin，然后用单引号闭合，在注释一下，后面的密码字段。即: admin' #

密码什么也不输入，然后登录，注入失败。。

然后发现，要随便输点密码。(我是不会告诉你，我看了源码的)。成功。

总结：

1. hackbar 不愧是个人人称赞的利器。
2. 注意中英文字符
3. 一般你输入的数据在 sql 语句中间，往往后面还有语句，养成加#或-- 注释的习惯。
4. 绕过登录时，密码总还是要输入点东西，（我看源码，判断用户名非空且密码非空后，才会进行后续操作）

## 参考资料

> -   webug 靶场源码
