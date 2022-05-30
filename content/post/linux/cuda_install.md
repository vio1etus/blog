---
title: Docker镜像 中 Cuda 安装
comments: true
toc: true
tags:
    - ml
    - cuda
description: 实验室服务器使用 docker 做虚拟化，在分得的 docker 镜像里面安装 cuda 便于跑深度学习
summary: 实验室服务器使用 docker 做虚拟化，在分得的 docker 镜像里面安装 cuda 便于跑深度学习
categories:
    - linux
date: 2022-05-29 14:48:25
---

## 选择合适的版本

1. 查看自己 Linux 发行版与版本，并记住：`lsb_release -a`
2. 查看显卡支持的最高 CUDA 版本：`nvidia-smi`，不超过左上角的就行

    注意：是否安装了 NVIDIA 显卡驱动，`nvidia-smi` 命令第一行如果显示驱动版本说明已经安装了
    由于我使用的是 docker 虚拟化出来 Ubuntu20.04 且主机已经给安装了驱动，因此，这里查看的时候显示安装了 510 版本的驱动。`NVIDIA-SMI 510.68.02 Driver Version: 510.68.02 CUDA Version: 11.6`，而正因为这个原因，我后面安装 CUDA 采用 deb 本地安装方式才一直失败，因为该安装方式 CUDA 会自动给你选择安装一个显卡驱动，导致新安装的驱动需要覆写旧的驱动的某些位置，然而虚拟镜像没有权限也不能够覆写主机的一些位置，导致一致出现了`unable to make backup link of` 的错误，导致新 driver 的某些依赖安装不上，导致一些 cuda、driver 的依赖不满足。

    这里也有个网友测试的 NVIDIA 显卡驱动与 CUDA 版本的兼容列表，可以参考
    [Ubuntu install specific old cuda drivers combo - Graphics / Linux / Linux - NVIDIA Developer Forums](https://forums.developer.nvidia.com/t/ubuntu-install-specific-old-cuda-drivers-combo/214601/5)

3. 查看你所用的机器学习框架：TensorFlow, PyTorch，Mxnet(这个属于是论文代码复现需要)

    1. pytorch

        pytorch 支持的 cuda 版本：[Start Locally | PyTorch](https://pytorch.org/get-started/locally/)，看到它支持 10.2 和 11.3，还是新的比较好，暂定 11.3

    2. TensorFlow

        由[Build from source  |  TensorFlow](https://www.tensorflow.org/install/source#gpu)可知，TensorFlow2.2.0-TensorFlow2.9.0 都支持我本机的 Python 3.8 版本，然后 CUDA 新的支持到 11.2，于是说明 11.3 应该也可以（大版本兼容）

    3. mxnet

        最近论文复现用到,由[mxnet · PyPI](https://pypi.org/project/mxnet/)和[Get Started | Apache MXNet](https://mxnet.apache.org/versions/1.9.1/get_started?platform=linux&language=python&processor=gpu&environ=pip&)得知，mxnet 最新的支持 CUDA 11.2，因此可行

最后决定安装 CUDA 11.3

## CUDA 安转

如果是本机的话，可以按照官方教程来（Ctrl+F： ubuntu）：[Installation Guide Linux :: CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
如果是已经被主机安装了 nvidia driver 的 docker 镜像来说，安装步骤如下：

安装必要的工具：

```
# system update
sudo apt-get update
sudo apt-get upgrade
# install other import packages
sudo apt-get install gcc g++ freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev
```

### 1. 安装 cuda

去官网[CUDA Toolkit 11.7 Downloads | NVIDIA Developer](https://developer.nvidia.com/cuda-downloads)下载指定版本，注意选对发行版及其版本以及 cuda 版本
我的是：linux x86_64，ubuntu20.04，runfile(local)，**安装方式注意选择 `runfile(local)`**,`deb(local)` 会给你默认安装推荐的驱动，可能（在我这里就是）与已安装的驱动冲突。我的安装链接：[CUDA Toolkit 11.3 Downloads | NVIDIA Developer](https://developer.nvidia.com/cuda-11.3.0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local)

选好后，按照指令下载安装即可。

选择 continue
![20220530194403](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220530194403.png)

手动输入 accept
![20220530194447](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220530194447.png)

**安装前取消勾选 driver（移动光标到该位置，回车）**，从而实现只安装 cuda 不安装 nvidia driver
![20220530194544](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20220530194544.png)

设置 cuda 环境变量,注意如果使用 zsh，则改成 `~/.bashrc`

```
echo 'export PATH=/usr/local/cuda-11.3/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
sudo ldconfig
```

### 2.安装 CuDNN

CuDNN 安装实际上就是下载一些库，然后复制到 CUDA 的对应位置。

进入 [cuDNN Archive | NVIDIA Developer](https://developer.nvidia.com/rdp/cudnn-archive)，选择与 CUDA 版本对应 CuDNN，我这里因为是 CUDA 11.3 因此选择最新的 cuDNN v8.4.0 (April 1st, 2022), for CUDA 11.x，然后选择 **`Local Installer for Linux x86_64 (Tar)`**

> 注意：我选择使用 Local Installer for Ubuntu20.04 x86_64 (Deb) 的时候没安装好，后面使用 tar 安装才安装好。

当你选好之后，点击应该会让你注册才能够获得下载链接，注册就好.然后安装如下：

```
# 下载 cuDNN，并解压
wget url cudnn.tar.xz
tar -xvf cudnn.tar.xz

# 复制以下文件到 cuda toolkit directory.
sudo cp -P cudnn/include/cudnn.h /usr/local/cuda-11.3/include
sudo cp -P cudnn/lib/libcudnn* /usr/local/cuda-11.3/lib64/
sudo chmod a+r /usr/local/cuda-11.3/lib64/libcudnn*
```

### 3. 安装 nccl

一些机器学习框架还需要安装 nccl，例如： Mxnet,如果未安装，则报错如下(CuDNN 类似 libcudnn)：

```shell
OSError: libnccl.so.2: cannot open shared object file: No such file or directory
```

安装步骤与 CuDNN 类似，安装链接：[NVIDIA Collective Communications Library (NCCL) Download Page | NVIDIA Developer](https://developer.nvidia.com/nccl/nccl-download)

```shell
# download
wget url
tar -xvf nccl.txz

# copy
sudo cp -P nccl/include/* /usr/local/cuda-11.3/include/
sudo cp -P nccl/lib/libnccl* /usr/local/cuda-11.3/lib64/
sudo chmod a+r /usr/local/cuda-11.3/lib64/libncc*
```

### 4. 验证安装成功

```shell
nvidia-smi
nvcc -V
```

### 5. 安装对应的机器学习框架

1. pytorch
   [Start Locally | PyTorch](https://pytorch.org/get-started/locally/)

2. mxnet

    ```shell
    conda install mxnet-cuda112
    # or
    pip install mxnet-cuda112
    ```

## 踩坑的错误

> 太长与教程无关，不用看系列

如果是主机的话，推荐安装：

```shell
## install tools for lspci, ubuntu-drivers, add-apt-repository
sudo apt install pciutils ubuntu-drivers-common software-properties-common
```

通过 ubuntu-drivers 识别推荐的驱动，并安装,看 "recommended" 那一行

```shell
$ ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
modalias : pci:v000010DEd00001C03sv00001043sd000085ABbc03sc00i00
vendor   : NVIDIA Corporation
model    : GP106 [GeForce GTX 1060 6GB]
driver   : nvidia-driver-440 - distro non-free recommended
driver   : nvidia-driver-390 - distro non-free
driver   : nvidia-driver-435 - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
```

卸载刚刚安装的显卡驱动的命令：

```shell
sudo apt remove nvidia-driver-515
sudo dpkg --configure -a
sudo apt-get -f install
sudo apt autoremove
```

### unmet dependencies 问题

原因是：主机已经安装了 nvidia 驱动，docker 镜像里面安装 cuda 的时候，会再给你安装驱动，但是权限不够，文件系统隔离 导致新驱动无法安装成功，然而其他的包已经安装了，cuda 也安装了一部分了，这就形成了 unmet dependencies。**解决办法：一行命令一起卸载**。

```shell
ubuntu@e2ac535b1b1f:~$ sudo apt install nvidia-compute-utils-515 nvidia-utils-515
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  nvidia-compute-utils-515 nvidia-utils-515
0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
45 not fully installed or removed.
Need to get 608 kB of archives.
After this operation, 1966 kB of additional disk space will be used.
Get:1 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64  nvidia-compute-utils-515 515.43.04-0ubuntu1 [271 kB]
Get:2 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64  nvidia-utils-515 515.43.04-0ubuntu1 [337 kB]
Fetched 608 kB in 1s (998 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
(Reading database ... 92572 files and directories currently installed.)
Preparing to unpack .../nvidia-compute-utils-515_515.43.04-0ubuntu1_amd64.deb ...
Unpacking nvidia-compute-utils-515 (515.43.04-0ubuntu1) ...
dpkg: error processing archive /var/cache/apt/archives/nvidia-compute-utils-515_515.43.04-0ubuntu1_amd64.deb (--unpack):
 unable to make backup link of './usr/bin/nvidia-cuda-mps-control' before installing new version: Invalid cross-device link
dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)
Preparing to unpack .../nvidia-utils-515_515.43.04-0ubuntu1_amd64.deb ...
Unpacking nvidia-utils-515 (515.43.04-0ubuntu1) ...
dpkg: error processing archive /var/cache/apt/archives/nvidia-utils-515_515.43.04-0ubuntu1_amd64.deb (--unpack):
 unable to make backup link of './usr/bin/nvidia-debugdump' before installing new version: Invalid cross-device link
dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)
Do you want to continue? [Y/n]
0% [Working]
Get:1 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64  nvidia-compute-utils-515 515.43.04-0ubuntu1 [271 kB]
Get:2 https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64  nvidia-utils-515 515.43.04-0ubuntu1 [337 kB]
Fetched 608 kB in 1s (1000 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
(Reading database ... 50%
(Reading database ... 95%
(Reading database ... 92572 files and directories currently installed.)
Preparing to unpack .../nvidia-compute-utils-515_515.43.04-0ubuntu1_amd64.deb ...
Unpacking nvidia-compute-utils-515 (515.43.04-0ubuntu1) ...
dpkg: error processing archive /var/cache/apt/archives/nvidia-compute-utils-515_515.43.04-0ubuntu1_amd64.deb (--unpack):
 unable to make backup link of './usr/bin/nvidia-cuda-mps-control' before installing new version: Invalid cross-device link
dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)

Preparing to unpack .../nvidia-utils-515_515.43.04-0ubuntu1_amd64.deb ...
Unpacking nvidia-utils-515 (515.43.04-0ubuntu1) ...

dpkg: error processing archive /var/cache/apt/archives/nvidia-utils-515_515.43.04-0ubuntu1_amd64.deb (--unpack):
 unable to make backup link of './usr/bin/nvidia-debugdump' before installing new version: Invalid cross-device link
dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)

Errors were encountered while processing:
 /var/cache/apt/archives/nvidia-compute-utils-515_515.43.04-0ubuntu1_amd64.deb
 /var/cache/apt/archives/nvidia-utils-515_515.43.04-0ubuntu1_amd64.deb


E: Sub-process /usr/bin/dpkg returned an error code (1)

ubuntu@e2ac535b1b1f:~$ sudo apt remove cuda-drivers nvidia-driver-515 cuda-drivers-515
Reading package lists... Done
Building dependency tree
Reading state information... Done
You might want to run 'apt --fix-broken install' to correct these.
The following packages have unmet dependencies:
 cuda-runtime-11-3 : Depends: cuda-drivers (>= 465.19.01) but it is not going to be installed
E: Unmet dependencies. Try 'apt --fix-broken install' with no packages (or specify a solution).
ubuntu@e2ac535b1b1f:~$ sudo apt remove cuda-drivers nvidia-driver-515 cuda-drivers-515 cuda-runtime-11-3
Reading package lists... Done
Building dependency tree
Reading state information... Done
You might want to run 'apt --fix-broken install' to correct these.
The following packages have unmet dependencies:
 cuda-11-3 : Depends: cuda-runtime-11-3 (>= 11.3.1) but it is not going to be installed
 cuda-demo-suite-11-3 : Depends: cuda-runtime-11-3 but it is not going to be installed
E: Unmet dependencies. Try 'apt --fix-broken install' with no packages (or specify a solution).
```

找了全网各种相似的问题也没找到解决方案，最后在一个兄弟的博客[NVIDIA-Driver-bug-201015 | Haulyn5 的博客](https://haulyn5.cn/2020/10/15/NVIDIA-Driver-bug-201015/)找到了。

既然无法安装完整的包，那就卸载，但是单独的卸载某个包都会出问题报错，必须将几个有问题的包一起卸载才可以。你可以输入一个，然后它又出现了包无法安装，你再添加到命令上，最后完整的命令命令：
`sudo apt remove cuda-drivers nvidia-driver-515 cuda-drivers-515 cuda-runtime-11-3 cuda-11-3 cuda-demo-suite-11-3`
执行结果：

```
A new initrd image has also been created. To revert, please regenerate your
initrd by running the following command after deleting the modprobe.d file:
`/usr/sbin/initramfs -u`

*****************************************************************************
*** Reboot your computer and verify that the NVIDIA graphics driver can   ***
*** be loaded.                                                            ***
*****************************************************************************

INFO:Enable nvidia
DEBUG:Parsing /usr/share/ubuntu-drivers-common/quirks/put_your_quirks_here
 dependency problems - leaving unconfigured
Processing triggers for mime-support (3.64ubuntu1) ...
Processing triggers for gnome-menus (3.36.0-1ubuntu1) ...
Processing triggers for libc-bin (2.31-0ubuntu9.9) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for dbus (1.12.16-2ubuntu2.2) ...
Processing triggers for desktop-file-utils (0.24-1ubuntu3) ...
Errors were encountered while processing:
 cuda-toolkit-11-3-config-common
 libnvjpeg-11-3
 libnvjpeg-dev-11-3
 cuda-cudart-11-3
 cuda-cudart-dev-11-3
 cuda-libraries-dev-11-3
 libnpp-11-3
 libcusparse-11-3
 libcurand-11-3
 cuda-visual-tools-11-3
 libcufft-11-3
 libcusparse-dev-11-3
 libcusolver-11-3
 cuda-cupti-11-3
 libcublas-11-3
 cuda-samples-11-3
 libcurand-dev-11-3
 libcublas-dev-11-3
 cuda-nvcc-11-3
 libnpp-dev-11-3
 cuda-libraries-11-3
 cuda-documentation-11-3
 cuda-compiler-11-3
 cuda-cupti-dev-11-3
 cuda-toolkit-11-3
 libcufft-dev-11-3
 libcusolver-dev-11-3
 cuda-tools-11-3
 cuda-command-line-tools-11-3
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

最后再执行以下：`sudo apt autoremove`

```
sudo apt-get install cuda=11.3.1-1 cuda-drivers=510.47.03-1
```

问题：[nvidia-docker issue](https://github.com/NVIDIA/nvidia-docker/issues/1287#issuecomment-715512118)

在 docker 状态下，主机安装了 nividia 驱动，并把 `/usr/bin/nvidia-debugdump` 等 mount 在了 docker 虚拟镜像中，因此当你尝试安装一个新的 nividia 驱动时,你不能够覆写主机的文件，创建镜像与主机之间的链接。

## 参考

1. [Ubuntu18.04 安装 cuda11.3\_努力~自律~开心的博客-CSDN 博客\_cuda11.3](https://blog.csdn.net/m0_62114628/article/details/123388758)
2. [Instructions for CUDA v11.3 and cuDNN 8.2 installation on Ubuntu 20.04 for PyTorch 1.11](https://gist.github.com/vio1etus/18485e1cff8525b923dce765a04072dd)
3. [整个过程\_MXNet GluonTS 使用报错：OSError: libnccl.so.2: cannot open shared object file: No such file or directory](https://www.songbingjia.com/nginx/show-293686.html)
4. [NVIDIA-Driver-bug-201015 | Haulyn5 的博客](https://haulyn5.cn/2020/10/15/NVIDIA-Driver-bug-201015/)
