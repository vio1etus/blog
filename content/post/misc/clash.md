---
title: Clash 使用 Tips
comments: true
tags:
    - misc
description: Some tips for Clash usage
summary: Some tips for Clash usage
categories:
    - misc
date: 2022-07-2 22:36:29
---

## 常用选项

1. 开启 General 下的 Allow LAN， Mixin， System Proxy， Start with Windows

    Allow LAN: 允许局域网联机，使用虚拟机时直接局域网代理
    Mixin： 不同协议端口混合都用一个端口

2. Pofiles 下的配置，右键选择 setting，将 Update Interval 设置为最小整数 1,

    有时候更新稍微一慢，节点就不行了，勤更新

## Clash 使用 Parser 添加自定义规则并防止更新覆盖

IEEE 有时候国内连不上，需要上外网，但是订阅的规则里面将其写为了直连，每一次更新订阅节点，我自定义规则就会被覆盖，造成规则丢失，因此找到这个方法。

1. 打开 `Setting`（设置），找到 `Profiles`（配置文件下）的 `Parsers`

    ![20220702230529](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220702230529.png)

2. 点击右侧的 `Edit`，打开编辑界面。

    ![20220702230419](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220702230419.png)

    ```
    parsers: # array
        - url: https://xxx
        yaml:
            prepend-rules:
                - DOMAIN-SUFFIX,ieee.org,DIRECT
    ```

    url：改成本人的订阅地址，如果不知道，可以直接在 Profiles 下点击当前订阅的 settings，复制其中的 URL 即可。
    prepen-rules：此处添加你的自定义规则，每一条占一行，按照（规则类型，值，代理策略）排列，使用逗号分隔。注意的是，每一行都需要以一个短横线加空格的开头，同时 注意对齐。具体的自定义规则如何书写在本文的后半部分有说明。
    编辑完成后，点击右下角保存。到 Profiles 里更新订阅，这样就可以将新的规则添加上了。可以点击 edit rules 查看规则进行验证。之后打开相应网页看是否生效。

3. 代理策略的选择

    一般情况我们使用 DIRECT，GLOBAL，REJECT。DIRECT 表示不走代理，即不通过代理节点直接连接。GLOBAL 则是走全局代理节点。REJECT 则表示禁止连接，使用 REJECT 后，将会屏蔽对应网站。

    有一些订阅还提供了很多自制的策略，可以自行尝试。使用时直接输入名字即可，中文也是支持的。

    点击 General，点击 Home Directory 下的 Open Folder，打开配置文件夹，点击 Profiles 文件夹，找到对应的 yml 文件，用记事本等软件打开，直接复制粘贴就可以啦 或者 Profiles 下点击 Edit Externally 便可以。

4. 原理介绍

    Parser 功能是配置文件进行预处理，因此，每一次更新都会执行一次 Parser，因此自定义规则会永远存在，只要你不删除 Parser。

# 参考

[Clash 使用 Parser 添加自定义规则并防止更新覆盖 - 觉今是而昨非 - Blog](https://chenjuefei.com:444/117.html)
