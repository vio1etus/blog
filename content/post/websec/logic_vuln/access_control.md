---
title: 访问控制与越权
comments: true
toc: true
description: 本文简要介绍业务逻辑漏洞及其挖掘姿势，并介绍授权验证绕过及密码找回等常见逻辑漏洞
categories:
    - websec
    - logic_vuln
date: 2020-03-25 21:51:20
tags:
---

# Introduction

访问控制往往是漏洞的高发地带，而且往往是危害严重。时至今日，最新版的 OWASP 2017 top 10 中 Broken Access Control 仍位居第五。

本文将讨论访问控制安全，讲述越权以及那些由访问控制不当而导致的漏洞，最后总结如何避免这些漏洞，下面我们先来了解以下三个概念以及他们之间的关系。

## Three Concepts

-   身份验证 ( 认证 )：鉴别用户身份，确定该用户与他自己所声称的身份一致。
    Authentication identifies the user and confirms that they are who they say they are.

-   会话管理：确定后续的 HTTP 请求是由与之前相同的用户发出。
    Session management identifies which subsequent HTTP requests are being made by that same user.

-   访问控制确定是否允许用户执行他们尝试执行的操作。
    Access control determines whether the user is allowed to carry out the action that they are attempting to perform.

> 从逻辑上讲，应用程序核心安全机制的访问控制建立在**验证和会话管理**之上，尤其是在 Web 应用程序的上下文环境中更是如此。应用程序通过验证机制来核实用户身份，并通过会话管理来保证它收到的一系列请求由该用户发出。应用程序之所以需要这样做，至少从安全上讲，是因为它必须决定是否允许某个请求执行特定的**操作**或访问它请求的**资源**。访问控制是应用程序的一个重要防御机制，因为它们负责做出这些关键决定。如果访问控制存在缺陷，攻击者往往能够攻破整个应用程序，控制其管理功能并访问属于其他用户的敏感数据。
>
> 当然，即使是应用程序做出一切努力执行稳定的验证与会话管理机制，但由于没有在它们上面建立任何有效的访问控制，这方面的投资也就相当于白白浪费了，这种情况非常常见。这些漏洞如此普遍的一个原因在于，需要对每一个请求，以及特殊用户在特定时刻尝试对资源执行的每一项操作执行访问控制检查。
>
> 而且，与许多其他类型的控制不同，访问控制的设计和管理是一个复杂而动态变化的问题，它需要将复杂的业务逻辑，组织和法律约束等用技术实现，而每个企业业务、法律约束、组织规范又都是不一样的。这导致访问控制的设计决策必须由人决定，而无法采用技术来解决。也因此，越权漏洞很难通过扫描工具发现出来，往往需要通过手动进行测试。

注意：
上面三段这么深刻（肯定不是我写的），基本选自《黑客攻防技术宝典 Web 实战篇（第 2 版）》

### Examples

你通过更改 id 来实现查看别的资料等，应用程序验证了你是你，然后通过会话管理机制确保了该请求是由你发出，但是由于权限控制没做到位，没有限制你访问别人的资料，进而就产生了这个漏洞。

## Access Control

访问控制是指在应用程序中，对用户尝试执行的**操作**或尝试请求的**资源**的控制。换句话说，当攻击者可以访问或修改他们本不可访问的**对象**（例如文件, 数据库记录，帐户等）或使用一些其本不该具有的**功能**，就存在访问控制漏洞。

并附上 OWSAP 对有缺陷的权限控制的描述：

> [**Broken Access Control**](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A5-Broken_Access_Control). Restrictions on what authenticated users are allowed to do are often not properly enforced. Attackers can exploit these flaws to access unauthorized functionality and/or data, such as access other users’ accounts, view sensitive files, modify other users’ data, change access rights, etc.

可以将访问控制分为三类：

1. 垂直权限访问控制（Vertical access controls）
2. 水平权限访问控制（Horizontal access controls）
3. 基于上下文的访问控制（Context-dependent access controls）

