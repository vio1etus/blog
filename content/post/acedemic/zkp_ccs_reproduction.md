---
title: ZKDT 和 zkCNN 论文复现
comments: true
toc: true
tags:
    - ZKP
    - reproduction
    - C++
description: 记录两篇 CCS 2021 关于 zero knowledge proof 的代码复现
summary: 记录两篇 CCS 2021 关于 zero knowledge proof 的代码复现
categories:
    - acedemic
date: 2022-05-20 15:03:58
---

Ubuntu 18.04 VMWare 虚拟机

论文：

[CCS21：Zero Knowledge Proofs for Decision Tree Predictions and Accuracy | Proceedings of the 2020 ACM SIGSAC Conference on Computer and Communications Security](https://dl.acm.org/doi/10.1145/3372297.3417278)

[CCS21：zkCNN: Zero Knowledge Proofs for Convolutional Neural Network Predictions and Accuracy | Proceedings of the 2021 ACM SIGSAC Conference on Computer and Communications Security](https://dl.acm.org/doi/abs/10.1145/3460120.3485379)

## zkCNN

[TAMUCrypto/zkCNN: A GKR-based zero-knowledge proof protocol for CNN model inference.](https://github.com/TAMUCrypto/zkCNN)
一般使用了 submodules 的，使用`git clone --recurse-submodules 仓库地址` 即可，但是本文仓库设置有点小问题。

1. 下载

    由于该仓库使用了 submodule，但是其由于该仓库 .gitmodules 使用 SSH 协议指定的仓库位置，但我们显然没有被授权过，因此没有权限下载 submodules。解决办法：

    1. (推荐) 先 git clone 仓库，然后把 .gitmodules 的链接改成 HTTPS 的，然后递归初始化并更新 submodules
       推荐：递归初始化，并更新: `git submodule update --init --recursive`

        > 不推荐：`git submodule update` 只更新子项目代码，在一些旧版本没有初始化的 submodules 不会被更新

        ```shell
        git clone https://github.com/TAMUCrypto/zkCNN.git
        git submodule update --init --recursive
        ```

    2. (凑活) 只使用 git clone，直接找 submodules 的仓库门，自行下载到指定的嵌套的 submodules 文件夹位置

2. 安装缺少的依赖

    安装 GMP library

    ```shell
    sudo apt-get install libgmp3-dev
    ```

    `cmake --version` 查看版本是否满足 cmake >= 3.10，满足
    `gcc --version` 查看 gcc 版本是否支持 C++14

    > according to GCC's Standards Support page--which shows full C++14 support since GCC v5

3. 编译运行

    ```shell
    cd scripts
    chmod +777 ./*
    ./demo_lenet.sh
    ```

### 调试

CMake + VSCode 调试
配置 CMake 选择 zkCNN 主目录下的 CMakeLists.txt
先 build
配置 CMake:build Target 为想要运行的可执行文件 demo_lenet_run

## ZKDT

[TAMUCrypto/ZKDT_release](https://github.com/TAMUCrypto/ZKDT_release)，直接 git clone 即可

1. 安装缺少的包：

    ```shell
    sudo apt-get install -y libprocps-dev # libprocps
    sudo apt-get install libssl-dev # libcrypto
    sudo apt-get install pkg-config
    ```

    针对报错：

    > No Boost libraries were found. You may need to set BOOST_LIBRARYDIR to the
    > directory containing Boost libraries or BOOST_ROOT to the location of
    > Boost.

    ```shell
    sudo apt-get install libboost-all-dev
    ```

2. 编译

    ```shell
    cd ZKDT
    mkdir build && cd build && cmake ..
    make
    ```

3. 运行

    在 build 的 src 文件夹下直接运行编译生成的二进制文件即可。

    ```shell
    ./build/src/dt_batch
    ```

## 参考

1. [Git update submodules recursively - Stack Overflow](https://stackoverflow.com/questions/10168449/git-update-submodules-recursively)
2. [software installation - How to install the latest gmp library in 12.04? - Ask Ubuntu](https://askubuntu.com/questions/207724/how-to-install-the-latest-gmp-library-in-12-04)
3. [c++ - CMake is not able to find BOOST libraries - Stack Overflow](https://stackoverflow.com/questions/24173330/cmake-is-not-able-to-find-boost-libraries)
4. [C++ Standards Support in GCC - GNU Project](https://gcc.gnu.org/projects/cxx-status.html#cxx14)
