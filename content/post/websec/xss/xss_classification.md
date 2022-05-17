---
title: XSS 基础及分类
comments: true
toc: true
tags:
    - XSS
description: 简介介绍 XSS 的是哪种类型，DOM 型暂时还未弄明白，以后再说
categories:
    - websec
    - xss
date: 2019-08-15 17:44:57
---

# 介绍

> 跨站脚本攻击( Cross Site Scripting )，为了和层叠样式表 csss 区分，缩写为 XSS。
> 恶意攻击者通过 “HTML 注入” 篡改网页，向 Web 页面里插入恶意脚本(例如恶意 javaScript 代码 )，当用户浏览该页时，嵌入其中 Web 里面的脚本( 例如 javaScript 代码 ) 会被执行，从而达到恶意攻击用户的目的。

XSS 是客户端代码注入，通常注入代码是 JavaScript。区别于命令注入，SQL 注入等服务端代码注入，XSS 的形成和 SQL 注入一样，通常是因为对用户可控的地方（数据）与命令区分不严谨（过滤做的不彻底）造成的。

# XSS 分类

| 类型       | 触发过程                                                 | 存储区     | 谁来输出          | 输出位置            |
| ---------- | -------------------------------------------------------- | ---------- | ----------------- | ------------------- |
| 存储型 XSS | 1.黑客构造 XSS 脚本<br>2.正常用户访问携带 XSS 脚本的页面 | 后端数据库 | HTML              | HTTP 响应           |
| 反射型 XSS | 正常用户访问携带 XSS 脚本的 URL                          | URL        | 后端 Web 应用程序 | HTTP 响应           |
| DOM 型 XSS | 正常用户访问携带 XSS 脚本的 URL                          | URL        | 前端 JavaScript   | 动态构造的 DOM 结点 |

输出在 HTTP 响应中和输出在动态构造的 DOM 结点中有什么区别呢？

？？？？暂未搞清楚？

# 危害

盗取用户信息（比如获取用户的 Cookie）、钓鱼、制造蠕虫等。

# 分类详解

## 存储型

### 原理

#### 形成

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/form_stored_xss.png)

1. 黑客构造携带 XSS 脚本的内容
2. 浏览器将携带 XSS 脚本的页面内容提交给 web 服务器
3. Web 服务器中的 Web 服务器软件(例如：免费的 HTTP 服务器软件：Apache 和 Nginx ) 处理浏览器与 Web 服务器的连接与请求过程
4. Web 服务器软件根据 HTTP 请求报文，解析文件位置、处理请求参数
5. 脚本语言解释器（如：php 语言解释器）从 Web 服务器软件获取请求参数，并解释对应文件，（存储型 XSS 的后端脚本文件一定是有数据库有交互的）
6. 解释执行的 php 脚本与数据库交互，将携带 XSS 脚本的内容存储到数据库中。
7. Web 服务器软件处理浏览器与 Web 服务器的应答过程以及关闭连接

#### 触发

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/trigger_stored_xss_.png)

1. 用户或管理员打开浏览器访问存在 XSS 脚本的页面
2. 浏览器将页面内容请求提交给 web 服务器
3. Web 服务器中的 Web 服务器软件(例如：免费的 HTTP 服务器软件：Apache 和 Nginx ) 处理浏览器与 Web 服务器的连接与请求过程
4. Web 服务器软件根据 HTTP 请求报文，解析文件位置、处理请求参数
5. 脚本语言解释器（如：php 语言解释器）从 Web 服务器软件获取请求参数，并解释对应文件，（存储型 XSS 的后端脚本文件一定是有数据库有交互的）
6. 解释执行的 php 脚本与数据库交互，将存储在数据库中恶意 xss 脚本（一般为网站留言等）查询出来，并拼接到页面的某个地方。
7. Web 服务器软件处理浏览器与 Web 服务器的应答过程，将内容返回给用户浏览器，浏览器渲染 HTML 并显示，因而触发 XSS

存储型 XSS 是 从数据库中提取恶意的 脚本代码（php 脚本与数据库有交互）

那这是不是先从参数中获取存入数据库中，然后再从数据库中获取呢？

类似于使用注入点进行二次注入？

### 示例

## 反射性

反射型 XSS 又称为非持久性 XSS，这种攻击往往具有一次性，点击访问一次含恶意脚本的 url 进行触发。

