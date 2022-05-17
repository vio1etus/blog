---
title: Requests 基础
comments: true
toc: true
description: 本文简要介绍 Python 的 Requests 模块的使用
categories:
  - python
date: 2019-10-05 16:21:29
tags:
---

# Requests 入门

[官方文档](https://requests.readthedocs.io/en/master/)

问题：为什么要学习 requests，而不是 urllib？

1. Requests 的底层实现就是 urlib

2. Requests 在 python2 和 python3 中通用，方法完全一样

3. Requests 简单易用

4. Requests 能够自动帮助我们解压（gzip压缩的等）网页内容

# 安装模块

1. 使用 pip install

   pip --version	查看当前 pip 是 Python 2 的，还是 Python 3 的

   注：直接输入工具名回车，一般都是帮助信息

2. 下载压缩包，解压，使用 Python 运行 setup.py
3. 

HTTP 请求方法：

get、post、put、delete、option

```python
response = requests.get('https://www.baidu.com')
response = requests.post('https://www.baidu.com')
```

返回一个 response 对象，通过 response 对象的方法，我们可以处理响应内容。

# 属性与方法

**区分属性与方法：**

属性是名词，是对象固有的属性

方法是动词，是对象可以做的事情

## response.text

- 类型：str

- 解码类型：根据 HTTP 头部对响应的编码作出有根据的推测，推测的文本编码
  
- 如何修改编码方式：response.encoding=”gbk”
- Requests 会自动对响应正文进行解码：如果 Response.encoding 为空，那么 requests 根据 header 来确定响应的编码方式，然后进行解码。如果你可以确定响应的编码方式，也可以先对Response.encoding进行设置，然后再通过Response.text获取响应正文。

## response.content

- 类型：bytes

- 解码类型：没有指定

- 如何修改编码方式：response.content.deocde（“utf8"）

- 如果你想取文本，可以通过 r.text。 如果想取图片，文件，则可以通过 r.content。
  （ resp.json() 返回的是 json 格式数据）

  当然，由于二进制是最原始的数据，我们方便对他进行任意操作，于是常用且推荐使用: **response.content.decode()**

**requests 中解决编解码问题：**

- response.content.decode()   默认使用 utf8
- response.content.decode('gbk')
- response.text

## response.status_code 状态码

当状态码为 200 时，只能说请求某个 URL 成功了，但是不一定是我们传入的参数 URL地址。

比如：我们现在请求一个登陆之后才能访问的页面，服务器会将我们重定向到登录页面，而我们成功访问登录页面，于是返回 200.

区分 4xx or 5xx 与 200

1. 直接使用 `response.status_code` 或者 `assert resposne.status_code == 200`（需要 try except）

2. `response.raise_for_status()` raise an exception for error codes (4xx or 5xx),

很多时候我们需要请求很多网页，那么我们需要定义一个方法，专门发送请求获得相应响应，并进行异常处理。然后再在别的方法中进行处理。

## response.header 响应头

响应头，一般只关注 Set-Cookie 字段

当我们关注网站如何设置 cookie 的时候，不应该只管响应头的  Set-Cookie 字段，因为也可以通过 JS 设置 cookie 到本地，所以也要关注一下 JS。

response.request 中有着关于请求报文的信息，可以通过对应的方法获得。

response.request.header 请求头、response.request.method 请求方法

注意：

1. 如果遇到重定向，请求和响应的 URL 就会不一样。
2. requests 模块默认的 User-Agent 为 python-requests/2.22.0（版本号可略有不同），所以我们要使用它时，要单独设置 UA，否则会被立即识别为爬虫，然后返回一个与浏览器的页面不一定相同的页面。

## 发送带 header 请求

我们只需要传递一个字典形式的 header 参数即可，注意：header 需要是键值对的形式，不要只写值，不写名

```python
headers = {"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36"}
url = 'https://www.baidu.com'
response = requests.get(url, headers=headers)
```

此处，我们发送带 header 请求是为了模拟浏览器，防止被识别为爬虫。如果有一天我们单单带上 UA，还是会被识别为爬虫，那么我们就要考虑带上 headers 中别的字段值了。如果还不行，我们可以考虑 带上 cookie 

## 发送带参数的请求

比如以下 URL 中 ？后面便是参数的键值对

```html
https://www.google.com/search?q=python
```

参数形式：字典

注意：有的参数对请求内容来说是没有用的，我们要测试出那些重要的参数。

**两种方式：**

1. requests 提供的方式

   比如：https://xxx.com/search.php?key=Python&time=2018

   url = 'https://xxx.com/search.php'  # 注意：带不带问号均可，requests 会判断有无问号，然后帮我们调整，使其有一个问号。

   keyword=｛‘key’:'Python', 'time':2018｝

   requests.get(url, params=keyword)

2. 拼接字符串

   [字符串格式化](https://zhuanlan.zhihu.com/p/37936007)

   3.6 及以上建议使用：f -string，采用直接在字符串中内嵌变量的方式进行字符串格式化操作

   ```python
   param1 = 'Python'
   param2 = 2018
   url =f"https://xxx.com/search.php?key={param1}&time={param2}"
   requests.get(url)
   ```

   当然，老式的方法我们也要能看懂：

   ```pyhton
   url  ="https://xxx.com/search.php?key={}&time={}".format(param1，param2)
   url  ="https://xxx.com/search.php?key=%s&time=%d" % (param1, param2)
   ```

   **注意：编码问题**

   **如果使用 w 模式打开文件写入报错，那在打开文件时，添加 encoding 字段**

   使用 ‘wb’ 模式打开文件写入没有问题

   ```pyhton
   f = open('liyiba-'+str(i+1)+'.html','w',encoding='utf-8')
      f.write(response.content.decode())
   或
   with open(file_path, 'w', encoding='utf-8') as f:
   ```

   类的每个方法的第一个参数为指向实例的引用。在类的方法中使用类的成员或方法也要在前面加上 self.

## Post 请求

哪些地方我们会用到 POST 请求：

- 登录注册（POST比GET更安全）
- 需要传输大文本内容的时候（POST 请求对数据长度没有要求）
      所以同样的，我们的爬虫也需要在这两个地方去模拟浏览器发送 post 请求

发送POST请求用法：

`````` Python
response=requests.post("http://www.baidu.com/", data=data, headers=headers)
```

data的形式：字典
本例中通过必应翻译的例子看看 post 请求如何使用

## 代理

[反向代理为何叫反向代理？](https://www.zhihu.com/question/24723688)

[正向代理与反向代理的区别](https://www.jianshu.com/p/208c02c9dd1d)

正向代理隐藏真实客户端，反向代理隐藏真实服务端

用法：

```
requests.get（"http://www.baidu.com"，proxies=proxies）
```

proxies 的形式：字典

```
proxies = {
"http": "http://12.34.56.79:9527",
"https": "https://12.34.56.79:9527",
｝
```

问题：为什么爬虫需要使用代理？

- 让服务器以为不是同一个客户端在请求

- 防止我们的真实地址被泄露，防止被追究

获取 requests 获取本地以及远程地址：

```python
import requests
response = requests.get('https://www.baidu.com/', stream=True)
print(response.raw._connection.sock.getpeername()[0])
print(response.raw._connection.sock.getsockname()[0])
```

其实是访问偏底层的套接字，然后使用套接字的方法获取套接字的属性

> In the rare case that you’d like to get the raw socket response from the server, you can access
> r.raw. If you want to do this, make sure you set stream=True in your initial request. Once you do, you can do this

```python
>>> import requests
>>> res = requests.get('https://www.baidu.com',stream = True)
>>> res.raw._connection.sock
<ssl.SSLSocket fd=848, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=0, laddr=('113.54.192.201', 15592), raddr=('182.61.200.7', 443)>
>>> type(res.raw._connection.sock)
<class 'ssl.SSLSocket'>
>>> res.raw._connection.sock.laddr
Traceback (most recent call last):
   File "<stdin>", line 1, in <module>
AttributeError: 'SSLSocket' object has no attribute 'laddr'
>>> res.raw._connection.sock.getpeername()
('182.61.200.7', 443)
>>> res.raw._connection.sock.getsockname()
('113.54.192.201', 15592)
>>> res.content.decode()
此处省略一个html的代码
>>> res.raw._connection.sock.getsockname()
Traceback (most recent call last):
   File "<stdin>", line 1, in <module>
AttributeError: 'NoneType' object has no attribute 'sock'
```

这里不能直接访问 laddr 和 raddr，socket 没有将其暴露出来，私有属性，所以我们只能通过接口，也就是使用`getsockname()` 获得 `laddr`、 `getpeername()` 获取 `raddr`

参考：[How do I print the local and remote address and port of a connected socket?](https://stackoverflow.com/questions/41250805/how-do-i-print-the-local-and-remote-address-and-port-of-a-connected-socket)

注意：在使用过程中，如果在调用 response.raw.connection.sock.getpeername() 之前进行了例如 response.text 或 response.content 的调用，那么这时候就会报错：response.raw.connection.sock.getpeername()!

参考：[获取python requests模块请求的ip地址](https://just4fun.im/2017/08/06/%E8%8E%B7%E5%8F%96python-requests%E6%A8%A1%E5%9D%97%E8%AF%B7%E6%B1%82%E7%9A%84ip%E5%9C%B0%E5%9D%80/)


[列表推导式](https://www.runoob.com/note/15802)

[Python的各种推导式（列表推导式、字典推导式、集合推导式）](https://blog.csdn.net/yjk13703623757/article/details/79490476)

原因：

1. 简洁
2. 因为扁平设计嵌套（Python 之禅）

注意：

1. python 不同编辑器以及不同地方拷贝代码时，要注意缩进，Tab 与 空格，
2. python中出现IndentationError:unindent does not match any outer indentation level 就是因为缩进与空格的问题

## Requests 模拟登陆的三种方式

### cookie 和 session 的区别

- Cookie 数据存放在客户的浏览器上，session 数据放在服务器上。
- cookie 不是很安全，别人可以分析存放在本地的 cookie 并进行 |cookie 欺骗。
- session 会在一定时间内保存在服务器上。当访问增多，会比较占用你服务器的性能。
- 单个 cookie 保存的数据不能超过 4 K，很多浏览器都限制一个站点最多保存 20 个 cookie。

### 爬虫处理 Cookie 和 session

带上 cookie、session 的好处：能够请求到登录之后的页面

带上 cookie、session 的弊端：一套 cookie 和 session 往往和**一个用户**对应。请求太快，请求次数太多，容易被服务器识别为爬虫

**不需要 cookie 的时候尽量不去使用 cookie**， 但是为了**获取登录之后的页面**，我们必须发送带有 cookies 的请求。

####1. 携带 cookie 请求 

- 携带一堆 cookie 进行请求，把 cookie 组成 cookie 池

#### 2. 处理 cookie 、session 请求

Requests 提供了一个叫做 session 类，来实现客户端和服务端的会话保持

使用方法：

1. **实例化**一个 session 对象
2. 让 session **发送** get 或者 post 请求

```python
session=requests.session()
response=session.get(url, headers)
```

动手尝试使用 session来登录人人网:

http://www.renren.com/PLogin.do

#### 使用 requests 提供的 session 类来请求登陆之后的网站的思路

1. 实例化 session
2. 先使用 session 向登录页面的表单提交， 发送 POST 请求，登录网站，session 对象自动把 cookie 保存在 session 中
3. 再使用 session 请求登陆之后才能访问的网站，session 能够自动的携带登录成功时保存在其中的 cookie，进行请求

```
session = requests.session()
post_url = "https://www.****.com//login_check"
post_data = {"_username":"615836359@qq.com",
            "_password":"*******"}

headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36"}

# 使用 session发送 post 请求,cookie 保存在其中
session.post(post_url, data=post_data, headers=headers)

# 再使用 session 进行请求 登录之后才能访问的地址
r = session.get("https://www.***.com/my/orders", headers=headers)

# 保存页面
with open('1.html', 'w') as f:
    f.write(r.content.decode())
```

## 小结

###获取登录后的页面的三种方式

1. 实例化 session，使用 session 发送 post 请求，在使用它，获取登陆后的页面 
2. 在 headers 中添加 cookie 键，值为 cookie 字符串
3. 在请求方法中添加 cookies 参数，接收字典形式的 cookie。字典形式的 cookie 中的键是 cookie 的 name，值是 cookie 的 value

   ```
   r = requests.get(url, headers=headers, cookies=cookies)
   ```


# 补充

字典推导式：

```python
cookies = {i.split('=')[0].lstrip():i.split('=')[1] for i in cookies.split(';')}
```

注意：字典和集合都是无序的