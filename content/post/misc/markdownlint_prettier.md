---
title: VSCode 的 Markdownlint 和 Prettier 兼容
comments: true
tags:
    - vscode
description: VSCode 写 Markdown 时，无序列表总是被 Prettier 格式化为 3 个空格，但是 Markdownlint 还波浪线标出 MD030 格式错误
categories:
    - misc
date: 2022-05-21 16:06:29
---

## 问题

![20220521155853](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220521155853.png)

为了和大多数项目源码的 4 个空格的缩进兼容，一般将 Prettier 设置`prettier.tabWidth": 4`,而 Markdown 的无序列表的`- `便会被当成四个空格缩进，因此出现波浪线报错问题。

> 这个问题困扰了我许久，有时候干脆不管，今天心情不好，一定要解决它，搜了搜 prettier 怎么修改配置，搜了搜 prettier markdownlint 终于搜到了，功夫不负有心人！！！

## 解决

Markdownlint 提出对 Markdownlint 增加如下配置:

```json
"markdownlint.config": {
    "MD007": {
        "indent": 4
    },
    "MD030": {
        "ul_single": 3,
        "ul_multi": 3
    }
}
```

> 看着没有波浪线提醒的 Markdown 博文，一个字，就是爽！！！

## 参考

1. [markdownlint/Prettier.md at main · DavidAnson/markdownlint](https://github.com/DavidAnson/markdownlint/blob/main/doc/Prettier.md?plain=1)
