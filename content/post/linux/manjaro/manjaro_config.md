---
title: Manjaro 系统配置
comments: true
toc: true
tags:
    - configuration
    - manjaro
description: 本文主要记录 manjaro 系统的配置操作以及一些常用软件，一方面为自己以后重装参考（我可不想再重装了，哈哈），一方面也希望能他人提供一点指导与帮助。
categories:
    - linux
    - manjaro
date: 2020-07-23 14:11:25
updated: 2020-08-07 21:11:25
---

## 简介

用了 Manjaro 有半年左右了，之前用了 Ubuntu，总是讨厌它祖传的内部错误，后面装了黑苹果， 感觉也不是很好用，而且到处都是花钱的软件，有些质量还没有 Windows 上免费的好用。后面听说过 Manjaro 不错，便装上了双系统，一直用到现在，目前主力系统是 Manjaro, 需要腾讯系软件或者 Microsoft Office 时，才会切换到 Windows, 越来越感觉 Manjaro 好用了。它自带的很多软件的功能都远远超过了 Windows 自带的，而且 Linux 的桌面环境远远强于 Windows 桌面环境。

Manjaro Linux（或简称 Manjaro）是基于 Arch Linux 的 Linux 发行版。

特点：

-   对显卡驱动的兼容性极其之高，可自主选择安装开源驱动或者闭源驱动。
-   采用滚动更新（意味着用户无需通过重装系统或系统更新来更新自己的操作系统）。而且对 Arch 稳定性和激进度平衡控制极好。
-   AUR 软件仓库有着世界上最齐全的 Linux 软件
-   最强大丰富的 wiki 和活跃的社区让所有问题都可以快速得到满意的答案
-   Manjaro 提供支持的桌面环境众多，这里我选择的是一个 **Manjaro KDE**，KDE 操作界面类似 Windows 的操作界面

## 初始化配置

配置当下在国内最快的镜像源，我这边一般是清华源和阿里源比较快。

```shell
sudo pacman-mirrors -i -c China -m rank
```

不一会，它会弹窗让你选择源，你根据显示的延迟，选延迟最低的就好。

### 配置 ArchLinux 仓库源

1. 先安装一下 vim 便于后续操作

    `sudo pacman -S vim`
    如果此时安装不了，那先更新一下系统： `sudo pacman -Syyu`

2. 修改配置文件，添加使用清华源

    `sudo vim /etc/pacman.conf`
    向该文件末尾增加下面语句（ `shift+g` 跳到文件末尾， `i` `编辑，esc` 退出编辑， `shift+z` 连续两下保存退出）

    ```txt
    [archlinuxcn]
    SigLevel= TrustedOnly
    Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
    ```

3. 安装密钥

    `sudo pacman -Syu archlinuxcn-keyring`
    如果遇到了 **Unable to lock database** 错误：执行命令： `sudo rm /var/lib/pacman/db.lck`

### 更新系统

更新系统： `sudo pacman -Syyu`
让 Manjaro 使用 LocalTime，解决与 Windows 共存主板时间冲突问题： `sudo timedatectl set-local-rtc true`

## 安装配置 aur 包管理

`sudo pacman -S yay`
Yay 默认使用法国的 `aur.archlinux.org` 作为 AUR 源，可以更改为国内清华大学提供的镜像。

yay 用户执行以下命令修改 au­rurl：

`yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save`
修改的配置文件位于 `~/.config/yay/config.json`
注：这两天清华源崩了，不知道后面会不会好。

## 常用命令

安装软件：

```shell
sudo pacman -Ss string             # 在包数据库中查询软件
sudo pacman -S package_name        # 安装软件
sudo pacman -U package.tar.zx      # 从本地文件安装
sudo pacman -R package_name        # 删除单个软件
```

上述所有 pacman xxx 命令，均可替换成 yay xxx 执行

## 必备工具

`sudo pacman -S git net-tools iproute2 tree vim`

### 输入法

