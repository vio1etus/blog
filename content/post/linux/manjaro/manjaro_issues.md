---
title: Manjaro 使用问题汇总
comments: true
toc: true
tags:
    - manjaro
description: 本文主要记录 manjaro 系统的使用过程中遇到的一些问题或者进阶的配置
summary: 本文主要记录 manjaro 系统的使用过程中遇到的一些问题或者进阶的配置
categories:
    - linux
date: 2020-07-24 10:11:25
---

## 忽略包更新

配置文件 `/etc/pacman.conf` 中的 `IgnorePkg` 那里写上你希望忽略更新的包。例如我忽略了 `xmind-zen`（因为我用的是果壳破解的，怕更新后就失效了。）

```shell
$ grep -n  "IgnorePkg" /etc/pacman.conf
28:# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
29:IgnorePkg   = xmind-zen
```

## fcitx 英文补全

1. 激活到并且进入 Fcitx 的英文输入状态,点击任意输入框. 2.按 ctrl+alt+H ,以激活 spell hint 状态. 3.输入几个英文字母,即可弹出候选单词(即自动补全功能), 可以按 alt 加数字,以选取候选单词.

2. 为了令补全功能更贴心,可以在 fcitx 设置里的找到 "English"(输入法)一栏,双击,进入可有更多设置. 比如把 "choose key modifier"由 alt 改成 none ,作用：不用按 Alt+序号，而是直接按序号即可选词。

## 桌面意外增加便签

其实这个不是 libinput-gestures 的问题。找了半天，我发现是鼠标中键触发了添加便签，而三指点击是 manjaro 自带的触摸板手势中键。于是右键桌面配置桌面 → 鼠标动作，删除中间动作即可。

## teamviewer 无法使用

显示 `Not ready. Please check your connection`

解决方法：
首次安装后，重启电脑，然后 `su root` 切换到 root 模式，命令行启动即可。

