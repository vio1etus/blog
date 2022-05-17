---
title: hexo 博客配置
comments: false
categories:
    - misc
date: 2020-03-15 15:41:45
updated: 2020-07-25 10:41:45
---

## 架构

本静态博客采用 hexo 模板 next 主题，markdown 源码及生成的 html 分别放在 Github 两个仓库。

通过 netlify 根据我写的简单脚本自动化部署操作 markdown 源码仓库，进行构建，并发布到 html 博客仓库。因此，我只需要对源码仓库的 markdown 进行编写，然后使用 git 同步仓库即可。

以下我的自动化构建脚本（仅供参考）:

```shell
#!/usr/bin/env sh
npm i
npm i -g hexo-cli
git clone --depth 1 --recursive https://github.com/violetu/hexo-theme-next themes/next
cp -r source/themes/next/* themes/next/
hexo clean
hexo g >/dev/null
hexo d
# 向 algolia 提交数据，以便搜索
export HEXO_ALGOLIA_INDEXING_KEY="a592b317037e2af5638bb820baa201e8"
hexo algolia
```

## 配置

[Hexo-NexT (v7.0+) 主题配置](https://tding.top/archives/42c38b10)
[Hexo 添加评论系统 Disqus](https://ftzzloo.com/hexo-add-disqus/)

## 新域名导致不蒜子统计数据归零

[不蒜子统计数据修改](https://tqraf.cn/2020/07/busuanzi.html)

## algolia 搜索不到东西

原因：部署脚本中忘记向 hexo 提交数据了。

解决方案: 那是因为你未能成功 hexo algolia 每次网站更新很多文章后,要及时提交数据, 即执行:

```shell
export HEXO_ALGOLIA_INDEXING_KEY=你为索引单独创建的key（不是search-only key）
hexo algolia
```

### 参考文章

[Hexo 博客指南|第十三篇:Icarus 配置 - 网站搜索插件](https://ji2xpro.github.io/ea684c22/)

## vscode 添加 hexo yaml snippet

1. 创建针对于 markdown 文件格式的 snippet

    `Ctrl+shift+p` 打开 vscode command palette，然后输入 snippet, 选择 `Preference: Configure User Snippets`并回车， 然后再输入 markdown 并回车，即可创建一个专门存放 markdown 格式文件 snippet 的 json。

2. 将我提供的 snippet 复制到大括号中，然后保存

    ```json
    "hexo yaml": {
        "prefix": "yaml",
        "body": [
            "---\ntitle: $1",
            "toc: true",
            "tags:",
            "   - $2",
            "description: $3",
            "categories:",
            "   - $4",
            "date: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND",
            "---\n"
        ],
        "description": "snippet fot hexo yaml"
    }
    ```

3. 测试

    在 markdown 的 `.md` 后缀文件中输入 `yaml`， 并按回车或者 Tab 键，即可自动替换为 snippet。

### 参考资料

[Snippets in Visual Studio Code](https://code.visualstudio.com/docs/editor/userdefinedsnippets)
