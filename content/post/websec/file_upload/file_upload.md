---
title: 文件上传
comments: true
toc: true
description: 本文主要使用 upload-labs 靶场，并以 Apache、PHP组合来学习以及总结文件上传的类型。不期望将每个知识点都写到，但求将大类整理好。
categories:
    - websec
    - file_upload
date: 2019-08-25 14:54:06
tags:
---

[upload-labs 靶场](https://github.com/theLSA/upload-labs)

# 预备知识

## 发现及利用

会员注册上传功能，扫描工具扫出的上传点，后台管理系统上传功能等。

## 危害

攻击者可以通过上传漏洞获取当前网站的权限，webshell 权限。

## 过滤手段

文件上传按照对上传文件的后缀名的限制分为：黑名单过滤与白名单过滤。

## 判断木马是否解析

如果是一句话的话

找到图片的地址访问它（一般是，右键新标签页打开图片网址），看看网页内容，

1. 传的只有代码，

    如果原原本本地把你的文件内容显示出来那是当做文本解析了，失败。
    如果是空白，那就好了，说明当做代码解析了。

2. 传的是图片马

    只要不正常显示图片，显示图片乱码啥的，就可以认为正常解析了。

当然，我们再用 Cknife 或中国蚁剑去连接试试就行了。

如果是由 Web 图形界面的大马

直接看图形界面显示没有就行了。

# 前端 Javascript 限制

前端 JS 限制上传文件的后缀名，常用绕过方法：

1. 浏览器禁用 Javascript
2. 先上传改为图片后缀的代码文件，然后 Burp 代理抓包，改后缀名为对应可解析代码的后缀名。
3. 修改或删减 Javascript 代码

注意：区分前端与后端限制：

1. 后端限制一般为页面回显的文字提示。JS 前端限制一般为弹窗提示（不仅仅局限于文件上传）。

    如果什么时候，你看到浏览器弹窗，就要知道这是前端 JS 代码的操作，禁用 JS 或 抓包绕过，这两种方法就要浮现在眼前。此外，如果是前端限制，在 chrome Dev tools 的 Elements 中，Ctrl + F ，便可以搜到提示文字。

2. 前端限制不需要服务器发包，不会刷新页面。
   后端限制要向服务器发包之后，会刷新页面

实例

upload labs 第一关

# 后端 MIME_types 白名单

如果是上传图片的话，就只会允许 image/jpeg、image/gif image/png 等图片相关的 MIME TYPE 上传。

> **媒体类型**（通常称为 **Multipurpose Internet Mail Extensions** 或 **MIME** 类型 ）是一种标准，用来表示文档、文件或字节流的性质和格式重要：\*\*浏览器通常使用 MIME 类型（而不是文件扩展名）来确定如何处理 URL，因此 Web 服务器在响应头中添加正确的 MIME 类型非常重要。如果配置不正确，浏览器可能会曲解文件内容，网站将无法正常工作，并且下载的文件也会被错误处理。

摘自：[MIME 类型](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types)

它位于 HTTP header 的 **Content**-**Type** 字段。

[常见 MIME 类型列表](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types)

常见的类型：

-   jpg 与 jpeg 都是 image/jpeg 类型

-   gif 是 image/gif 类型，png 是 image/png 类型。

-   `text/plain` 表示文本文件的默认值。一个文本文件应当是人类可读的，并且不包含二进制数据。
-   `application/octet-stream` 表示所有其他情况的默认值。一种未知的文件类型应当使用此类型。浏览器在处理这些文件时会特别小心, 试图防止、避免用户的危险行为.

如何确定后端在某些 HTTP 头上的限制（这里就是：MIME TYPE 限制）

这里讲一个通用的方法，当然，如果只是看 MIME-TYPES 不用这么麻烦，直接看就行啦。

上传正常后缀图片文件，抓包发送到 comparer，同样的上传 php 后缀代码文件，抓包发送到 comparer。二者对比，看看 header 头有哪些不一样的地方。当然，我们这里需要判断 Content-type 字段，那就看 content-type 是否一样，甚至可以去 Repeater 发包验证是不是 MIME-TYPES 限制，如果是的话，我们上传 php 文件，抓包改掉 content-type 就可以了。

# 后端后缀名黑名单

如果是某些代码后缀名或配置文件后缀名，便禁止上传。

绕过方式：

## 黑名单不全

过滤的后缀名不全

尝试 Web 中间件（Apache，IIS，Nginx 等）其他的可以解析的但是黑名单没有过滤的后缀名。 适用于黑名单不全的情况，要是黑名单比较全，那这个方式就不好使了。

对 Apache 与 PHP 来说（其他的思路大致一样）

Apache PHP 常见的有：php3，php4，php5，php6，phtml，phps，pht，但是要想让 Apache 解析前提是下面将的配置文件中配置了它。

理论基础：

首先在 Apache 和 PHP 以 Module 的[方式结合](https://blog.csdn.net/sinat_22991367/article/details/73431316)的情况下（我们一个个研压缩包安装的，就是 Module 方式结合，其他的还没了解过 emm），自己配置过环境的都知道，在 Apache 的 conf/httpd.conf 配置文件中，我们需要加载 PHP 的一些模块、配置 PHP 路径，并且需要配置添加 Apache 要把哪些后缀名的文件交给 PHP 解析。

而下面这语句就是

```html
AddType application/x-httpd-php .php .php3 .phtml
```

这里面的后缀名就是正常情况下，Apache 可以解析的后缀名，如果黑名单屏蔽不全的话，我们便可以使用其中之一绕过，如果都屏蔽了，那这个方法就凉了。

过滤逻辑有问题

对于有的黑名单过滤，只过滤一次后缀 php 的，可以采用双写文件名绕过，文件名改成`xx.pphphp`

实例：upload lab Pass 10

## 操作系统特性

windows 系统下

1. 在 Linux 没有特殊配置的情况下，这种情况只有 Windows 可以，因为 Windows 会忽略大小写，因此我们可以尝试大小写绕过。当然，因为 linux 环境下，路径是区分大小写的，在 apache 部署下的 web 应用，有时候出现大小写不匹配导致无法访问。我们也可以配置 apache 支持不区分大小写，这就要通过 speling_module 模块了。这我们知道就好了。

    实例：upload labs Pass 5

2. Win 下`xx.jpg[空格] 或 xx.jpg.`这两类文件都是不允许存在的，若这样命名，windows 会默认除去空格或点此处会删除末尾的点，但是没有去掉末尾的空格，因此上传一个`.php空格`文件即可。需要知道的是，如果黑名单对你的后缀名进行了去点、去空格操作，这种方法就不太好使了。当然，如果他的去除逻辑有问题，我们便可以绕过。

    实例：upload lab Pass 6，Pass 7，Pass 9

3. NTFS 文件系统包括对备用数据流的支持。这不是众所周知的功能，主要包括提供与 Macintosh 文件系统中的文件的兼容性。备用数据流允许文件包含多个数据流。每个文件至少有一个数据流。在 Windows 中，此默认数据流称为：`$DATA`。上传`.php::$DATA`绕过。(仅限 windows)

## 重写文件解析规则

上传中间件的相关配置文件，是自己的文件被对应脚本语言解析。

Apache 当后缀名没有过滤 .htaccess 时，我们可以上传 [.htaccess 文件](https://www.jianshu.com/p/81305ca91ebd)，通过它来配置我们上传的文件被 PHP 解析。

上传 `.htaccess`文件需要：httpd.conf 中的

1.`mod_rewrite模块开启`，这个作用是允许在 httpd.conf 外重写配置

2.`AllowOverride All`，这个作用是允许重写覆盖相关配置

我们上传的 .htaccess 文件内容：

```html
<FilesMatch "shell.jpg">
  SetHandler application/x-httpd-php
</FilesMatch>
```

意思是：匹配文件 shell.jpg，将此名的文件都交给 PHP 解析处理。

这种方法在它会随机改上传文件的名字的情况下，就不好使了（可以看看 Pass 3，就是这样）。一方面文件名改成了由时间名组成的文件名，这样我们的配置文件当然不能生效了。另一方面，在配置文件我们写的是：将 shell.jpg 当做 php 执行，可是，我们的 shell.jpg 也被改名字了。

实例：

upload labs Pass 2 与 Pass 3 分别对应方法一和二。

# 脚本语言函数特性

这里当然是拿 PHP 来举例了。

1.move_uploaded_file`函数的 00 截断漏洞绕过。

PHP 任意文件上传漏洞[CVE-2015-2348 浅析](https://www.cnblogs.com/cyjaysun/p/4390930.html)

对于 GET 方式 传路径

上传的文件名写成`hello.jpg`, save_path 改成`../upload/shell.php%00`，最后保存下来的文件就是`11.php`。

[CVE-2015-2348](http://www.cnblogs.com/cyjaysun/p/4390930.html)影响版本：`5.4.x<= 5.4.39, 5.5.x<= 5.5.23, 5.6.x <= 5.6.7`

对于 POST 方式传路径，由于 POST 方式不会进行 URL 解码，我们需要将%00 进行 URL Decode 或者直接在 hex 处增加 00。

上传文件名的后缀名改为正常的后缀名，.jpg，然后，在/upload/ 后面加个 shell.php+，然后，去 hex 下，将+对应的 2b 改为 00 因为用 post 获取路径，不会像 get 一样自动 url 解码。所以，用 hex 将空格（20）改为 00 或者 %00 再右键 url decode

实例：Upload labs 11

2.利用`pathinfo`的特性绕过

```php
var_dump(pathinfo("/testweb/shell.php/.",PATHINFO_EXTENSION));
string(0) ""
var_dump(pathinfo('/testweb/shell.php\00.jpg',PATHINFO_EXTENSION));
string(3) "jpg"
```

在后缀名后面加 `/.` pathinfo 获取到空的后缀名，从而绕过黑名单。然后 Window 文件后缀名会去掉 `/`、`.`及``，因此它就被识别为了 PHP。当然，利用`\00`绕过，`move_uploaded_file`会忽略后面的`.jpg`

实例：Upload labs Pass 19

3.`end`与`count`的函数特性

end() 函数将数组内部指针指向最后一个元素，并返回该元素的值（如果成功）。

count() 函数返回数组中元素的数目.

Pass 20 关键代码：

```php
$ext = end($file);
....
$file_name = reset($file) . '.' . $file[count($file) - 1];
```

`end`取的是数据的最后一个元素，无论下标（感觉 PHP 的数组有点类似 C 语言数组和结构体的合体，haha），

`count($arr)-1`取的是下标为总个数简易的元素。

reset 函数将数组的指针移到第一个元素，并返回它的值。这里是用来从数组中取文件名字。

举例：

```php
<?php
$arr = array("0"=>"jpg", "2"=>"php", "1"=>"jpg");
var_dump(end($arr));
var_dump($arr[count($arr) - 1]);

string(3) "jpg"
string(3) "php"
```

我们创建了一个数组，数组顺序不是按照寻常的顺序的，我们故意把最后一个元素排在了前面一位，这样`end`就取到了`jpg`后缀，这样我们就可以利用`$_POST[save_name]`来绕过最后后缀检测了

数组绕过，利用 end 取数组最后一个元素，而代码是取索引的最后一个。
判断时，判断最后指针的位置 save_name[2] 也就是 jpg，于是绕过后缀名检查。
拼接文件名时，使用数组的第一个指针位置即：`shell.php/`作为文件名，
使用下标为 [元素个数-1]，即：索引为 1 的数组中的值作为扩展名，我们这里没有写，因此为空。

之后使用 `$file_name = reset($file) . '.' . $file[count($file) - 1];`拼接文件名就是 `shell.php/`。但是你知道 . 在 windows 中是 `/.`会被去除的。因此，我们上传的文件名为：只需要访问：../upload/shell.php 就可以了

# 中间件解析漏洞

Apache 解析漏洞从右向左判断后缀名，从而判断能否解析。

Apache 解析文件的规则是从右到左开始判断解析,如果后缀名为不可识别文件解析,就再往左判断。比如 test.php.owf.rar “.owf”和”.rar” 这两种后缀是 apache 不可识别解析，apache 就会把 wooyun.php.owf.rar 解析成 php。

修复方法：要在配置文件里面修改，写解析漏洞的时候再详细讲吧。

实例：upload lab Pass 19

# 图片马

很多时候，我们没有别的办法了，这时候就只能是图片马加上文件包含漏洞了。

上传图片马，然后确定图片与文件包含的代码文件的相对路径，在文件包含的参数中写上图片马的相对路径及名称，然后使用蚁剑连接即可。

图片马的制作：

1. 命令行

    1. echo php 代码 >> xx.jpg

    2. copy 方法
       copy baidu.png /b + shell.php /a baidu_shell.png

2. 用记事本或 Notepad++ 或者 UltraEdit 打开图片，在最后粘贴代码即可。

像 upload labs Pass 13 要求的那样，我们电脑上一般都备好 jpg，png，gif 三种图片马，用的时候直接拿来用就好了。

注意：有些网上的图片做图片马不会成功，最好找一些免费没版权的图片来整。如果你的图片马解析不了，不妨多换个七八张个图片试试 emm。（这也是为什么让你以后备好图片马的原因，感觉好像是图片问题，不是所有的图片做成图片马之后，都会被正常解析。）

## 常见函数：

unpack() 函数从二进制字符串对数据进行解包，常用来检测文件头。

可以通过添加图片的头部标识绕过，比如：添加 GIF 图片的文件头`GIF89a`，绕过 GIF 图片检查。

getimagesize() 函数用于获取图像大小及相关信息，成功返回一个数组，失败则返回 FALSE 并产生一条 E_WARNING 级的错误信息。返回值为数组，数组的索引 2 给出的是图像的类型，返回的是数字，每个数字对应一种图片类型。

stripos() 函数查找字符串在另一字符串中第一次出现的位置（不区分大小写）。

exif_imagetype — 判断一个图像的类型，**exif_imagetype()** 读取一个图像的第一个字节并检查其签名。

upload Pass 13 检测文件头，Pass 14 检测文件类型，Pass 15 exif_imagetype 检测通过检测图像的第一个字节并检查签名来判断图像类型。

## 二次渲染

优先使用 gif，其次，jpg，最后 png。

对 gif 的二次渲染来说，我们上传 gif 图片，然后下载，按 16 进制查看下载的图片与原上传的区别，确定渲染处理部分。将一句话插入到未被渲染处理的部分，然后上传即可。

对于 jpg 以及 png 的处理，可以看[upload-labs 之 pass 16 详细分析](https://xz.aliyun.com/t/2657#toc-12)，感觉好像二者相比，jpg 更为简单，直接运行大佬的脚本就行了。

实例：

Upload labs Pass 16

这里不详细搞了，遇到再说吧。

# 条件竞争

条件竞争漏洞是一大类逻辑漏洞，不仅仅限于文件上传，也常见于转账等交易场景。

从 Pass-17 来看，代码是先移动文件到 upload 文件夹，然后判断后缀是否在名单中，再删除与否，我们可以通过一定的时间差来访问自己上传的文件导致写入 shell 的。

```php
<?php file_put_contents("shell.php","<?php phpinfo();?>");?>
```

这里我们的代码就要稍微改一下，我们改成写文件的代码。这样只要我们访问到一次，我们就生成了 shell.php 的一句话，然后再去连接爽歪歪。

条件竞争常使用：Burp Suite、Fiddle 等抓包工具，或者自己编写 Python 脚本来测试

使用 Burp intruder 模块，开启两个 Attack，一个不断上传，一个不断访问上传的文件（当然，你要预先能推测出上传后你的文件名以及位置。）。中间我们需要设置线程数（将访问线程开的比上传的线程打大一些，比如：25:5）以及设置 Payload Type 为 nullpayload，然后设置 Payload Option（设置激发多少次，或者一直攻击），一般我都设置成一直攻击。先发起 post 上传 attack，再发起 get 访问 attack。然后根据 get 的返回长度及返回数据包，我们发现访问成功以后，便去访问创建的 shell.php，查看它是否解析成功，然后用工具去连接。

## 参考资料

来两个简单的，深层次到操作系统的，咱也看不懂，咱也看不下去呀。

实例：Pass 17，Pass 18

[条件竞争](https://v0w.top/2018/08/16/%E6%9D%A1%E4%BB%B6%E7%AB%9E%E4%BA%89/)

[结合 CTF 详解条件竞争漏洞](https://co0ontty.github.io/2019/04/12/batterupload.html)

[条件竞争（Race Condition）](https://mengsec.com/2018/04/07/Race-Condition/)

# 总结回顾

1. 要接着学，从 Apache 与 PHP 要衍生到别的组合
2. 熟悉了解中间件的配置文件以及一些关键配置。
3. 自己搭建环境。复现相关解析漏洞。

# 推荐阅读

[文件隐藏 之 NTFS 交换数据流](https://klionsec.github.io/2017/11/13/ntfs-streams/)

[谈谈 NTFS 数据流文件](https://blog.csdn.net/vivilorne/article/details/3841509)

[文件寄生——NTFS 文件流实际应用](https://gh0st.cn/archives/2017-03-29/1)

[服务器解析漏洞](https://thief.one/2016/09/21/%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%A7%A3%E6%9E%90%E6%BC%8F%E6%B4%9E/)

[Upload-labs 20 关通关笔记](https://xz.aliyun.com/t/4029#toc-7)

[文件解析漏洞总结](https://www.smi1e.top/%E6%96%87%E4%BB%B6%E8%A7%A3%E6%9E%90%E6%BC%8F%E6%B4%9E%E6%80%BB%E7%BB%93/)

[对文件上传的一些思考和总结](https://www.anquanke.com/post/id/164561#h3-7)

[简单粗暴的文件上传漏洞](https://paper.seebug.org/560/#2-filename)