参考：[manjaro 安装 teamviewer 后无法打开](https://www.cnblogs.com/kunx/p/9158153.html)

## deepin tim 各种问题

1. manjaro kde 上 tim 卡死

    解决方案： 卸载你之前导入的 windows 的全部字体

    [manjaro kde 上不可用，启动慢+勉强启动卡死 #49](https://github.com/countstarlight/deepin-wine-tim-arch/issues/49)

    KDE 桌面目前存在不能记住密码的问题。

    我的 Manjaro KDE 只能使用 wine,不能使用 deepin-wine,一切换就卡死。

2. 字体发虚，中文方框，打不开，调 dpi 等，解决方法见：

    [在 Archlinux 及衍生发行版上运行 TIM](https://github.com/countstarlight/deepin-wine-tim-arch)

3. 图片一直加载，不显示

    [Arch || Manjaro 禁用 IPV6](https://www.4gml.com/thread-53.htm)

### kde 桌面 deepin wine 中焦点的问题

目前 manjaro kde 下 `deepin-wine-tim` 右键不能鼠标选中功能，因此复制，@，撤回，回复某个人消息都不行。

临时替代：右键之后，不要鼠标点击，而是要通过键盘上下键和回车来进行。

此解决方案来自 Arch linux QQ 群的憋憋大佬，表示感谢（虽然他可能看不见）， QQ 群号：204097403

## 字体

### manjaro 字体小

1. font 那里调 dpi
2. display 那里调 scale，konsole 打字或选中出现白线
   KDE 的 bug：不要去 `Settings -> Displays and Monitor` 那里调节系统的 DPI，否则 Konsole 就会出现斜线。

### chrome ui 字体小

首先，相关版本信息：

1. chrome 版本: Version 83.0.4103.61 (Official Build) (64-bit),
2. OS: Manjaro 20.0.1 Lysia
3. DE: KDE 5.70.0 / Plasma 5.18.5

注意: 是 chrome ui （bookmarks、address bar 等），而不是 chrome 渲染的网页，后者可以再 setting 中很容易设置。
前者的调节方法:

1. 查看一下 chrome 启动文件

    ```shell
     $ cat  /usr/bin/google-chrome-stable
     #!/bin/bash
     # Allow users to override command-line options
     if [[ -f ~/.config/chrome-flags.conf ]]; then
        CHROME_USER_FLAGS="$(cat ~/.config/chrome-flags.conf)"
     fi

     # Launch
     exec /opt/google/chrome/google-chrome $CHROME_USER_FLAGS "$@"%
    ```

    注意到: `# Allow users to override command-line options`以及下面的文件

2. 创建 `~/.config/chrome-flags.conf` 该文件，并写入 `--force-device-scale-factor=n`
   其中， `n` 由你自定义，可为小数。我设置为了 `1.2`, 你可以设置一下 n，重启 chrome，观察大小，从而确定适合你的 n 值。

参考:
[Chrome UI size & zoom levels in Ubuntu 16.04](https://superuser.com/questions/1116767/chrome-ui-size-zoom-levels-in-ubuntu-16-04)

## master pdf 中文显示，输入以及编辑中文时，空白

1. 确保安装好了常用中文字体,教程如下
   [为 Linux 发行版安装中文字体](https://blog.frytea.com/archives/296/)

2. "Tools -> Settings -> Editing"
   ![config](https://raw.githubusercontent.com/violetu/blogimages/master/20200806184959.png)

    这了这两步骤，在编辑中文的时候，就基本可以了。

3. Error "This font doesn’t contain these characters. Try choosing another font." when editing text.

    [Possible Issues with Text](https://code-industry.net/masterpdfeditor-help/possible-issues-with-text/)

## manjaro20.0 连接 eduroam wifi

配置如下：

![link_eduroam](https://raw.githubusercontent.com/violetu/blogimages/master/20200612162738.png)

然后，连接 eduroam 后，弹出一次框，再输入一次图片中 Password 对应输入的值。

参考链接：
[monash Connect to eduroam wi-fi: Linux](https://www.monash.edu/esolutions/network/connect-eduroam-linux)

## 真无线蓝牙耳机

蓝牙配对、连接成功，可是声音还是外放。重复配对、连接，偶尔蓝牙内放，但是一听歌，就又外放了。

解决：

1. [arch wiki Bluetooth](https://wiki.archlinux.org/index.php/Bluetooth#Installation)
   按照前两步安装，然后重启了蓝牙 `sudo systemctl restart bluetooth.service`， 再进行连接（如果此时正常了，就不用下一步了）

    [archlinux 蓝牙耳机没有声音](https://blog.csdn.net/weixin_30460489/article/details/101312239)
    把输出的默认流设置为蓝牙。

2. 经过第二部之后，连接上了，但是还是外放。
   解决：每次连接上蓝牙之后，再启动（即：重启）你用的音视频播放软件，如：vlc，spotify、netease 等，就可以了。

## 声音

## manjaro 没有声音了

一条命令：`systemctl --user restart pulseaudio.service`

应该是整上面的耳机配置整的，不小心把这个服务关闭了 emm

参考：

[Manjaro 没有声音(伪输出)怎么办](https://blog.csdn.net/qq_43497702/article/details/104370104)

## 声音小

在桌面右上角（仿 Mac 顶部栏）或者右下角（类 Windows 任务栏），找小喇叭

之前可以在下图箭头 1 指向的那里进入设置，然后永久设置最大音量的。最近好像升级改了，只剩下箭头 2 那里的勾选 `Raise maximum volume`，勾选后最大音量变为 150%，如图:

![20200724105146](https://raw.githubusercontent.com/violetu/blogimages/master/20200724105146.png)

[Need more volume](之前的设置方法：https://forum.manjaro.org/t/need-more-volume/57555)

## ark 解压中文乱码

Manjaro 默认安装 unar，这个工具会自动检测文件的编码，也可以通过 -e 来指定：
命令行：`unar file.zip`， 即可解压出中文文件

## NTFS 只读挂载: “Read-only file system”

Windows 未正常关闭导致的，关闭了 Manjaro, 开机进入 Windows，然后正常关机，再进入 Manjaro 即可。

## 参考资料

> 1. [Arch Linux (Manjaro) 配置与常用软件安装指南](https://blog.kaaass.net/archives/1205#toc-1)
> 2. [https://mrswolf.github.io/zh-cn/2019/05/24/manjaro%E8%B8%A9%E5%9D%91%E8%AE%B0/#rslsync](https://mrswolf.github.io/zh-cn/2019/05/24/manjaro踩坑记/#rslsync)
