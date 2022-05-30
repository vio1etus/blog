---
title: CMake 和 Make 编译
comments: true
toc: true
tags:
    - C++
    - CMake
    - Make
description: 在论文复现时，经常会遇到一些 C++ 的项目需要编译运行，因此这里对Make、MakeFile、CMake 等常见的编译安装进行基本的了解与学习。
summary: 在论文复现时，经常会遇到一些 C++ 的项目需要编译运行，因此这里对Make、MakeFile、CMake 等常见的编译安装进行基本的了解与学习。
categories:
    - programming
date: 2022-05-20 15:03:58
---

## Make 与 MakeFile

makefile 文件使代码编译更加便捷高效, make 程序解析 makefile 文件的指令，进行编译和链接程序。

makefile 优点：

1. 如果这个工程没有编译过，那么我们的所有 c 文件都要编译并被链接。
2. 如果这个工程的某几个 c 文件被修改，那么我们只编译被修改的 c 文件，并链接目标程序。
3. 如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的 c 文件，并链接目标程序。
4. 编译命令复杂，例如：`gcc -o hellomake hellomake.c hellofunc.c -I.`

    1. 节省重复编译时，重新输入编译命令所需的时间，尤其是要编译的源文件很多时。
    2. 如果编译命令丢失了，你就需要重新输入

MakeFile 的几个常用关键字段与知识：

1. Makefile 文件名默认的情况下，make 命令会在当前目录下按顺序找寻文件名为 “GNUmakefile”、“makefile”、“Makefile” 的文件，建议优先使用“Makefile”文件名。

    也可用别的文件名来书写 Makefile，比如 CMake 生成的 Makefile 一般为 xxx.make，注意：要指定非默认的 Makefile，使用 make 的“- f”和“--file”参数，一般如下：

    ```shell
    make
    make -f ./Makefile ./build
    make -f ./build.make ./build
    ```

2. 默认情况下，make 解析 Makefile 中第一个不以 `.` 开头的 target 作为默认编译目标

    例如：

    ```makefile
    .DEFAULT_GOAL := mytarget

    # 或
    .PHONY: default
    default: mytarget ;

    # 或
    default_target: all
    .PHONY : default_target
    ```

对于一个 C/C++ 项目，一般有着与下面类似的目录结构：

```shell
.
├── build
│   ├── a.o
│   ├── b.o
│   └── ...
├── include
│   ├── a.h
│   └── b.h
├── depends
│   ├── lib1
│   ├── lib12
│   └── ...
├── src
│   ├── a.c
│   ├── b.c
│   └── ...
├── Makefile
└── test
```

其中，test 是最后生成的可执行二进制文件，include 是头文件存放的目录，src 存放源文件，build 存放目标文件，depend 存放依赖的库，按照惯例，我们一般会将 Makefile 放在项目的根目录下。

一般将所有生成的目标文件输出到 build 目录下，这样目录就比较干净，当然也不乏将最后的二进制可执行文件生成在 build 下的，具体看 MakeFile 如何指定。

## make

make 常见用法三种：

1. `make` 寻找默认的 Makefile 进行编译，可通过 `-f` 指定 MakeFile
2. `make install` 是编译并安装
3. `make clean` 用来清除所有的目标文件，以便重编译。

linux 编译安装软件的流程如下，如果编译项目则不执行 `make install` 安装

```shell
./configure
make
make install
```

configure、make 和 make install 作用如下：

1. ./configure 是用来检测你的安装平台的目标特征的。比如它会检测你是不是有 CC 或 GCC，并不是需要 CC 或 GCC，它是个 shell 脚本。
2. make 是用来编译的，它从 Makefile 中读取指令，然后编译。
3. make install 是用来安装的（例如把 C++ 库编译安装到系统目录），它也从 Makefile 中读取指令，安装到指定的位置。

## CMake

不同平台（linux、Windows、MacOS）的编译环境是有差异的，为了应对这种差异，各平台编译所需的 MakeFile 文件也各不相同。而 cmake， 作为一个一个跨平台的安装（编译）工具，它抽象了一套上层的编译配置语法，并负责了将 Ta 针对平台进行 MakeFile 文件解释的任务。

