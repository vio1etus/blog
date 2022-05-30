---
title: DVWA 中的 XSS
comments: true
toc: true
tags:
    - XSS
description: 通过 DVWA 中的 几个安全等级的 XSS 来学习三种 XSS 及其探测、绕过方式
summary: 通过 DVWA 中的 几个安全等级的 XSS 来学习三种 XSS 及其探测、绕过方式
categories:
    - websec
    - xss
date: 2019-08-15 17:42:56
---

首先我们大致了解一下 dvwa 的代码结构（以 xss 的为例，其他类似）

dvwa 每个页面有一个 index.php ，在 index.php 中有这样一段代码

```php
$vulnerabilityFile = '';
switch( $_COOKIE[ 'security' ] ) {
	case 'low':
		$vulnerabilityFile = 'low.php';
		break;
	case 'medium':
		$vulnerabilityFile = 'medium.php';
		break;
	case 'high':
		$vulnerabilityFile = 'high.php';
		break;
	default:
		$vulnerabilityFile = 'impossible.php';
		break;
}

require_once DVWA_WEB_PAGE_TO_ROOT . "vulnerabilities/xss_r/source/{$vulnerabilityFile}";
```

它通过判断 cookie 中的 security 来决定将参数提交到哪一个 php 脚本上，所以我们看源码需要看 low、medium、high、impossible 这些后端脚本如何处理参数。

# Reflected XSS

## low

黑盒测试

1. 探测 xss

    构造一个独一无二且不会被识别为恶意代码的字符串用来提交到页面，这里构造 kidding，并提交。

    看页面回显以及使用浏览器审查工具进行代码审查，寻找构造的字符串是否在页面中显示。

    ![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/dvwa_reflected_xss_low.png)

    我们可以看到页面上回显：Hello kidding，而且在 Elements 中我们发现 Hello kidding 这个文本，并未使用字符串包裹，也就是说，我们输入<script> 标签，它就会当成脚本执行。

2. 测试 xss

    那么我们输入：\<script>alert(/xss/)\</script>或\</pre>\<script>alert(1)\</script>

    如果不弹窗而且页面将我们的输入完整的回显出来或者都转成实体编码呼回显出来，那八成是凉了，htmlspecialchars 警告。（你去 开发者工具定位，编辑 html，就可以看到它将<>等特殊符号实体编码了）

    弹窗成功，黑盒测试完成(第二种 payload 只是告诉你可以闭合前面标签，再写 script 标签)

代码讲解

上代码：low.php

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

array_key_exists() 函数检查某个数组中是否存在指定的键名，如果键名存在则返回 true，如果键名不存在则返回 false。

这里的 if 语句

一方面检查 \$GET 数组中有无 name 这个键，也就是我们的输入，即：检查有没有提交这个 name 参数

提交 name 参数状态：

http://localhost/dvwa-master/vulnerabilities/xss_r/?name=

未提交 name 参数状态：

http://localhost/dvwa-master/vulnerabilities/xss_r/

另一方面，检查我们如果提交了 name 参数，name 参数是否为空

只有满足提交了 name 参数并且该参数不为空的条件下，才会执行后面的语句。

代码直接采用`get`方式传入了`name`参数，后面直接用一个 html 变量来拼接我们的参数，并没有任何的过滤与检查，存在明显的`XSS`漏洞，所以我们直接使用 script 标签即可。

## meduim

黑盒测试

1. 探测 XSS

    输入独一无二字符串，搜索并在开发者工具中对应查看，发现前端没有什么区别

2. 测试 xss

    \<script>alert(1)\</script>

    ![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/dvwa_reflected_xss_medium.png)

    结果发现事情没那么简单，很明显后端过滤了 script 标签，下面我们来绕过它的过滤。

    绕过方式（与 SQL 注入的某些绕过方式一样）：

    1. 大小写绕过（如果他只过滤小写的 script 标签，可以绕过）

        \<sCript>alert(1)\</scRipt>

        绕过成功

    2. 嵌套绕过（如果它只过滤一次 script 标签，便可以绕过）

        可以尝试两种：

        <scr\<script>ipt>alert(/xss/)\</script>

        <scr\<script>ipt>alert(/xss/)</scr\</script>ipt>

        我们发现第一种绕过了，那么为什么第二种不行呢？也就是为什么闭标签不用嵌套呢？后面我们白盒测试将代码的时候再讲。

代码讲解

上代码，medium.php

```php
<?php
header ("X-XSS-Protection: 0");
// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Get input
	$name = str_replace( '<script>', '', $_GET[ 'name' ] );
	// Feedback for end user
	$html .= "<pre>Hello ${name}</pre>";
}
?>
```

