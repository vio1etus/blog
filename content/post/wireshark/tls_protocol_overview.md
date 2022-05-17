---
title: 从数据包看 TLS 1.2
toc: true
tags:
    - 网络协议
description: 本文介绍了 TLS1.2 协议，重点讲述了其握手协议
categories:
    - wireshark
date: 2019-07-09 19:25:43
---

TLS（Transport Layer Security）和它的上一代 SSL（Secure Sockets Layer）都用来提供网络通信安全的加密协议，其中 SSL 如今已经不被推荐使用。这些协议的一些版本在 web 浏览器、电子邮件、即时通讯以及 IP 电话等方面被广泛地使用着。

TLS（Transport Layer Security）协议是 Web 上最流行的加密协议，它通过确保浏览器与服务端之间的保密性以及数据的完整性来保护 Web 上的用户。在本文中，我将介绍 TLS 1.2 版本中握手阶段(子协议)的细节。

TLS 1.2 中所有与握手相关的子协议都在 [RFC 5246](https://www.ietf.org/rfc/rfc5246.txt)被定义，下面我将通过 Wireshark 抓包的方式进行讲解

# 一. 作用

不使用 SSL/TLS 的 HTTP 通信，就是不加密的通信。所有信息明文传播，带来了三大风险。

> （1） **窃听风险**（eavesdropping）：第三方可以获知通信内容。
>
> （2） **篡改风险**（tampering）：第三方可以修改通信内容。
>
> （3） **冒充风险**（pretending）：第三方可以冒充他人身份参与通信。

SSL/TLS 协议是为了解决这三大风险而设计的，希望达到：

> （1） 所有信息都是**加密传播**，第三方无法窃听。
>
> （2） 具有**校验机制**，一旦被篡改，通信双方会立刻发现。
>
> （3） 配备**身份证书**，防止身份被冒充。

互联网是开放环境，通信双方都是未知身份，这为协议的设计带来了很大的难度。而且，协议还必须能够经受所有匪夷所思的攻击，这使得 SSL/TLS 协议变得异常复杂。

二、历史

互联网加密通信协议的历史，几乎与互联网一样长。

> 1994 年，NetScape 公司设计了 SSL 协议（Secure Sockets Layer）的 1.0 版，但是未发布。
>
> 1995 年，NetScape 公司发布 SSL 2.0 版，很快发现有严重漏洞。
>
> 1996 年，SSL 3.0 版问世，得到大规模应用。
>
> 1999 年，互联网标准化组织 ISOC 接替 NetScape 公司，发布了 SSL 的升级版[TLS](http://en.wikipedia.org/wiki/Secure_Sockets_Layer) 1.0 版。
>
> 2006 年和 2008 年，TLS 进行了两次升级，分别为 TLS 1.1 版和 TLS 1.2 版。最新的变动是 2011 年 TLS 1.2 的[修订版](http://tools.ietf.org/html/rfc6176)。

目前，应用最广泛的是 TLS 1.2，主流浏览器都已经实现了 TLS 1.2 的支持。

## 三、基本的运行过程

SSL / TLS 协议的基本思路是采用[公钥加密法](http://en.wikipedia.org/wiki/Public-key_cryptography)，也就是说，客户端先向服务器端索要公钥，然后用公钥加密信息，服务器收到密文后，用自己的私钥解密。

但是，这里有两个问题。

**（1）如何保证公钥不被篡改？**

> 解决方法：将公钥放在[数字证书](http://en.wikipedia.org/wiki/Digital_certificate)中。只要证书是可信的，公钥就是可信的。

**（2）公钥加密计算量太大，如何减少耗用的时间？**

> 解决方法：每一次对话（session），客户端和服务器端都生成一个"对话密钥"（session key），用它来加密信息。由于"对话密钥"是对称加密，所以运算速度非常快，而服务器公钥只用于加密"对话密钥"本身，这样就减少了加密运算的消耗时间。

因此，SSL/TLS 协议的基本过程是这样的：

> （1） 客户端向服务器端索要并验证公钥。
>
> （2） 双方协商生成"对话密钥"。
>
> （3） 双方采用"对话密钥"进行加密通信。

上面过程的前两步，又称为"握手阶段"（handshake），握手阶段使用非对称加密算法，通信阶段使用对称算法。

# 抓包

1. 打开 Wireshark 进行抓包

2. 定位对应网站数据包，两个方法

    1. ctrl + f ，在捕获过滤器下面出现一个搜索栏，第一个下拉列表选择 “分组详情” ，最后一个下拉列表选择 “字符串”，搜索你访问的网站的域名，比如: baidu,这样就能定位数据报，也就能定位到其 IP 地址了。

        这样做可行的原因是：在 TLS/SSL 握手的时候，Client Hello 报文中会包含服务器的域名。

    2. 打开浏览器，按 F12，调出开发者工具，选中 network 一栏，然后访问一个国内（不用翻墙的网站）的使用 HTTPS 的网站，待网页加载完毕。然后在开发者工具中找到网站主页，查看此次访问的 IP。

3) 在显示过滤器中输入: ip.addr == 你访问的 ip && ssl

    更精确的话，可以输入：ip.addr == 你访问的 ip && tls.handshake

对应方法 b 有两个注意点：

1. 为什么要在开发者工具里面实时看 IP，而不直接 ping 呢？因为现在稍微大一点网站一个域名对应一个主机集群，并不仅仅只是一个主机（IP），所以，即使你在打开网页的同时去在 cmd 里面 ping 该域名，你 ping 出来的 IP 也不一定是你刚才访问的 IP。

2. 为什么要访问不翻墙的网站呢?

    其实你一看开发者工具就知道了，比如你使用 Shadowsocks，那么你访问需要翻墙的网站时，在开发者工具里面看到的地址是：127.0.0.0.1:1080. 这样，还是找不到 IP 呀。

注：

1. 上面找 IP 的方法是为了能够找到自己访问的特定网站的数据报所提供，如果你不想找特定网站，那么直接使用显示过滤语法：ssl 或者 tls.handshake 即可
2. 本来想放到后面说，但是还是在前面说的，免得你发现自己的包与我的讲解不太相符。要知道即使都是 TLS 1.2 在执行过程中也会有些许不一样（我猜的，因为我自己抓的和网上找的 2018 年的一个抓包文件，都是 TLS 1.2 但有些小差异，也有可能是小版本改动）。此外，你要是都不是 TLS 1.2，那就更不一样了，不过，大体步骤顺序是一样的，原理一样。

相关知识：

> 一个域名用 dns 解析到多台服务器，服务器如果做了负载冗余，那么其中一个 ip 的服务器宕机了的话，另外一个立马补上而用户去察觉不到
> 冗余：起到的作用是在你主备服务器的主机宕机之后，立刻启动备机防止应用不能访问，提供 24 小时不间断服务。负载是在一个服务器组中做均衡，提高服务器组的总体运行安全度。这点负载与冗余有很大的相似处。

先放两个图，下面使用一张图来讲解。

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/icourse_tls.png)

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/tls.png)

# 原理步骤

![](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/tls_handshake.png)

"握手阶段"涉及四次通信，我们一个个来看。需要注意的是，"握手阶段"的所有通信都是明文的。

## **Client Hello**

![client hello](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/client_hello_proc.jpg)

客户端发送 “Client Hello” 报文给服务端

如果客户端（ Web 浏览器或 手机应用）发起一个 TLS 握手，它将会在 “Client Hello” 报文中发送下列重要的参数：

-   随机字节：客户端使用一个安全的随机数产生器产生随机字节。随机数生成的熵源将取决于操作系统和客户端软件的实现，稍后参与生成 “对话密钥”

-   会话 ID：如果客户端与服务端在过去建立过一个 TLS 会话，该标识符便可以具有先前的会话 ID 值，如截图所示，其可以用于更新该会话的加密参数。对于新会话，此字段为空白，这里涉及会话复用知识，会考虑再加一篇文章或给出参考资料。

-   加密套件列表：客户端还会根据它的偏好发送一个它支持的加密套件列表，在此图中，客户端最钟情的加密套件是 TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256，然而，我们可以看到服务端选择了第二个套件（在下一步中可以看到），这一长串的加密名字表示什么呢？以 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 为例，如下图所示：

    ![img](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/format.png)

    密钥交换使用 ECDHE 算法，服务身份验证使用 RSA 算法，数据传输加密使用 AES（+GCM），握手使用 SHA256 检验。

    换句话说，证书签名使用 RSA，如果证书验证正确，那么将使用 ECDHE 算法进行密钥交换，保证浏览器和服务拥有相同的私有密钥，然后一方使用这把密钥进行 AES 数据加密，另一方使用相同的密钥进行 AES 数据解密。验证证书签名合法性和密钥交换的身份确认都是使用 SHA256 这个哈希算法进行检验。具体过程下文展开描述。

-   Compression Method 压缩方式，可以展开下拉列表，默认是 null。0，即：不使用压缩。

-   下面我们可以看一看 Extension

    1. Reserverd 是保留
    2. server_name 服务器名，可以下拉列表展开，这里可以看到，我是抓的包的服务端是 www.icourse163.org，就是中国大学 MOOC。
    3. session_ticket 会话票据，客户端发起 client hello，Extention 中带上空的 session ticket TLS，表明自己支持 session ticket。
    4. supported_version 包含 Client 支持的 TLS 协议版本。
    5. 以后有重要的再补充

## Server Hello

![server hello](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/serverhello_proc.jpg)

“Server Hello” 报文是用来回应 “Client Hello” 报文的。

服务器收到客户端请求后，向客户端发出回应，这叫做 ServerHello 。服务器从收到的客户端请求的加密方法列表选择一组它支持的加密方法，如果该列表中不包括服务器认可、支持或想要使用的加密方法组，那么服务器将会忽略这些密文，如果服务器找不到自己支持的加密组，那么它将发送失败警告并关闭连接。

服务器的回应内容包括以下内容

-   随机数：服务端生成一个与客户端独立（无关）的随机数，稍后参与生成 “对话密钥”
-   加密通信协议版本和加密套件：如果浏览器与服务器支持的版本不一致，服务器关闭加密通信。在本次抓包中，服务端选择了客户端第二偏好的加密套件：`TLS 1.2 with TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`.
-   Session ID : 这里返回的 session ID 为 0，即：服务器没有进行会话复用。原因是因为服务器会话老化了，服务期开启了新的会话，新的会话的会话 ID 为 0
-   带有证书链的服务器证书（客户端信任库中存储的证书将验证该证书链）

除了上面这些信息，如果服务器需要确认客户端的身份，就会再包含一项请求，要求客户端提供"客户端证书"，比如，金融机构往往只允许认证客户连入自己的网络，就会向正式客户提供 USB 密钥，里面就包含了一张客户端证书。

## Server Certificate

在 “server hello” 完成之后，服务端必须发送能够被浏览器或移动设备的根 CA 验证的证书或证书链，根据上面显示的数字，这些证书是被 www.icouse163.com 服务器发送的。（客户端收到服务器回应以后，首先验证服务器证书。如果证书不是可信机构颁布、或者证书中的域名与实际域名不一致、或者证书已经过期，就会向访问者显示一个警告，由其选择是否还要继续通信。）

![Certificate](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/cert.png)

CA（_certification authority_）是以构建在公钥基础设施 PKI（public key infrastructure）基础之上的产生和确定数字证书的第三方可信机构（trusted third party）。在这里，我将简要介绍一下当浏览器收到服务端的证书时发生了些什么。基于 PKI 的 CA 和 TLS 协议结合起来能提供很好的安全性。 要知道，我们对根证书有无条件的信任。注意下面一段的内容并不属于 TLS 协议的一部分。

“加密”字段实际上是与第一个证书相关联的数字签名。“encrypted”字段上方的“algorithmIdentifier”字段表示 sha256WithRSAEncryption 。这意味着第一个证书的 SHA-256 哈希值是使用上面的证书颁发机构的 RSA（私有）密钥签名的。
浏览器使用证书中与之相对应的公钥来验证签名。继续相同的验证步骤，直到 CA 证书正好位于根 CA 之下。根 CA 证书不需要验证，因为它由浏览器隐式信任。
请注意，“algorithmIdentifier” 值与前面描述的“密码套件不相关。
现在，在此消息中突出显示一个字段非常重要。嵌入在证书链中第一个证书中的公钥如下图所示：

![www.icourse163.com 在第一个证书中的公钥](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/rsa_pukey.png)

此证书包含 www.icourse163.com 服务器的 RSA 公钥（以及相关的数学参数），因为服务器选择了包含 RSA 作为数字签名算法的密码套件。该公钥将在握手的后续步骤中用于数字签名。

## Server Key Exchange & Server Hello Done

![server_exchage](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/server_exchage.png)

服务器在 “server key exchange message” 消息中发送它的参数

握手协议的下一步是交换用于生成对称密钥的参数以加密所有未来的应用程序数据。
当服务器和客户端同意使用 Elliptic Curve Diffie-Hellman Ephemeral（ECDHE）时，他们需要交换 ECDHE 算法中使用的公共参数。加密细节超出了这里的范围。
但是，请注意此处发送的三个突出显示的值：

-   命名曲线：服务器为计算选择的椭圆曲线。
-   公钥：客户端使用的服务器的公共组件。
-   签名：使用服务器的私有 RSA 密钥对值进行签名，以便客户端可以验证（使用证书中的相应公钥）ECDHE 参数确实来自与其通信的服务器而不是攻击者。

“Server Hello done” 意味着 “Server Hello” 报文的结束

## Client Key Exchange / Change Cipher Spec /Encrypted handshake

![key_change](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/blog/BlogPic/wireshark/%E8%BF%9B%E9%98%B6/key_change.png)

**Client Key Exchange**

“Client Key Exchange” 包含客户端的供 ECDHE 使用的公共参数，在这种情况下，客户端参数并未签名。

现在，在我们查看上面屏幕截图中的其他消息之前，让我们先看看客户端和服务器如何生成密钥（称为主密钥）。

根据 8.1 RFC 5246，master_secret 的公式如下：

```
master_secret = PRF(pre_master_secret, "master secret",   ClientHello.random + ServerHello.random)
```

上面提到的* pre_master_secret *实际上是服务器和客户端使用 ECDHE 算法计算的密钥。伪随机函数（PRF）实际上是 HMAC-SHA256。 ClientHello.random 和 ServerHello.random 是在初始 hello 消息期间分别由客户端和服务器生成和交换的随机值。字符串 “master secret” 也用在 PRF 中。 master_secret 长 48 个字节。

至于为什么一定要用三个随机数，来生成"会话密钥"，[dog250](http://blog.csdn.net/dog250/article/details/5717162)解释得很好：

> "不管是客户端还是服务器，都需要随机数，这样生成的密钥才不会每次都一样。由于 SSL 协议中证书是静态的，因此十分有必要引入一种随机因素来保证协商出来的密钥的随机性。
>
> 对于 RSA 密钥交换算法来说，pre-master-key 本身就是一个随机数，再加上 hello 消息中的随机，三个随机数通过一个密钥导出器最终导出一个对称密钥。
>
> pre master 的存在在于 SSL 协议不信任每个主机都能产生完全随机的随机数，如果随机数不随机，那么 pre master secret 就有可能被猜出来，那么仅适用 pre master secret 作为密钥就不合适了，因此必须引入新的随机因素，那么客户端和服务器加上 pre master secret 三个随机数一同生成的密钥就不容易被猜出了，一个伪随机可能完全不随机，可是是三个伪随机就十分接近随机了，每增加一个自由度，随机性增加的可不是一。"

此时，重要的是指出一个在 TLS 记录协议中执行关于 master_secret 的操作。
TLS 记录协议是一个单独的子协议，用于实际加密和传输高级协议数据，如 HTTP。使用 TLS 记录协议中的 PRF 将主密钥“扩展”为更多秘密。
从 master_secret 派生的密钥在 RFC 规范的[section 6.3](https://tools.ietf.org/html/rfc5246#section-6.3)中命名如下：

```http
client_write_MAC_key[SecurityParameters.mac_key_length]   server_write_MAC_key[SecurityParameters.mac_key_length]   client_write_key[SecurityParameters.enc_key_length]      server_write_key[SecurityParameters.enc_key_length]      client_write_IV[SecurityParameters.fixed_iv_length]      server_write_IV[SecurityParameters.fixed_iv_length]
```

可以猜测，“写密钥”用于加密数据。 “写 MAC” 密钥用于计算应用级数据的 MAC。仅在密码套件需要时才计算初始化向量（IV）。由于客户端和服务器都具有所有这些密钥，因此它们可以解密并验证消息的完整性。

**Change Cipher Spec**

Change Cipher Spec 是 TLS 中的一个单独的子协议，用于指示 TLS 协商中的任何一方将使用协商的密钥和算法加密后续消息。

**Encrypted Handshake Message (Finished Message)**

你们中的一些人可能想知道握手消息中中间人攻击（Man-In-The-Middle ）的可能性。例如，如果攻击者改变客户端发送的密码套件列表以使服务器选择相对较弱的密码套件，该怎么办？
TLS 协议确实使用 Finished Message 来防止 MITM 攻击，它在 Change Cipher Spec 消息之后发送。
屏幕截图中的“加密握手消息”将是一个 HMAC-SHA256 。他有下列属性

1. 有着 主密钥（master_secret）
2. 所有先前握手消息的哈希值（从 ClientHello 到 Finished Message ，不包括此 Finished Message ）
3. 结束标志字符串（客户端消息为“client finished”，服务器消息为“server finished”）

```
verify_data
			PRF(master_secret, finished_label, Hash(handshake_messages))(quoted from section 7.4.9 of RFC 5246)
```

如果服务器或客户端无法验证握手消息的完整性，则 TLS 握手失败。

## Encrypted Application Data

在握手完成后，传送加密的数据。

-   MAC-then-Encrypt：在明文上计算 MAC，将其附加到数据，然后加密整个（这就是[TLS](http://tools.ietf.org/html/rfc5246)所做的）
-   加密和 MAC：在明文上计算 MAC，加密明文，然后将 MAC 附加到密文的末尾（这就是 SSH 所做的）
-   Encrypt-then-MAC：加密明文，然后在密文上计算 MAC，并将其附加到密文（在这种情况下，我们不要忘记将初始化矢量（IV）和加密方法标识符包含在 MACed 数据中）

前两个选项通常称为“MAC-then-encrypt”，而第三个选项则是“encrypt-then-MAC”。

直到 TLS 1.2，“MAC-then-Encrypt” 技术仍然用来从上层（ TLS record 协议）加密和保证数据的完整性。首先，使用 客户端的 client_write_MAC_key 或 服务端的 server_write_MAC_key 来创建消息的 MAC，然后明文数据和 MAC 被客户端使用 client_write_key 和服务端使用 server_write_key 各自加密。

参考资料

> 1. [RFC 5246](https://www.ietf.org/rfc/rfc5246.txt)
> 2. [TLS/SSL 会话复用](https://blog.csdn.net/mrpre/article/details/77868669)
> 3. [TLS 1.2 hand shake](https://medium.com/@ethicalevil/tls-handshake-protocol-overview-a39e8eee2cf5)
