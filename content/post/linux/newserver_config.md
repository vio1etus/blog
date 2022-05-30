---
title: 新服务器配置
comments: true
toc: true
tags:
description: 分配了实验室的服务器容器，记录一下配置流程。
categories:
    - linux
date: 2022-05-30 20:29:25
---

# 新服务器配置

1. 查看自己发行版与版本 `lsb_release -a`
2. 修改密码 `sudo passwd user(user 是对应的用户名)`
3. 更新系统

    ```shell
    sudo apt-get update
    sudo apt-get upgrade
    ```

4. 安装 `git wget curl tmux`等

    ```shell
    sudo apt-get install vim git wget curl tmux zip
    ```

5. 换源

6. 改 host 便于上 github

    使用 `ipaddress.com` 这个网站查找相应域名的 IP 地址，修改 HOST 文件 `sudo vim /etc/hosts`

    ```shell
    199.232.69.194 https://github.global.ssl.fastly.net
    140.82.114.4 github.com
    140.82.114.4 gist.github.com
    ```

7. 配置 git 连接 github

## 常用工具

安装 python3, python3-pip

```
sudo apt install python3.8 python3-pip
```

## 安装 zsh 和 oh-my-zsh

安装 zsh: `sudo apt install zsh`
下载 oh-my-zsh：`sh -c "$(curl --insecure -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

修改主题，增加插件

```shell
vim ~/.zshrc
# 修改 ZSH_THEME="robbyrussell" 为 ZSH_THEME="ys"
source ~/.zshrc
```

安装插件 zsh-suggestions, zsh-syntax-highlighting

```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 修改 ~/.zshrc：
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source ~/.zshrc
```

## 安装开发环境

### Python

1. 安装 miniconda

    [Installing on Linux — conda 4.13.0.post1+0adcd595 documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html)

2. 安装与使用

    [An introduction to Conda](https://astrobiomike.github.io/unix/conda-intro)

3. 安装 CUDA
   link
