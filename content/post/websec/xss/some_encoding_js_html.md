---
title: XSS 涉及的一些编码与引号问题
comments: true
toc: true
tags:
    - XSS
description: 简要介绍一下 html 与 js 中的编码与引号的问题，便于我们理解 XSS
categories:
    - websec
    - xss
date: 2019-08-15 17:45:11
---

# html 属性值的引号问题

如果 html 文件在写属性值没有用括号包围，默认见到空格会认为该属性值已经完结，后面的字母它会认为是一个空属性。

html 中成对使用上，不缺分单双引号，但是如果引号要嵌套的话，有四种解决方式：

1. 内双引号，外单引号
2. 内单引号，外双引号
3. 外部不使用引号
4. 内部使用 HTML 的实体编码：\&quot;

# alert 函数

事件绑定函数 alert 中的参数，如果是数字可以直接写，如果是字符串要加单引号，其他函数也是这样

# js 中字符串的表示方式

JavaScript 共有 6 种方法可以表示一个字符，当然字符串就是一个个字符拼接起来的了

```javascript
"z" === "z"; // true
"\172" === "z"; // true		8进制
"\x7A" === "z"; // true		16进制
"\u007A" === "z"; // true	unicode编码
"\u{7A}" === "z"; // true	带括号的unicode编码
```

# Js 中的常用编码相关函数

fromCharCode() 可接受一个指定的 Unicode 值，然后返回一个字符串。

语法

```
String.fromCharCode(numX,numX,...,numX)
```

| 参数 | 描述                                                                   |
| :--- | :--------------------------------------------------------------------- |
| numX | 必需。一个或多个 Unicode 值，即要创建的字符串中的字符的 Unicode 编码。 |

## 提示和注释

**注释：**该方法是 String 的静态方法，字符串中的每个字符都由单独的数字 Unicode 编码指定。

它不能作为您已创建的 String 对象的方法来使用。因此它的语法应该是 String.fromCharCode()，而不是 myStringObject.fromCharCode()。

注意：在这里 numX 与其前面的逗号之间有无空格均可，但是在 html 中，如果我们是这样使用：

```html
<img
    src="1"
    onerror="eval(String.fromCharCode(97,108,101,"
    114,116,40,49,41))
/>
```

再扩大一点，是我们在属性值中使用 String.fromCharCode()，所以如果你使用上面 payload 的时候，如果 String.fromCharCode(97,108,101, 114,116,40,49,41) 中的逗号之后有空格，就不会触发 XSS，所以我们有两种解决方式：

1. 不加空格（注：有的 hackbar 自带空格就很不太好，可以使用 chrome 插件中的图标为 H 的那个 hackbar，之前也介绍过。）。

2. 将属性值用引号包围起来

    ```html
    <img
        src="1"
        onerror="eval(String.fromCharCode(97, 108, 101, 114, 116, 40, 49, 41))"
    />
    ```

    这样，空格啥的就不会被误认为是属性值的结束了。

推荐阅读：

[html 标签中，单引号和双引号区别：](https://blog.csdn.net/shadow_zed/article/details/71076339)

[字符串的扩展](http://es6.ruanyifeng.com/#docs/string)