-   Arch based Linux 建议使用的 fcitx 框架， 因为据说开发者是 Arch Linux 用户
-   RIME 中州韵输入法是 Linux 下广受好评的中文输入法。
-   Fcitx5 目前使用很体验不错了

截止本文更新日期之际，目前较好的解决方案有两种：

1. fcitx4/fcitx5 + rime + 词库

    [我的 rime 配置](https://github.com/violetu/mybackup/tree/master/configurations/rime_config)
    除了常用词典外，我还单独将搜狗词库中与计算机，软件，网络，安全，黑客相关词汇转换添加了进去。

2. fcitx5 自带的 pingyin + 肥猫维基百万大词库（推荐）

    安装教程：[fcitx5、输入法、词库安装配置](https://violetus.life/os/manjaro/fcitx5/)

3. 其他（个人不推荐）

    1. 搜狗，主要是因为它还是基于 Qt4， bug 还有一些影响体验，还要关闭云输入解决了 CPU 飙升问题，而且还是搜狗，你懂的。

    2. 百度拼音， 今年才出，用了一段时间还行，bug 还是有一些，不过不太影响体验，不过，百度，你懂的，用着心里隔应。

有上面提到的两种仅仅使用开源软件的好的解决方案，为什么不用？它不香嘛

### 浏览器

`sudo pacman -S firefox google-chrome`

-   [ ] 待补充， Plasma integration 插件， kde 配合

### 科学上网

1. 软件安装

    shadowsocks v5，安装小飞机： `sudo pacman -S electron-ssr`
    v2ray， 我习惯使用 Qv2ray： `sudo pacman -S qv2ray`
    进阶： Qv2ray 高级路由配置 1. [高级路由设置](https://qv2ray.github.io/manual/route.html#%E5%85%A8%E5%B1%80%E8%B7%AF%E7%94%B1%E8%A7%84%E5%88%99) 2. [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat)

2. 订阅

    `electron-ssr` 只能订阅 ssr, 而 Qv2ray 不仅默认支持 v2ray 的 vmess 协议，通过插件还可以支持支持 ssr， 因此，我目前只用 qv2ray 了

### 终端代理

proxychains-ng 原理
简单的说就是这个程序 Hook 了 sockets 相关的操作，让普通程序的 sockets 数据走 SOCKS/HTTP 代理。

1. 安装

    `sudo pacman -S proxychains-ng`

2. 置代理协议与端口

    `vim /etc/proxychains.conf`
    将该文件里面的 `socks4 127.0.0.1 9095` 形式的那一行，改为 `socks5 127.0.0.1 1080` 。
    注意： `1080` 该值，应为你自己的代理软件监听代理的端口，需要自行在代理软件配置那里获得。

3. 使用

    在命令前加上 `proxychains4` 即可。
    测试命令： `proxychains4 curl www.google.com`

**Notice**：

如果你没有修改 yay 的源的话，使用 yay 下载官方仓库的东西时，可能会很慢，需要代理。但是 `yay` 由于本身原因，不支持 proxychains 代理，你可重新编译其他版本 yay 或者使用临时环境变量设置 HTTP 代理（端口同样是需要在代理软件配置那里获得）

```shell
export https_proxy="http://127.0.0.1:8888"
export http_proxy="http://127.0.0.1:8888"
```

## 编程开发

### zsh/oh-my-zsh

#### 切换 zsh

Manjaro linux 默认安装了 zsh
查看本地有哪几种 shell： `cat /etc/shells`
切换 shell 到 zsh： `chsh -s /bin/zsh`

1. 默认终端启动 zsh 需要在终端中进行配置：

    `Ctrl+Alt+t` 快捷键打开 `Konsole` ， 进入: `Settings -> configure Konsole -> Profile` ，然后右侧 `New` ，名字随意，Command 填写 `/usr/bin/zsh` ，然后 Apply， OK

#### oh-my-zsh 配置

1. 下载安装

    **注意： root 用户和普通用户需要单独安装配置，即分别切换到普通和 root 用户安装**

    ```shell
    # curl 或者是 wget，二者选其一即可
    # via curl
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # via wget
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

    # 想要卸载oh-my-zsh 输入以下命令
    uninstall_oh_my_zsh
    ```

2. 常用插件安装

    ```shell
    # 语法高亮插件 zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

    # 自动补全插件
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    ```

3. 安装完后启用插件

    `sudo vim ~/.zshrc`
    搜索到 plugins， 在括号后括号里添加安装的插件名字

    ```shell
    plugins=( git
                zsh-autosuggestions
                zsh-syntax-highlighting
                )
    ```

4. 使其在当前 shell 中生效

    `source ~/.zshrc`

### IDE/Editor

PyCharm 和 vscode

`sudo pacman -S pycharm-professional visual-studio-code-bin`

### GO

`yay -S go go-tools`

### Oracle jdk8

当然，目前大部分应用都开始使用 java 11 或者 java 13 了，但是安装教程不变，把对应包，数字等朝着改就行了（我懒得改了）.

1. 去 oracle 官网下载 tar 包， 我下载的是： `jdk-8u241-linux-x64.tar.gz`
2. 将其移动到 `~/Download` 目录下
3. 在该路径下打开终端， 输入 `yay jdk8`
4. 选择和你下载的包名一致的那个

    可以使用 `yay jdk8|grep 8u241` ， 找到他是第几个，然后在运行 `yay jdk8` ，输入序号即可。

5. 点击 jar 包，运行
    1. 配置: jar 包上，右键 open with， 在空行中输入 `java -jar`
    2. 在几乎最下方勾选 勾选框， 使得所有 jar 包都可以这样执行。

### Docset 离线文档

`yay -S zeal`

## 办公生产力

### Office

目前的 WPS 和 Libreoffice 对 msoffice 兼容还是不太行，不过，有的格式（有的文档）前者兼容好，有的后者兼容好。

1. office

    `sudo pacman -S ttf-wps-fonts wps-office`

2. Libreoffice

    `yay -S libreoffice`

3. PDF 查看编辑

    1. 自带的 PDF 查看器：Okular
    2. PDF 编辑/查看器

        Windows 下 Foxit 的企业版功能极其强大，但是 Linux 下可以比肩的几乎没有，较好的有两款：

        1. Master PDF 5.6.20 最新版本，亲测可破解

            安装： `yay -S masterpdfeditor`
            破解教程：[跨平台好用且小巧的 pdf 阅读器](https://blogs.porterpan.top/linuxPDF/)
            注意：破解前先屏蔽访问： `code-industry.net` ，屏蔽方法很多，可以写入 host 映射到 localhost, 也先对 master pdf 设置代理，然后通过 Qv2ray 路由功能屏蔽。

        2. PDF studio

            破解教程：也可以找到，我下载了一份免安装破解版的，但是忘了在哪里下载的了 emm。

### 邮件

1. thunderbird

    插件： `Lighting` 和 `Provider for Google Calendar`

2. birdtray(用来后台监控邮件消息，即时弹窗显示)

### Todoist Linux 非官方客户端

`yay -S elementary-planner-git`
[elementary-planner](https://aur.archlinux.org/packages/elementary-planner-git/) 搭配 KDE 插件 Event Calendar 搭配 Todoist, Google Calendar 同步

### 文献阅读，管理

Zotero 文献管理，copytranslator 论文翻译助手

`yay -S zotero copytranslator-appimage`

### 思维导图

Xmind ZEN 跨平台的思维导图工具

安装： `yay -S xmind-zen`
破解教程：[XMind 2020 (10.1.3) 全平台 完美破解版](https://www.ghpym.com/xmindzen.html)

### 电子书

电子书管理 calibre， 电子书阅读 foliate 或者 bookworm

`yay -S foliate calibre`

### 字典

`yay -S goldendict`

### 坚果云

`yay -S nutstore-experimental`

## 影音图像

### 影音

1. 视频

    默认的 VLC 很棒

2. 音频

    本地音乐播放器
    默认的 Cantata 作为本地音乐播放器很棒
    推荐的在线音乐播放器：
    网易云音乐： `sudo pacman -S netease-cloud-music`
    listen1： `sudo pacman -S listen1-desktop`
    Spotify： `sudo pacman -S spotify`
    目前在用 listen1 和网易云音乐（注：目前网易云的包不能搜索中文，我几乎不用搜索，所以没管它）

3. 视频录像

    `yay -S simplescreenrecorder`

### 图像

1. 图像

    1. 看图自带的 Gwenview

    2. 简单画图 KolourPaint， 类似 Microsoft Paint

        `sudo pacman -S kolourpaint`

    3. 简单修图，编辑图片 pinta

        `sudo pacman -S pinta`
        最近才下载使用 pinta，未深度使用，效果暂定

2. 截图

    自带的 Spectacle 与 Flameshot 贴图

    `yay -S flameshot`

3. 换壁纸软件

    variety 全平台最好的静态壁纸软件，没有之一
    `yay -S variety`

## KDE 环境配置

### Open Files

KDE 默认是单击打开文件，但是作为前 Windows 用户，我不是很习惯，改：

`System Settings > Workspace Behavior > General Behavior > Click Behavior > Double-Click to open files and folders(single click to select) .`

### Screen Edge

作为前 Windows 用户，极其不习惯当鼠标移动到左上角显示桌面的手势操作，关了它：

`System Settings > Workspace Behavior > Screen Edges`， 单击下图中箭头指的那个亮块（对，它是能点的，然后有菜单，选择 No action 即可）

![Screen Edges](https://raw.githubusercontent.com/violetu/blogimages/master/20200724101651.png)

### 整体字体太小

修改字体和 DPI： `System Settings > Workspace Behavior > Fonts`

我的配置如图：

![fonts](https://raw.githubusercontent.com/violetu/blogimages/master/20200724102022.png)

### Dock

`yay -S latte-dock-git`

## 其他

### virtualbox

[VirtualBox manjaro 安装](https://wiki.manjaro.org/index.php?title=Virtualbox#Install_VirtualBox)

注意以下： `linux54-virtualbox-host-modules` 中的 54 对应自己内核的数字

[VirtualBox 虚拟机全屏显示](https://blog.csdn.net/wow4464/article/details/51778449)

安装扩展支持 USB 3.0

`yay -S virtualbox-ext-oracle`

### 远程

`yay -S remmina teamviewer`

### 下载

`yay -S baidunetdisk-bin aria2 xdman`

### Tim

`yay -S deepin-wine-tim`

## 网络、安全

1. `netcat` 包含在 `nmap` 包里面
2. `dig` , `host` , `nslookup` ， `ip` （全名： `iproute2` ， 使用时直接 `ip` ）都在 `bind-tools` 包里。
3. `dsniff` ： 包含 `arpspoof` 命令
4. `fping` ， `traceroute`
5. `macchanger` ：改变 mac 地址

安装： `yay -S bind-tools fping traceroute nmap sqlmap macchanger dsniff`

### wireshark 安装

`yay -S wireshark-qt`
将用户加入 wireshark 组： `gpasswd -a username wireshark` （username 改为你的用户名）

## 参考文章

> 1. [将干净的 Manjaro 快速配置为工作环境](https://blog.triplez.cn/manjaro-quick-start/)
> 2. [Yay 使用小记](https://sshwy.gitee.io/2019/04/14/24636/)
> 3. [Manjaro 配置](https://www.cnblogs.com/tomyyyyy/p/12902714.html)
> 4. [Github proxychains-ng](https://github.com/rofl0r/proxychains-ng)
> 5. [Oh-My-Zsh 及主题、插件安装与配置](https://www.cnblogs.com/misfit/p/10694397.html)
> 6. [Manjaro Linux](https://zh.wikipedia.org/wiki/Manjaro_Linux)
> 7. [Not able to install arpspoof](https://www.edureka.co/community/37886/not-able-to-install-arpspoof)
> 8. [Manjaro 安装套路](https://zhuanlan.zhihu.com/p/65767238)
