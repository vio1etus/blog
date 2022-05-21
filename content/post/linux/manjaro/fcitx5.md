---
title: fcitx5、输入法、词库安装配置
comments: true
toc: true
tags:
    - manjaro
description: fcitx5 框架，pinyin 输入法、rime 输入法，肥猫的维基百万词库以及fcitx5-rime 配置
categories:
    - linux
date: 2020-08-07 20:11:25
---

## 卸载 Fcitx4

首先把卸载系统中 fcitx4 相关包:

`sudo pacman -Rs $(pacman -Qsq fcitx)`

## 安装 fcitx5

以下安装二选一，切忌带 `-git` 后缀的和不带 `-git` 的包一起安装（当然，一些词库啥的没事）。

稳健安装（安装 community 源的 fcitx5）：

`sudo pacman -S fcitx5-chinese-addons fcitx5 fcitx5-gtk fcitx5-qt kcm-fcitx5`

注意：`kcm-fcitx5` 为 KDE 桌面的图形化配置 fcitx5 包。

激进安装（archlinuxcn 源的 fcitx5）:

`yay -S fcitx5-chinese-addons-git fcitx5-configtool-git fcitx5-git fcitx5-gtk-git fcitx5-qt5-git fcitx5-pinyin-zhwiki`

fcitx5: 输入法基础框架主程序
fcitx5-chinese-addons: 简体中文输入的支持，云拼音
fcitx5-gtk: GTK 程序的支持
fcitx5-qt: QT5 程序的支持
fcitx5-pinyin-zhwiki: 肥猫制作的维基百万词库，没有版权风险, 放心使用
kcm-fcitx5: KDE 桌面环境的支持，最近换为了 `fcitx5-configtool-git`， manjaro 还没更新到，不过可以手动安装。

## 设置 Fcitx5 初始配置

配置 Group
直接启动 fcitx5 是只有西文键盘的，如果是 KDE，可以到系统的输入法配置启用拼音。如果是别的桌面的话，把下面的内容粘贴到 `~/.config/fcitx5/profile`

```
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=pinyin

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=pinyin
# Layout
Layout=

[GroupOrder]
0=Default
```

`DefaultIM=xx` 为设置默认输入法，如果你习惯使用 rime,后面安装好之后可以设置成 rime。

配置文件在注销重新登陆之后就会生效，届时启动 fcitx5 即可体验。

### 配置环境变量

修改 `~/.pam_environment`，添加如下内容：

```
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS="@im=fcitx5"
```

使用 `echo ${XDG_SESSION_TYPE}` 命令查看，如果是 x11 用户，则还应当在`~/.xprofile` 添加如下内容：`fcitx5 &`

## fcitx5-rime

`sudo pacman -S fcitx5-rime fcitx5-pinyin-zhwiki-rime` 或者
`yay -S fcitx5-rime-git fcitx5-pinyin-zhwiki-rime`

新版兼容旧版配置，可以直接使用命令复制配置与词库：
`cp -r ~/.config/fcitx/rime ~/.local/share/fcitx5/rime`

## 个性化

### 关闭云拼音

修改 `~/.config/fcitx5/conf/pinyin.conf`：

```
# Enable Cloud Pinyin
CloudPinyinEnabled=False
```

### 关闭自动 DPI

fcitx5 会自动根据多显示器不同的 DPI 来调整界面大小，但可能会造成了一些困扰，将这一功能关闭，并调整字体大小为 14。

修改`~/.config/fcitx5/conf/classicui.conf`

```
# 按屏幕 DPI 使用
PerScreenDPI=False

# Font (设置成你喜欢的字体)
Font="Noto Sans Regular 14"
```

### 自定义快速输入

```
#在 fcitx5 数据文件夹建立 mb 文件
sudo touch /usr/share/fcitx5/data/quickphrase.d/quick.mb
# 使用 vim 编辑自定义输入
sudo vim /usr/share/fcitx5/data/quickphrase.d/quick.mb

```

在文件中添加形如`input output`的代码，一行一条，即可实现添加快速输入辞典。

示例：要在快速输入中输入`eg`，在候选中显示`e.g.`，只需在上述 mb 文件中添加一行`eg e.g.`即可。

_友情提示：快速输入可以使用分号打开，Rime 不支持快速输入。_

## 皮肤

[fcitx5-dark-transparent](https://github.com/hosxy/fcitx5-dark-transparent)

### 用单行模式(inline_preedit)

上图就是单行模式，非常好看，推荐开启

对于 fcitx5 自带 pinyin 请修改 `~/.config/fcitx5/conf/pinyin.conf`

对于 fcitx5-rime，请新建/修改 `~/.config/fcitx5/conf/rime.conf`

加入/修改以下内容：

```
# 可用时在应用程序中显示预编辑文本
PreeditInApplication=True
```

> 输入法配置完成后，如果没有达到应该达到的效果，建议先重启 fcitx5 或者 logout 或者重启电脑，以便配置生效。

## 参考教程

> 1. [在 Manjaro 上优雅地使用 Fcitx5 含 fcitx5+rime](https://www.wannaexpresso.com/2020/03/26/fcitx5/)
> 2. [配置 Fcitx5 输入法, 肥猫百万词库就是赞](https://manateelazycat.github.io/linux/2020/06/19/fcitx5-is-awesome.html)
> 3. [fcitx5-dark-transparent](https://github.com/hosxy/fcitx5-dark-transparent)
