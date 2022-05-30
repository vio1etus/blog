---
title: PHP基本语法规范及常量与变量
toc: true
description: 本文主要介绍 PHP 的基本语法规范以及 PHP 中的常量与变量
summary: 本文主要介绍 PHP 的基本语法规范以及 PHP 中的常量与变量
tags:
    - php
categories:
    - programming
date: 2019-07-23 20:00:29
tags:
---

# PHP 基本语法规则

## PHP 标记

PHP 语言，是一种可以嵌入到 “html” 代码中的后台处理语言（程序）

有以下几种标记形式，只推荐第一种。

1. \<?php php 代码写在这里..... ?>

2. \<script language="php" > php 代码写在这里..... \</script>

3. \<? php 代码写在这里..... ?>

    此种方法需要到 php.ini 中进行配置：short_open_tag = On //默认为 Off，表示不能用该形式。

**注意：**

纯 PHP 代码：可以省略标记结尾符。

后面，我们会写很多“纯 php 代码文件”（里面没有任何 html 代码）。

## PHP 语句结束符

使用英文分号（;）表示一条语句的结束。

## PHP 输出

通过 PHP，有两种在浏览器输出文本的基础指令：**echo** 和 **print**。

## PHP 注释

和 C++ 一样，单行注释：//注释内容 多行注释：/_ 注释内容_/

## PHP 中的引号

1. 字符串

    在 PHP 中，字符串的定义可以使用单引号，也可以使用双引号。但是必须使用同一种单或双引号来定义字符串，如：‘Hello"和“Hello'为非法的字符串定义。

2. 单引号

    双引号里面的字段会经过编译器解释然后再当作 HTML 代码输出，但是单引号里面的不需要解释，直接输出。

3. html 使用啥引号

    要知道 php 最终要输出 html，所以 php 中使用 html 时，使用单引号即可。

    html 包含很多的双引号使用，可以用单引号包含起来，是没有问题的 。双引号虽好，能包含变量和转义字符，但是效率比单引号低，能用单引号的尽量用单引号，不可忽略的是，要注意区分英文和中文引号

    **注：单引号里面的双引号中的变量不会解析！**

# 变量

定义形式： $变量名 = 具体的数据;

注意：**变量名区分大小写**

## 变量的命名规则

与 C++ 相同，字母、数字、下划线，不以数字开头。

骆驼命名法（小驼峰命名法）：第一个单词首字母小写，其余单词首字母大写。

childAge, yungerAge, parentHouse, myParentHouse, myParentHousePrice

其中 JavaScript 的函数命名规则便是小驼峰命名法。

帕斯卡命名法（大驼峰命名法）：所有单词都首字母大写。

ChildAge, YungerAge, ParentHouse, MyParentHouse, MyParentHousePrice

## 变量的操作

赋值 $v1 = 'Hello World'; 取值: echo $v1;

### 判断变量：isset()

判断一个“变量名”是否里面存储了数据！结果：true（真，表示有），或者 false（假，表示没有）。

使语法：isset( $变量名 );

还有一个特殊的赋值，赋值后，变量中也没有数据，如下：

$v5 = null; //null 是一个特殊的“数据”（值），该数据的含义是：没有数据。

即此时判断 isset($v5) 的结果是“false”。

因为上面直接 echo isset($v5) ；结果并不明显，可以使用

```PHP
echo var_dump(isset($v5));
```

**var_dump()** 函数用于输出变量的相关信息。

**var_dump()** 函数显示关于一个或多个表达式的结构信息，包括表达式的类型与值。数组将递归展开值，通过缩进显示其结构。

删除/销毁变量 unset()

当一个变量中存储了数据，我们也可以去销毁（删除）它，语法如下：

