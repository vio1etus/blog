---
title: Backup of Edge collections and Favorites
comments: true
tags:
    - misc
description: Don't trust browser， backup your important files.
summary: Don't trust browser， backup your important files.
categories:
    - misc
date: 2022-07-02 23:16:29
---

最近更新 Windows 11 尝鲜，更新前特地对 Edge 浏览器进行了同步，然而 Favorite 还是丢了，垃圾 Edge 浏览器，Windows 同步都做不好，别说跨平台了，也就 Windows 上用用。但是又习惯了 Edge 的侧边栏和 collection，所以注意时常备份这两个文件。

对于密码，我使用 LastPass 插件，跨浏览器。

Edge collections 备份：
关闭 Edge 浏览器，打开下面路径：`%userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Collections`，将 collectionsSQLite 文件备份

还原：将该文件复制到上面对应位置覆盖即可。

Edge favorite 备份：
关闭 Edge 浏览器，打开下面路径：`"%userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\"`，找到 `Bookmarks` 文件备份即可

还原：将该文件复制到上面对应位置覆盖即可。

## 参考

[Edge 集锦备份与搬移-黑暗执行绪](https://blog.darkthread.net/blog/edge-collections-backup/)
