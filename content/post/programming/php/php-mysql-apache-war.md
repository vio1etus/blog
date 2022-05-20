---
title: WAMP 安装配置以及 war 包导入 Tomcat
comments: true
toc: true
description: 本文记录自己搭建 WAMP 的过程以供参考借鉴，涉及Apache 2.4，PHP 7.3，PHP5.6，MySQL8.0
tags:
    - php
categories:
    - programming
date: 2019-08-20 14:52:31
tags:
---

最近被 PHP Study 坑惨了，打开 PHP study 的 MySQL、Aapche，在后台找不到服务，Tomcat 导入 war 包也连接不上数据库，都是泪呀。

注意：自己配置好下面的环境后，即使是绿色的 phpstudy 等这些工具也不要用了，它会直接禁用本地 mysql，apache，而且你还无权访问（管理员账户都不行），唉，我因为这又重装了一遍

网上找到的教程都很好，这里推荐一下我搭建环境过程中参考的两篇文章

推荐文章（两个文章一起看，互补）：

[windows 配置 apache2.4+php7.2+mysql8.0](https://www.cnblogs.com/lx0715/p/9955069.html)

[Apache2.4.34 + php 7.28 + MySQL8.0.12 安装及配置](https://www.w3xue.com/exp/article/20189/817.html)

# 主要步骤

## apache

1. 修改服务器根路径
2. 添加 php 扩展（与 php 路径有关），如果你要使用多版本 php，只需要在这里的 httpd.conf 中对应配置即可（事实上，你可以提前写好，需要用哪个版本，解注释那个版本的配置即可。）
    1. 加载 php 中与 apache 相关的 dll
    2. 添加 php.ini 文件路径
3. 命令行安装 apache 服务（可以指定服务名，默认为：Apache2.4）

## PHP

1. 修改 php.ini，配置 php 扩展的路径（与路径有关）
2. 添加 mysql 扩展。

## MySQL

1. 修改 my.ini 配置 mysql 路径（与路径有关）

2. 初始化

3. 安装服务

4. 进入 mysql，修改密码

    alter user 'root'@'localhost' identified by 'youpassword';

# 遇到的问题：

1. Apache 2.4 不支持 TLS 3.0，因此会报错

    你可以在 Apache 配置文件 httpd.conf 中 搜索 ENABLE_TLS13，会有这样一句 Define ENABLE_TLS13 "Yes" 这一句话去掉就行了，这样就 apache 就不会使用 TLS 1.3 了。

2. 统一命名

    mysql 我安装的时候，未指定服务名称，我发现 mysql 和 MySQL 都可以用，对应的都是服务下 MySQL 那个服务，安装是可以指定服务名称

    apache 也是，服务名称默认是 Apache2.4，你在安装的时候，也可以指定。提一句，Tomcat 8 默认的服务名是 Tomcat8

3. 如果安装的 apache 的时候报错了，我采用的是卸载，然后修改对应配置解决，然后再安装的方式。

4. 如果要配置虚拟主机需要将 httpd.conf 下的这两句解注释，这样才能是 httpd-vhosts.conf 中的配置生效。

    ```html
    LoadModule vhost_alias_module modules/mod_vhost_alias.so .... Include
    conf/extra/httpd-vhosts.conf
    ```

    我配置的一个虚拟主机，在 extra/httpd-vhosts.conf 最后加上下面配置，然后 计算机的 host 中添加 lab11.me 转到 127.0.0.1

    ```html
    #site 2
    <VirtualHost *:80>
    	ServerName  lab11.me
    	DocumentRoot "D:/WWW"
    	<Directory  "D:/WWW" >
    		#允许列出目录
    		Options Indexes
    		#允许权限覆盖
    		AllowOverride  All
    		#允许所有访问
    		Require  all  granted
    	</Directory>
    	ErrorLog "logs/lab.me-error.log"
    	CustomLog "logs/lab.me-access.log" common
    	DirectoryIndex  abc.php  index.php  index.html
    </VirtualHost>
    ```

5. apache 启动发生 “发生服务特定错误: 1.” 可能是 php 32 位 apache 64 位，加载 dll 的问题，具体可以去看 window 事件日志的应用程序日志。
6. 注意：apache 不要使用 nts（no thread safe）php 的版本，php 与 apache 版本也有搭配，有的版本不支持有的版本...

将 war 包导入 Tomcat 请看下面博文：

[war 包放入 tomcat](https://www.cnblogs.com/yaowen/p/5684455.html)

# 总结反思：

1. 之前不太在意 64 位、32 位的区别，本次安装知道了象这种套件，版本要一致。
2. 学会了看程序的日志，Windows 系统的事件日志，这对以后确定问题原因很有帮助呀。
3. 掌握了多版本 php 的配置，当然，也可以多版本 mysql 道理都一样。
4. 掌握了将 war 包导入 Tomcat 的方法，简单方便。