## Vertical access controls

访问控制是建立用户角色与权限之间的关系，

垂直访问控制是一种基于角色的访问控制（RBAC，Role Based Access Control），它是指将系统中的用户的权限以角色（Role）划分，根据角色来限制可使用的敏感功能点。通过垂直访问控制，不同类型的用户可以访问不同的应用程序功能。 垂直访问控制是安全模型的更加细粒度的实现，这些安全模型旨在将企业策略等付诸实践，例如职责和最低特权的分离。

### Example

在一个论坛中，有管理员、普通用户、游客三种角色，管理员有删除、编辑、置顶帖子的权限，普通用户有评论和浏览帖子的权限，游客只有浏览帖子的权限。目前已有 Shiro，Spring Security 等基于 RBAC 模型的成熟框架来处理功能权限管理和鉴权的问题。

## Horizontal access controls

水平访问控制是一种基于数据的访问控制，它通过限制特定用户访问其对应的特定资源来实现。通过水平访问控制，不同的用户可以访问相同类型的资源的子集。 例如，银行业务应用程序将允许用户查看自己的交易并从自己的帐户进行付款，但不能查看其他任何用户的帐户。

### Example

同属于普通用户角色的用户 A 和用户 B，正常情况下，他们只能访问自己的私有数据，例如：修改/查看个人详细资料、增加/查看/删除个人订单、查看/删除个人邮件等。

## Context-dependent access controls

基于上下文的访问控制根据应用程序的状态或用户与应用程序的交互来限制对功能和资源的访问。

上下文相关的访问控制可防止用户以错误的顺序执行操作。
例如，零售网站可能会阻止用户在付款后修改购物车中的内容。找回密码过程中，不能

### Examples

在购物网站的付款的多阶段过程：（添加购物车 -> ）点击购买 -> 下订单 -> 付款 -> 确认订单；
在找回密码的多阶段过程：(用户名 ->) 手机号/邮箱 -> 验证码 ->新密码；
需要确保前后的数据等的一致性以及按顺序进行。

# Vertical privilege escalation

如果用户可以使用那些他们不被允许使用的功能，那这就是垂直越权。 例如：如果非管理用户可以访问可以具有删除用户帐户功能的管理页面，则这是垂直越权。

## Unprotected functionality

在最基本的情况下，如果应用程序不对敏感功能实施任何保护，则会出现垂直越权。
例如：管理员的欢迎页面中链接着管理功能，而用户的欢迎页面就没有。但是，用户可能可以通过直接访问浏览相关的管理 URL ，就能访问管理功能。

例如：一个网站在以下的 URL 中存在着敏感功能点： `https://insecure-website.com/admin`

实际上，在该网站中，不仅是在其用户界面中存在该功能链接的管理员，任何用户都可以访问此目录。 在某些情况下，管理 URL 可能会在其他位置泄露，例如 robots.txt 文件： `https://insecure-website.com/robots.txt`
如果 URL 没有在任何地方都没有泄露，攻击者还可以跑字典来暴力破解敏感功能点的位置。