unset( $变量名 ）。

删除变量的本质是：断开变量名跟其关联过的那个数据之间的“联系”，断开之后，该变量就不再指向某个数据了，其 isset() 判断的结果为 false。

## 变量传值

### 值传递

```php
$v1 = $v2;
```

### 引用传递

```php
$v1 = &$v2;
```

要注意的有一点: unset() 是断开名称与内存数据之间的联系. 所以对两个引用同一块内存数据的变量来说, 对一个数据进行 unset() 不会影响另一个数据.

原理你懂的。

## 预定义变量

在 PHP 语言内部，有一些（也就 10 来个）变量，是现成的，直接可以使用，这就是所谓预定义变量。

我们要做的是事情就是：理解该变量是什么意思，以及怎么用！

### $\_GET 变量

代表浏览器表单通过“get”方式提交的所有数据（集），可以称为“get 数据”。

也可以理解为：

$\_GET 变量里面会“自动存储”（保存/装载）提交到某个文件中的 GET 数据。

而 GET 数据，是在一个页面以“get”方式请求的时候提交的数据。

使用 get 方法提交表单的 URL 一般有 fileName.php?userName=张三&age=15 以下特征。

![php_get](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/php_get.png)

### $\_POST 变量

代表浏览器表单通过“post”方式提交的所有数据（集），可以称为“POST 数据”。

也可以理解为：

$\_POST 变量里面会“自动存储”（保存/装载）提交到某个文件中的 POST 数据。

而 POST 数据，是在一个表单中以“post”方式提交的数据。

![php_post](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/php_post.png)

加法改进(初始显示与提交页面为一个页面, 即: 向自己提交)

知识点: action=''为空时,意思是提交给自己

```php
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
</head>
<!-- 作为 post 计算加法的改进,初始与提交再也个页面上完成-->
<?php
	$n1 = "";	//先把三个变量定义上，免得第一次载入页面（$POST 预定义变量中没有数据）时报错
	$n2 = "";
	$sum = "";
	if(isset($_POST['num1']))
	{
		//获取输入
		$n1 = $_POST['num1'];
		$n2 = $_POST['num2'];
		$sum = $n1 + $n2;
	}
?>
<body>
	<form action='' method='post'>
		<input type='text' name='num1' value='<?php echo $n1;?>'>		<!--数字1 -->
		+
		<input type='text' name='num2' value='<?php echo $n2;?>'>		<!-- 数字2 !-->
		<input type='submit' value='='>
		<input type='text' value='<?php echo $sum;?>'>
	</form>
</body>
</html>
```

### $\_REQUEST 变量

代表浏览器通过“get”方式 或 “post”方式提交的数据的合集。

即：它既能接收到 get 过来的数据，也能接收到 post 过来的数据！

通常，一个表单，只提交一种形式的数据，要么 get 数据，要么 post 数据！

注: 如果明确是 post 或 get 就用 $\_POST 或 $\_GET, 不确定时,再用$\_REQUEST

这里就不演示了.

注意: 有一个情况，提交 post 数据的同时，也可以提交 get 数据：

```php
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
</head>
<?php
$n1 = "";
$n2 = "";
$sum = "";
if(isset($_REQUEST['num1']))
{
	$n1 = $_REQUEST['num1'];
	$n2 = $_REQUEST['num2'];
	$sum = $n1 + $n2;
	echo "<br> 用户名: ", $_REQUEST['userName'];
	echo "<br> 你的账户余额为: 0";
}
 ?>
<body>
	<form action='request_form.php?id=10&userName=zhangsan' method='post'>
		<!--这种表单形式,才可以让一个表单同时提交get数据和post数据:
			action 中地址里的 ? 后的数据是get数据
			form 表单中的各个表单项,就是post数据! -->
		<input type='text' name='num1' value='<?php echo $n1;?>'>		<!--数字1 -->
		+
		<input type='text' name='num2' value='<?php echo $n2;?>'>		<!-- 数字2 !-->
		<input type='submit' value='='>
		<input type='text' value='<?php echo $sum;?>'>
	</form>
</body>
</html>
```

### $\_SERVER 变量

它代表任何一次请求中，客户端或服务器端的一些“基本信息”或系统信息，包括很多（10 多项）。

$\_SERVER['xxx'] 这里的 xxx 与其余几个预定义变量的 xxx 不同, 这里是固定的 10 来个,可以通过查文档查到它们都是意思.

我们无非就是要知道，哪些信息是可以供我们使用的！

常用的有：

PHP_SELF： 表示当前请求的网页地址（不含域名部分）

SERVER_NAME： 表示当前请求的服务器名

**SERVER_ADDR**： 表示当前请求的服务器 IP 地址

DOCUMENT_ROOT： 表示当前请求的网站物理路径（apache 设置站点时那个）

**REMOTE_ADDR**： 表示当前请求的客户端的 IP 地址

SCRIPT_NAME： 表示当前网页地址

```php
echo "<br> 你的 IP 为: ", $_SERVER['REMOTE_ADDR'];
```

在你的网页的 php 代码块中, 插入这样一句,就可以显示当前请求页面的客户端的 IP.

## 可变变量

变量名本身又是一个"变量"的变量.

示例:

```php
$v1 = 10;
echo $v1;		//输出10
$str = "v1";	//这是一个名为str的变量,其值为 "v1" (字符串)
echo $$str;		//$str = v1,, $($str) = $v1 = 10
```

应用场景:

1. 获取文件后缀名后, 不确定文件后缀名, 比如:图片 jpg, png, bmp , 写可变函数名.(和 C++ 中的重载有些相似,根据实际变量选择函数)

2. 循环遍历一些后缀数字不同的变量,比如: v1, v2, v3,设置循环变量 $i,然后拼接变量: $s = "v" .$i;

# 常量

## 常量的两种定义形式

### define() 函数形式

define("常量名", 对应常量值);

常量名推荐使用全大写

### const 关键字定义

const 常量名 = 对应常量值;

例: const PI = 3.14; const PI = 1 + 2.14;

## 常量的两种取值形式

### 直接使用

echo 常量名; **常量在直接使用时,不用再名字前加$符号,直接用就行**

### 使用 constant()函数以取值

echo constant("常量名");

## 常量与变量的区别

1. 变量的数据可以变化（重新赋值），常量不可以。

2. 变量可以存储各种数据类型，而常量只能存储简单数据类型。

## 判断一个常量是否存在: defined()

判断的结果返回：true（表示存在）或 false（表示不存在）

形式：
if（ defined (‘常量名’) ) { //如果该常量名存在，则....
//....做什么事情。。。。
}

```php
//如果常量未定义过,那么定义一下,如果定义过,就不再定义,直接使用.
if (!define('PI2')) {
	define('PI2',3.1415)
}
$s2 = PI * 3 * 3;
```

## 预定义常量(用得比较少 )

预定义常量就是 PHP 语言内部预先定义好的常量，我们可以直接使用。

比如：PHP_VERSION, PHP_OS, PHP_INT_MAX, M_PI 等。
PHP_VERSION： 表示当前 php 的版本信息
PHP_OS： 表示当前 php 运行所在的系统信息
PHP_INT_MAX： 表示当前版本的 php 中的最大的整数值
M_PI： 表示圆周率 π（一个有 10 多位小数的数）

使用: (常量不用$)

```php
echo M_PI;
```

## 魔术常量 Magic Constants(用得比较多)

魔术常量也是常量，只是在形式上为常量，而其值其实是“变化”的。

他们也是系统中预先定义好的，也就几个，下面是最常用的 3 个：
\_\_DIR\_\_ ：代表当前 php 网页文件所在的目录
\_\_FILE\_\_ ：代表当前 php 网页文件本身的路径
\_\_LINE\_\_ ：代表当前这个常量所在的行号

可以动态获取信息

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/magic_constants.png)