CMake 定义了一套语法来组织 CMakeLists.txt 文件，然后通过 cmake 命令可以结合 CMakeLists.txt 文件的”配置“生成 MakeFile，然后交给 make 解析

### 外部构建

CMake 可以将将所有的编译信息有效地管理在一个文件夹下！当我们想清理编译数据时，只需要删除 build 文件夹。其生成的 MakeFile 中的变量 CMAKE_BINARY_DIR 指向 cmake 命令的根文件夹，所有二进制文件在这个文件夹里产生，一般可以在 CMake 之后查看，确定二进制文件的位置。

外部构建常规步骤：创建 build 文件夹，然后进入该文件夹，通过为 cmake 指定上层目录寻找 CMakeLists.txt, 将编译文件生成在该文件夹下。

```shell
mkdir build
cd build/
cmake ..
```

一般文件树如下：

```shell
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   │   ├── 2.8.12.2
│   │   │   ├── CMakeCCompiler.cmake
│   │   │   ├── CMakeCXXCompiler.cmake
│   │   │   ├── CMakeDetermineCompilerABI_C.bin
│   │   │   ├── CMakeDetermineCompilerABI_CXX.bin
│   │   │   ├── CMakeSystem.cmake
│   │   │   ├── CompilerIdC
│   │   │   │   ├── a.out
│   │   │   │   └── CMakeCCompilerId.c
│   │   │   └── CompilerIdCXX
│   │   │       ├── a.out
│   │   │       └── CMakeCXXCompilerId.cpp
│   │   ├── cmake.check_cache
│   │   ├── CMakeDirectoryInformation.cmake
│   │   ├── CMakeOutput.log
│   │   ├── CMakeTmp
│   │   ├── hello_cmake.dir
│   │   │   ├── build.make
│   │   │   ├── cmake_clean.cmake
│   │   │   ├── DependInfo.cmake
│   │   │   ├── depend.make
│   │   │   ├── flags.make
│   │   │   ├── link.txt
│   │   │   └── progress.make
│   │   ├── Makefile2
│   │   ├── Makefile.cmake
│   │   ├── progress.marks
│   │   └── TargetDirectories.txt
│   ├── cmake_install.cmake
│   └── Makefile
├── CMakeLists.txt
├── main.cpp
```

build 文件夹下生成了许多二进制文件，如果要从头开始重新创建 cmake 环境，只需删除构建目录 build，然后重新运行 cmake 即可。

## 参考

1. [makefile 介绍 — 跟我一起写 Makefile 1.0 文档](https://seisman.github.io/how-to-write-makefile/introduction.html)
2. [makefile - How does "make" app know default target to build if no target is specified? - Stack Overflow](https://stackoverflow.com/questions/2057689/how-does-make-app-know-default-target-to-build-if-no-target-is-specified)
3. [make 和 make install 的区别\_Linux 教程\_Linux 公社-Linux 系统门户网站](https://www.linuxidc.com/Linux/2019-08/160139.htm#:~:text=%E7%AE%80%E5%8D%95%E6%9D%A5%E8%AF%B4%EF%BC%8Cmake%20%E6%98%AF%E7%BC%96%E8%AF%91%EF%BC%8Cmake%20install%20%E6%98%AF%E5%AE%89%E8%A3%85%E3%80%82)
4. [想玩儿 github 开源，怎能对 make、cmake 一知半解？ - 简书](https://www.jianshu.com/p/5c9ffb3506c0)
5. [Makefile 将目标文件输出到指定目录 | Snow's Blog](https://xkun.me/2021/09/02/Makefile%E5%B0%86%E7%9B%AE%E6%A0%87%E6%96%87%E4%BB%B6%E8%BE%93%E5%87%BA%E5%88%B0%E6%8C%87%E5%AE%9A%E7%9B%AE%E5%BD%95/)
6. [1.1 hello-CMake · GitBook](https://sfumecjf.github.io/cmake-examples-Chinese/01-basic/1.1%20%20hello-cmake.html)
