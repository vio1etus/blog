#!/usr/bin/env sh
npm i
npm i -g hexo-cli
git clone --depth 1 --recursive https://github.com/violetu/hexo-theme-next themes/next
#cp -r source/images/* themes/next/source/images/
cp -r source/themes/next/* themes/next/
hexo clean
hexo g >/dev/null
hexo d
# 向 algolia 提交数据，以便搜索
export HEXO_ALGOLIA_INDEXING_KEY="a592b317037e2af5638bb820baa201e8"
hexo algolia