medium 基于黑名单的思想进行过滤。if 判断和 low 一样，这里多了一个 str_replace 函数，将 script 标签的开标签 \<script> 给替换为了空格，而没有对其闭标签 \</script> 进行处理，这也就是为什么我们之前使用开闭标签都嵌套的方式失败的原因了。

注：

php 变量名加 “ {} ” 主要是为了区分变量与文本。

一方面是为了防止变量名和后面的字符串连在一起，另一方面是怕变量名中有空格啥的（当然，咱这个 name 没有空格啥的），没有什么其它的作用。

## high

黑盒测试

重复前面的步骤，我们发现无法绕过 script 的过滤，现在我们学习一些标签来触发 XSS。

```html
<img src=@ onerror=alert(/xss/)>
<iframe onload="alert(1)"> <body onload=alert('XSS')></iframe>
```

上面这些都可以，当然，还有一些更隐蔽的：

```html
<img src="1" onerror=eval("\x61\x6c\x65\x72\x74\x28\x27\x78\x73\x73\x27\x29")>
<img src="1" onerror=eval("\u0061\u006c\u0065\u0072\u0074\u0028\u0031\u0029")>
```

上面这两个分别是使用 alert(1) 的 16 进制编码和 unicode 编码，这样可以绕过对 alert 等函数的过滤。

注：javascript 中的 eval 和别的语言的 eval 函数功能一样，都是接收字符串，将字符串当做命令执行。

```html
<img
    src="1"
    onerror="eval(String.fromCharCode(97, 108, 101, 114, 116, 40, 49, 41))"
/>
```

String.fromCharCode 是返回 UTF-16 的 unicode 编码对应的字符/字符串。（直接用 hackbar 的 String.fromCharCode 加解密即可）

代码讲解

```php
<?php
header ("X-XSS-Protection: 0");
// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Get input
	$name = preg_replace( '/<(.*)s(.*)c(.*)r(.*)i(.*)p(.*)t/i', '', $_GET[ 'name' ] );

	// Feedback for end user
	$html .= "<pre>Hello ${name}</pre>";
}
?>
```

preg_replace() 函数用于正则表达式的搜索和替换，这使得双写绕过、大小写混淆绕过（正则表达式中 i 表示不区分大小写）不再有效。

(._)正则表达式
(._)涉及到贪婪模式。当正则表达式中包含能接受重复的限定符时，通常的行为是（在使整个表达式能得到匹配的前提下）匹配尽可能多的字符。以这个表达式为例：a.\*b，它将会匹配最长的以 a 开始，以 b 结束的字符串。如果用它来搜索 aabab 的话，它会匹配整个字符串 aabab。这被称为贪婪匹配。所以第一个程序第一个分组匹配的的结果是 Found value:This order was placed for QT300，尽可能匹配多的字符（因为第二组还要匹配数字，所以匹配到 300）

所以我们一开始输入：\<script>alert(1)</script>， 从最早的< 到最晚的 t ，中间全部被过滤掉了，只剩下一个 >。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/dvwa_reflected_xss_high.png)

## impossible

黑盒测试

直接测试：\<script>alert(/xss/)\</script>

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/dvwa_reflected_xss_impossible.png)

回显：Hello \<script>alert(/xss/)</script>，它将你输入的特殊字符都完好的回显出来，到了这种时候，你心里要有一句话：是时候放弃了...

我们在开发者工具中定位，并 edit as html 发现，果不其然，大于小于号都给实体化了，嗯，不愧是 impossible。

代码讲解

```php
<?php
// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Check Anti-CSRF token
	checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

	// Get input
	$name = htmlspecialchars( $_GET[ 'name' ] );

	// Feedback for end user
	$html .= "<pre>Hello ${name}</pre>";
}
// Generate Anti-CSRF token
generateSessionToken();
?>
```

