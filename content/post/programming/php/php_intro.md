---
title: 初识PHP
toc: true
description: 掌握 Web 服务端架构，清楚请求访问的具体流程，并为学习PHP搭建好环境。
tags:
    - php
categories:
    - programming
date: 2019-07-21 13:26:42
tags:
---

# 预备知识

## 动态与静态页面

在介绍 php 之前，有必要了解一下静态页面与动态页面的区别：

[静态网页与动态网页的区别](https://www.jianshu.com/p/649d2a0ebde5)，[静态网页与动态网页的理解](http://xbhong.top/2018/02/15/static/)

其中，动态网页：

1. 会因为浏览时间或不同的人而呈现不同的内容。（比如：订单详情）
2. 后台程序的运行结果（动态程序），最终目的，是为了“输出”前台的静态页面。

## 网站访问流程(浏览器端过程)

从浏览器输入一个网址，到我们看到这个网页展示出来，其中的过程大致为：

1. 先在本机的 hosts 文件中，查找域名所对应的 IP；

2. 如找到，则根据该 IP 就可以找到并访问该服务器了，服务器返回相应网页信息，访问结束；

3. 如没有找到，则到互联网上的 DNS 服务器中，查找域名所对应的 IP；

4. 如果找到，则根据该 IP 就可以找到并访问该服务器了，服务器返回相应网页信息，访问结束；

5. 如果没有找到，则浏览器会有类似“无法找到服务器”的报错提示，访问结束。

## web 服务端发展历程

### WEB 的静态页面时期

1. 浏览器根据 URL 向 web 页面发送请求，WEB 服务端会去相应的服务器找到对应的 html 文件。
2. 服务器将该 html 的内容发送给浏览器端
3. 浏览器端接收 HTML 通过渲染引擎进行渲染，并显示页面

### WEB 的动态页面时期

动态页面由脚本驱动的（php 是脚本语言）。脚本语言文件（如：php 文件）由服务端的对应的语言解释器解释为 HTML 文件，然后发送到 WEB 服务端进而发送到浏览器渲染显示。但是显示到浏览器上时，它的后缀不是 HTML，而是对应脚本语言的名称（如：.php）

当我们建立一些数据庞大的网站时，便需要数据库服务。提供 WEB 网站的数据支持。浏览器发送请求，服务端收到请求，定位文件，脚本语言到达解释器，进行解释，根据脚本文件中调用数据库的命令/内容，向数据库调取或操作数据，而后数据库返回相应的数据。这些数据通过语言解释器，再组装成 HTML 内容，最后发送给浏览器，渲染显示。

数据库，web 服务器，语言解释器 这三个模块构成现在 web 服务端的架构。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/struct.png)

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/struct_detail.png)

一般情况下，语言解释器和 web 服务器位于同一个服务器上，两者使用配置文件进行连接（Apache 配置文件等..）。脚本文件也是通过配置文件连接到数据库服务的（PHP 解析器配置，PHP 网站文件配置）。

目前流行的架构：

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/PHP/struct_popular.png)

## 网络应用体系架构

C/S 模式（结构）：C：Client （客户端）、S：Server（服务器）

B/S 模式（结构）：B：Browser （浏览器）、S：Server（服务器）

# PHP 简介

PHP ：Hypertext Preprocessor 超文本预处理器，（PHP/FI（form Interpreter）在 1995 年由 Rasmus Lerdorf 创建。起初脚本取名为“Personal Home
Page Tools”，也是 PHP 名称的由来。）最新 PHP 版本 PHP 7.0x。

