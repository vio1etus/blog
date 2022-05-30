---
title: URL 编码那点儿事
toc: true
description: 本文简要介绍 url 编码相关知识来帮助我们更好得理解编码、掌握编码绕过。
summary: 本文简要介绍 url 编码相关知识来帮助我们更好得理解编码、掌握编码绕过。
categories:
    - network
date: 2019-08-04 10:08:50
tags:
---

没什么好写的了，网上优秀的资料很多呀。我就是资源搬运工 haha。

好的博文：

[URL 编码的奥秘](https://aotu.io/notes/2017/06/15/The-mystery-of-URL-encoding/index.html)

[关于 URL 编码](http://www.ruanyifeng.com/blog/2010/02/url_encoding.html)

[HTTP URL 字符转义 字符编码 、 RFC 3986 编码规范](https://www.cnblogs.com/panchanggui/p/9436348.html)

关于空格应该被编码为%20，还是 +？简单来说，两个标准规定有些混乱，导致应用们实现起来也比较混乱。

摘自[空格的 url encode 到底是+还是 ？](https://blog.csdn.net/stpeace/article/details/60371396)

> 无论是哪种规范， url decode 的时候， 都能正确 decode. 实际经验表明也确实如此！

我们不用管那么多，知道都能用就行了。