[LAB: Unprotected admin functionality
](https://portswigger.net/web-security/access-control/lab-unprotected-admin-functionality)

## Parameter-based access control methods

某些应用程序在登录时确定用户的访问权限或角色，然后将此信息存储在用户可控制的位置，例如隐藏字段，cookie 或预设查询字符串参数。 应用程序根据提交的值做出后续的访问控制决策。 例如：
`https://insecure-website.com/login/home.jsp?admin=true`
`https://insecure-website.com/login/home.jsp?role=1`

这种方法从根本上来说是不安全的，因为用户可以简单地修改值，然后就获得对未经授权的功能（例如管理功能）的访问权限。

[LAB：User role controlled by request parameter](https://portswigger.net/web-security/access-control/lab-user-role-controlled-by-request-parameter)

[LAB：User role can be modified in user profile](https://portswigger.net/web-security/access-control/lab-user-role-can-be-modified-in-user-profile)

## Broken access control resulting from platform misconfiguration

某些应用程序通过基于用户角色限制对特定 URL 和 HTTP 方法的访问来在平台层实施访问控制。 例如：一个应用程序可能配置如下规则：

> DENY: POST, /admin/deleteUser, managers

该规则拒绝 managers 组中的用户通过 POST 请求访问 URL：`/ admin / deleteUser`，在这种情况下，很多事情都可能会出错，从而导致访问控制被绕过。

一些应用程序框架支持各种非标准 HTTP 头，它们可用于覆盖原始请求中的 URL，例如 X-Original-URL 和 X-Rewrite-URL。 如果一个网站使用严格的前端控件来限制基于 URL 的访问，但是应用程序允许通过一个请求头覆盖 URL，则它可能可以使用如下请求来绕过访问控制：

```http
POST / HTTP/1.1
X-Original-URL: /admin/deleteUser
...
```

[LAB: URL-based access control can be circumvented](https://portswigger.net/web-security/access-control/lab-url-based-access-control-can-be-circumvented)

> 注：X-Original-URL 写相对 URL（相对 URL 从 / 开始，表示当前 URL 的根目录）， GET 那里写参数
> GET 方法指定在提交表单时将参数值追加到 URL 请求上。

```http
GET /?username=carlos HTTP/1.1
Host: acf61fbd1f0575ac80b2daf200190016.web-security-academy.net
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3835.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Cookie: session=sw017My5iPscUyAzDeCUJEFJiDbuqiom
Upgrade-Insecure-Requests: 1
X-Original-URL: /admin/delete
```

与请求中使用的 HTTP 方法有关的其他攻击也可能会产生。 上面的前端控件基于 URL 和 HTTP 方法限制访问。 某些网站在执行操作时可以使用其他 HTTP 请求方法。 如果攻击者可以使用 GET（或其他）方法对受限制的 URL 执行操作，则他们可以规避在平台层实现的访问控制。

[LAB: Method-based access control can be circumvented](https://portswigger.net/web-security/access-control/lab-method-based-access-control-can-be-circumvented)

# Horizontal privilege escalation

当用户能够访问属于其他用户的同种类型资源，而不是他们自己的时，就出现了水平越权。 例如：如果一个员工只应该能够访问自己的工作和工资记录，但实际上也可以访问其他员工的记录，那么这就是水平越权。

## Classification

其实关于水平越权的分类，没啥标准，这里为啥要提一下呢，主要是便于大家对越权发生的具体场景有一个更加形象具体的了解。本文讲的时候，就不刻意区分了。

根据对数据的操作分类

1. 越权增加（增）
2. 越权删除（删）
3. 越权修改（改）
4. 越权查看（查）

上面我们讲到水平权限控制是基于数据的访问控制，而对于数据来说，就有：增、删、改、查 四种操作方式，因而越权漏洞的成因也主要是因为开发人员在对数据进行增、删、改、查询时，对客户端请求的数据过分相信而遗漏了权限的判定。

根据数据的对象分类

1. 基于用户身份 ID
2. 基于对象 ID
3. 基于文件 ID

## Test Methods

基本：两个账户，两个浏览器，分别登陆，查看对方 id 标识，然后改成对方的，测试。

## Four Test Scenario

### id 直接可遍历

场景： id 直接就是简单的数字
举例子：

1. 使用 Burp 的 intruder 进行遍历
2. 自己写 py 等脚本遍历

#### Local lab

Webug 和 pikachu 靶场练习

#### Online lab

水平越权攻击可能使用与垂直越权类似的利用方法。 例如：用户通常可以使用如下网址来访问自己的帐户页面：
`https://insecure-website.com/myaccount?id=123`

现在，如果攻击者将 id 参数值修改为另一个用户的 ID 参数值，则攻击者可能会访问具有相关数据和功能的另一个用户的帐户页面。

[LAB: User ID controlled by request parameter](https://portswigger.net/web-security/access-control/lab-user-id-controlled-by-request-parameter)

#### Cases

越权删除：

[百度创意专家某功能平行权限漏洞（可删除他人素材）](http://www.onebug.org/wooyundata/6663.html)

[华住酒店某处越权删除修改用户信息](http://wy.zone.ci/bug_detail.php?wybug_id=wooyun-2016-0212974)

[搜狐白社会任意用户信息修改漏洞](http://wy.zone.ci/bug_detail.php?wybug_id=wooyun-2013-036411)

套路：

1. 查看自己的删除请求，发现标识自己的 id 参数 --> 寻找功能点的请求包， 发现用户标识
2. 寻找别人的 id 参数，然后拿过来，替换到删除的请求包中，重放包 --> 替换为别人的用户标识，重放功能点的请求包
3. 观察结果

越权查看、修改：

[Like 团用户信息泄露+越权漏洞（可获取大量用户住址联系信息）](http://wy.zone.ci/bug_detail.php?wybug_id=wooyun-2013-033748)

越权增加、删除、修改：
[爱拍越权漏洞及设计不合理漏洞大礼包（妹子哭了）](http://wy.zone.ci/bug_detail.php?wybug_id=wooyun-2013-033542)

### id 可逆编码

举例

对于 payload， 先编码，再遍历。

场景：id 类似某种编码，比如：base64 编码， 简单 md5（复杂的解不出来呀 emm） 等（需要手动尝试解码，看看能不能解码，解出来是啥）

方法：

1. 使用 Burp 的 intruder 进行编码，遍历
2. 自己写 py 等脚本遍历

### id 前端 JS 加密

场景：前端 JS 加密 id，比如：ras，aes 加密等

方法：
浏览器开发者工具 JS 断点调试，找出加密前的值，进行手动修改
找到加密方法后，可以写脚本遍历。

### id 不可遍历

## Online Lab

在某些应用程序中，可利用参数的值并不可预测。 例如，应用程序可以使用全局唯一标识符（GUID）来标识用户，而不是递增数字。 在这里，攻击者可能无法猜测或预测另一个用户的标识符。 但是，属于其他用户的 GUID 可能会在引用用户的应用程序的其他位置泄露，例如用户消息或评论。

[LAB: User ID controlled by request parameter, with unpredictable user IDs](https://portswigger.net/web-security/access-control/lab-user-id-controlled-by-request-parameter-with-unpredictable-user-ids)

在某些情况下，应用程序会检测到何时不允许用户访问资源，并将其重定向返回到登录页面。 但是，包含重定向的响应可能仍然包含一些属于目标用户的敏感数据，因此攻击仍然是成功。

[LAB: User ID controlled by request parameter with data leakage in redirect](https://portswigger.net/web-security/access-control/lab-user-id-controlled-by-request-parameter-with-data-leakage-in-redirect)

## Real Bug Hunting

# Horizontal to vertical privilege escalation

通常情况下，通过攻击权限较高的用户，可以将水平越权转变为垂直越权。 例如：水平越权可能允许攻击者重置或获取属于另一个用户的密码。 如果攻击者以管理员用户为目标并攻击了他们的帐户，那他们便可以获得管理员权限，因此可以进行垂直越权。

例如，攻击者也许可以使用在前面针对水平越权已经讲述过的参数篡改技术来访问另一个用户的帐户页面：

`https://insecure-website.com/myaccount?id=456`

如果目标用户是应用程序管理员，则攻击者将获得对管理帐户页面的访问权限。此页面可能泄露管理员密码或提供修改密码的手段，又或者可能提供对特权功能的直接访问。

# Insecure direct object references

不安全的直接对象引用（IDOR）是访问控制漏洞的一个子类别。 当应用程序使用用户提供的输入直接访问对象，并且攻击者可以修改输入以获得未经授权的访问时，就会发生 IDOR。 它以其在 OWASP 2007 Top 10 中的出现而得到普及，尽管它只是许多实现出错的一个例子，该错误可能导致访问控制被规避，从而实现越权。

[LAB: Insecure direct object references](https://portswigger.net/web-security/access-control/lab-insecure-direct-object-references)

> Read more
> [Insecure direct object references (IDOR)](https://portswigger.net/web-security/access-control/idor)

# Access control vulnerabilities in multi-step processes

许多网站通过一系列步骤来实现重要功能。 当需要获取各种输入或选项时，或者当用户需要在执行操作之前查看并确认详细信息时，通常会这样做。 例如，用于更新用户详细信息的管理功能可能涉及以下步骤：

1. 加载包含特定用户的详细信息的表单；
2. 提交更改；
3. 查看更改并确认。

## Procedure-based access control

有时，网站会对其中某些步骤实施严格的访问控制，而忽略其他步骤。 例如，假设第一步和第二步已经正确实行了访问控制，但第三步却没有。 实际上，该网站假定用户只有完成了具有恰当访问权限控制的第一步之后，才可以进入第 3 步。 在这里，攻击者可以跳过前两个步骤并直接使用所需参数提交对第三步的请求，从而获得未经授权的功能访问。
（实际测试时，并不知道这样，需要先过一遍步骤，记录每一步的请求包，然后自己根据数据包（请求以及相应）作出假设，并进行测试验证，是否存在这样的漏洞。）

[LAB: Multi-step process with no access control on one step](https://portswigger.net/web-security/access-control/lab-multi-step-process-with-no-access-control-on-one-step)

## Referer-based access control

某些网站的访问控制基于 HTTP 请求中提交的 Referer 头。 通常，浏览器会将 Referer 标头添加到请求中，以指示发起请求的页面。

例如，假设应用程序对 `/admin`上的主管理页面实施了很好的访问控制，但是对于子页面（例如`/admin/deleteUser`）仅检查 Referer 标头。 如果 Referer 头包含主要的 `/admin` URL，则允许该请求。

在这种情况下，由于 Referer 头可以被攻击者完全控制，因此他们可以直接伪造对敏感子页面的请求，提供所需的 Referer 头，从而获得未经授权的访问。

[LAB: Referer-based access control](https://portswigger.net/web-security/access-control/lab-referer-based-access-control)

## Location-based access control

一些网站根据用户的地理位置对资源实施访问控制。 例如，这可以适用于那些有国家法律或企业业务限制的银行应用程序或媒体服务等。 这些访问控制通常可以通过使用 Web 代理，VPN 或修改客户端地理定位机制来规避。

# How to prevent access control vulnerabilities

通常，可以采取 [纵深防御](https://www.forcepoint.com/cyber-edu/defense-depth) 方法并应用以下原则来防止访问控制漏洞：

-   不要通过隐藏来进行访问控制。
-   除非打算公开访问资源，否则默认拒绝访问。
-   尽可能使用单个应用程序范围的机制来执行访问控制。
-   在代码级别，使开发人员必须声明每个资源允许的访问权限，并默认拒绝访问。
-   彻底审核和测试访问控制，以确保它们按设计工作。

# 参考与推荐

> 1. [安全设计的一些实践](https://zhuanlan.zhihu.com/p/41377443)
> 2. 《数据安全架构设计与实战》
> 3. [权限控制的解决方式(科普向)](https://cloud.tencent.com/developer/article/1099266)
> 4. [业务逻辑漏洞探索之越权漏洞](https://cloud.tencent.com/developer/article/1367399)

# 乌云镜像

[镜像 1](http://wy.zone.ci)
[镜像 2](http://xss.one/)
[镜像 3](http://www.onebug.org)
[镜像 4](https://www.madebug.net/)