与存储型 XSS 不同的是，反射性 XSS 可以在链接 （url ）中查看到很明显的 XSS 脚本特征，所以我们一般诱导用户点击时通常采用 url 编码、生产短网址的方式增加隐蔽性，以期减弱用户的警惕性。

一般判断是否存在反射型 XSS 的方式：看你的输入是否会在页面上某个地方显示，当然，一般你的输入要有唯一性，这样才好确定的显示的是不是你输入的呀

### 原理

![1565781435376](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/reflected%20xss_prici.png)

#### 形成

下面的流程就不写那么详细了....

1. 攻击者通过邮件等形式将包含 XSS 代码的链接发送给正常用户，用户点击访问该 URL
2. 浏览器向 web 服务器发送请求
3. Web 服务器软件解析处理应用参数
4. php 语言解释器定位到对应 php 文件，解释执行对应 php 脚本，获取请求参数（即：恶意 XSS 脚本）拼接到页面内容中，生成 html 文件
5. Web 服务器软件响应对应页面内容，然后把带有 XSS 的代码（一般为 javaScript 脚本）的 HTML 发送给用户
6. 用户浏览器渲染 HTML ，触发 XSS 漏洞。

#### 触发

反射型 XSS 是从 URL 中提取的参数中含有恶意脚本代码。

### 示例

黑客在 url 中插入恶意脚本，然后发给用户点击

```
http://localhost/dvwa-master/vulnerabilities/xss_r/?name=<script>alert("xss")</script>
```

用户点击访问，后端 php 开始处理提交的参数（当然，参数是之前黑客构造的恶意脚本），

```php
<?php
header ("X-XSS-Protection: 0");

// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Feedback for end user
	$html .= '<pre>Hello ' . $_GET[ 'name' ] . '</pre>';
}
?>
```

我们可以看到后端 php 代码对输入参数未经过滤就直接拼接，导致脚本拼接之后解析出来的是以下代码，这样浏览器渲染的时候，就会产生弹出。

```html
<pre>Hello <script>alert("xss")</script></pre>
```

测试流程：

1. 输入页面上比较唯一的正常字符串（无引号，无大于小于号），看有没有在页面上回显，右键查看源码或开发者工具中定位到显示位，看是什么标签。
2. 尝试输入一些带有大于小于号对或引号的不正常字符串，看页面如何显示，按 F12 打开开发者工具，定位到显示位置看如何解析我们的输入
3.

## DOM

DOM 型的 XSS 由于其特殊性，常常被分为第三种，这是一种基于 DOM 树的 XSS。例如服务器端经常使用 document.boby.innerHtml 等函数动态生成 html 页面，如果这些函数在引用某些变量时没有进行过滤或检查，就会产生 DOM 型的 XSS。DOM 型 XSS 可能是存储型，也有可能是反射型。

### 原理

1. 用户在浏览器中访问携带有 XSS 脚本的链接
2. 浏览器通过 JavaScript 从 URL 中提取 XSS 脚本中的内容，并写入到 DOM 中，触发 XSS

DOM 型与反射型的区别：DOM 型通过前端 JavaScript 将 XSS 脚本写入到 DOM 中触发 XSS，而反射型是通过后端 Web 服务器中的 PHP 解释执行将 XSS 脚本写入到页面中。浏览器渲染响应页面触发 XSS。

DOM 型 XSS 的一种情况：

XSS 不是在 URL 的参数中而是在 URL 的 hash 中，URL 的 hash 是不会发送到 后端 Web 服务器的，说明向页面输出 XSS 脚本的不是后端，是前端页面。我们可以在脚本中搜索 hash 来定位。

如果改变 # 后面 hash 的内容，点击 Enter，页面是不会重载的，你需要手动去刷新。

dom 型 xss 是由 javascript 来触发的，所以不能想其他两种那样通过查看页面源代码的方式在 html 中找到 xss 脚本代码。我们需要去开发者工具中的还有 js 脚本的 html 中搜索。

补充：

JavaScript 中的三个弹窗函数：alert() confirm() prompt()

根据服务器的过滤情况，如果第一个被过滤了，我们可以尝试其他函数。

### 文章推荐：

[前端安全系列（一）：如何防止 XSS 攻击？](https://tech.meituan.com/2018/09/27/fe-security.html)

[XSS 跨站脚本攻击(一)----XSS 攻击的三种类型](https://blog.csdn.net/u011781521/article/details/53894399)