[全球大约 80%的网站](https://w3techs.com/technologies/details/pl-php/all/all)都是用了 PHP 技术作为网站后台服务程序。

### PHP 的特点

-   Web 服务器端的主流开发语言，用来实现用户请求。
-   开源软件，所有操作系统下均可以运行
-   入门简单，快速开发
-   支持主流的数据库，比如；MySQL、MSSQL、Oracle

-   php 是弱类型语言(与 JavaScript 相似)

    1. 从变量角度：在声明一个变量不需要声明其类型，这事 PHP 的特色，因为他交给了底层

        底层的变量存储是在一个 zval 结构里，声明一个变量会把所有类型都考虑到并开辟空间，同种类型默认用最大限度声明(int 用 long,float 用 double)，这样绝对满足的所有变量的需求

    2. 从运算的角度：底层会根据你当前变量类型做转换并运算，并且返回结果做类型转换（string+string=int,float+string=float,sting('')==int0...）；数组也可以加减参与运算；

## 搭建环境

方案一：可以自己分别安装 Apache，MySQL，PHP，鉴于太麻烦，弃用。

方案二：安装集成环境

集成环境：

-   WampServer 是法国人开发的一款 Windows Apache Mysql PHP 集成安装环境，即在 window 下的 apache、php 和 mysql 的服务器软件。

-   phpStudy 是一个 PHP 调试环境的程序集成包。该程序包集成最新的 Apache+PHP+MySQL+phpMyAdmin+ZendOptimizer，一次性安装，无须配置即可使用，是非常方便、好用的 PHP 调试环境。该程序不仅包括 PHP 调试环境，还包括了开发工具、开发手册等。

这里选用 php study v8.0 最新版.

### Apache 配置信息简介

apache 安装后，有一个默认站点，其配置都在 apache 的主配置文件（apache/conf/httpd.conf）中。
主要包括如下几项：
1，站点域名：
ServerName 1ocaltsst
域名是可以设置的！
2，站点位置（文件夹位置）：
DocumentRoot H:itcast\class bj-quanzhan4\amp\Apachet\htdocs

如果是 phpStudy 带的 Apache 的话，DocumentRoot 应该是 ..\phpstudy\PHPTutorial\WWW

站点位置是可以设置的！
3，站点文件夹的访问权限设置：
使用-Directory>..</Directory 配置项来配置。
4，站点默认显示的网页（首页）：
DirectoryIndex index.html
默认网页（首页）是可以设置的。

5.1.3.网站文件夹访问权限的设置。
文件夹的访问权限的设置形式如下所示：
<Directory “要设置权限的文件夹路径>
Options 设置项
AllowOverride 设置项
Require 权限设置项
<Directory>
各项解释如下：
Options：用于设置一些系统选项，通常 window 系统中就用 Indexes 就可以了。
Options Indexes//表示允许列出目录结构（如果没有可显示的网页）
AllowOverride：用于设置“可覆盖性”，即是否允许在项目文件中覆盖这里的访问权限设置：
AllowOverride All //表示可覆盖
AllowOverride None /表示不可覆盖
Require：用于设置可访问权限，常用的有：

-   允许所有来源的访问：一一推荐
    Require All granted
-   拒绝所有来源的访问：一一网站需要临时关闭时使用
    Require All denied
-   允许所有但拒绝部分来源的访问：
    <RequireAll>
    Require all granted
    Require not ip 192.168.1.102 192.168.1.103
    <RequireAl>
-   拒绝所有但允许部分来源的访问：
    <RequireAny>
    Require all denied
    Require ip 192.168.1.102 192.168.1.103
    <RequireAny>

总结:

浏览器出发（请求）--> 找 hosts 文件 --> 找网络上 DNS 服务 --> 进入相应的服务器--> Apache--> PHP --> mysql 数据库模块 --> mysql 数据库。

Apache 中调用 PHP 的设置：
LoadModule php7_module “php 目录/php7apache2_4.dll”
AddType Application/x-httpd-php .php .php4 .php3

hosts 文件中的内容：
127.0.0.1 [www.a.com](http://www.a.com)
127.0.0.1 www.quanzhan7.com
127.0.0.1 www.php69.com
PHP 的基本设置：
设置 php.ini 的位置：
在 apache 的主配置文件(httpd.conf)中： PHPIniDir “php 目录”

设置 php 的运行时区：
在 php.ini 中设置： date.timezone = PRC
PHP 的模块设置（以 mysqli 模块为例）

\#设置 PHP 的模块所在位置（目录）
extension_dir = “php 目录/ext/”

\#开启所需要的模块：
extension = php_mysqli.dll

mysql 的安装与配置

注:使用 phpStudy 并不需要修改 Apache 的配置，但是在这里仍介绍一下一些重要的配置，便于理解，扩展知识（如果想要详细了解，自己搭建一遍 wamp 环境就差不多了）。

### 注意事项

mysql 用户名密码都是 root

phpMyAdmin 账号密码和 mysql 一样： root root

一个网站，就是一个文件夹。一个网页，就是一个文件。

192 开头、172 开头的 ip 地址，规定只用于局域网的 ip。

每个电脑，都有一个最精简的最小规模的“域名解析服务器”，为 hosts 文件。win10 中需要操作系统权限才能修改。

修改方式：以管理员身份运行 notepad.exe ，菜单栏->文件 -> 找到 host 文件, 这样就可以修改后保存了.

感想：以后有别的需要，会接触比较多的语言，等哪一天，该把语言的分类，强弱类型，动态/静态，解释/编译，什么的都理理思路，然后把学习一门语言要学哪几部分好好看看。这样，以后学起语言才能得心应手呀。