htmlspecialchars() 函数把预定义的字符(" & <> ' )转换为 HTML 实体。这样就基本杜绝了 XSS。

此外，在此函数中，默认不编码单引号，要加上 ENT_QUOTES 参数才会编码单引号。在 dvwa 中不编码单引号没有风险，但是在其他场景下，单引号就可能会被利用

# Stored XSS

温馨提示：存储型 xss 会一直有，对后续使用 dvwa 不友好，还要自己去数据库删除，可以选择 Setup/Reset DB 来重置 dvwa

黑盒测试

首先，我们测试 Message 栏，我们在 Name 栏输入 Hello， 在 Message 栏输入 \<script>alert(/xss/)\</script>，成功弹窗。

然后，我们测试 Name 栏，我们尝试在 Name 栏输入 \<script>alert(/xss/)\</script>，但是发现它限制了长度（一般，你在输入那里输着输着，输不动了，就是前端限制），打开开发者工具，我们看到：

```html
<input name="txtName" type="text" size="30" maxlength="10" />
```

字符串长度最长为 10，此长度限制为**前端限制**，我们有两种方式突破

1. 直接 F12 在 Elements 中的对应长度处，改长度
2. burp suite 抓包，直接改 name 的值

然后，测试弹窗成功。

代码讲解

```php
<?php
if( isset( $_POST[ 'btnSign' ] ) ) {
	// Get input
	$message = trim( $_POST[ 'mtxMessage' ] );
	$name    = trim( $_POST[ 'txtName' ] );

	// Sanitize message input
	$message = stripslashes( $message );
	$message = ((isset($GLOBALS["___mysqli_ston"]) && is_object($GLOBALS["___mysqli_ston"])) ? mysqli_real_escape_string($GLOBALS["___mysqli_ston"],  $message ) : ((trigger_error("[MySQLConverterToo] Fix the mysql_escape_string() call! This code does not work.", E_USER_ERROR)) ? "" : ""));

	// Sanitize name input
	//代码基本同上（我这里不抄过来了）

	// Update database
	$query  = "INSERT INTO guestbook ( comment, name ) VALUES ( '$message', '$name' );";
	$result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );
	//mysql_close();
}

?>
```

trim() 函数

移除字符串两侧的空白字符或其他预定义字符。

语法：trim(string,charlist) 若无 charlist， 则移除字符串两侧的空白字符，否则，移除 charlist 中的字符。

stripslashes() 函数

删除由 [addslashes()](https://www.w3school.com.cn/php/func_string_addslashes.asp) 函数添加的反斜杠。

**提示：**该函数可用于清理从数据库中或者从 HTML 表单中取回的数据。

mysqli_real_escape_string 函数

mysqli_real_escape_string() 函数转义在 SQL 语句中使用的字符串中的特殊字符，用来防止 SQL 注入，仅在写数据库的时候才需要调用这个函数。

可以看到，对输入并没有做 XSS 方面的过滤与检查（做了对 SQL 执行方面的检查，所以不太好进行 SQL 注入），且存储在数据库中，因此这里存在明显的存储型 XSS 漏洞。

## medium

黑盒测试

首先测试，Message，测试以下 payload:

```php
<script>alert(xss)</script>
<img src=@ onerror=alert(/xss/)>
<iframe onload=alert(1)>
<body onload=alert('XSS')>
```

均未成功，放弃

测试 Name，测试

```php
<script>alert(xss)</script>

<scrIpt>alert(xss)</sCript>
```

大写那个测试弹窗，看来对 Message 做了较强的过滤，对 Name 只做了过滤小写 script 标签的黑名单。

当然，双写也能绕过，这里就不再做演示了。

代码讲解

大致代码与上面 low 相同，不同的相信我们呀猜出来了。

\$message 多了一步 htmlspecialchars 的处理

```php
$message = htmlspecialchars( $message );
```

\$name 多了过滤 \<script> 的操作

```php
	$name = str_replace( '<script>', '', $name );
```

## high

黑盒测试

从 medium 我们知道 Message 是不可能了，接着尝试 Name， 大写与嵌套失败，使用别的标签，比如：img，iframe，body 标签绕过成功。

代码讲解

```php
$name = preg_replace( '/<(.*)s(.*)c(.*)r(.*)i(.*)p(.*)t/i', '', $name );
```

可以看到，这里用正则完全地过滤了 script 标签，所以我们使用 script 标签不再奏效。

## impossible

黑盒测试

使用以下 payload 进行测试，

```php
<img src=x onerror=alert(1)>
```

回显：

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/stored_xss_impossible.png)

我们看到 <> 均被实体化编码了，凉凉。

代码讲解

不出所料，Name 和 Message 参数都进行了 htmlspecialchars 处理。

一个坏习惯：

测试留言板要一个个测试，不要两个一起都输入 xss payload 测试，很能会相互影响，这里就因为二者挨着，相互影响，导致测试失败。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/Web%E5%AE%89%E5%85%A8/xss/dvwa/stored_xss_notice.png)

# DOM XSS

未完待续...

总结回顾：

1. 测试漏洞时，要一个一个点的测试，不要相邻的点就一起测试，不然，如果他们在代码中是一起的，容易相互影响。

2. 修复方式：
   输入过滤：提倡白名单，在服务端对用户的输入做好限制

    输出过滤：如果是输出到 html 中，那进行 html 编码；如果是输出到 js 中，js 转义

3. 存储型 XSS 一旦存储上每次访问对应地方都会触发，很烦。尤其在测试别人的网站的时候，不要使用弹窗的 XSS payload，最好使用 XSS 平台检测。
