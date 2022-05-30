---
title: 通过双系统看 EFI
comments: true
toc: true
tags:
    - os
    - efi
description: 本文通过双系统来进一步学习 efi 结构以及 UEFI 引导过程
summary: 本文通过双系统来进一步学习 efi 结构以及 UEFI 引导过程
categories:
    - os
date: 2020-09-30 20:33:55
---

## 安装系统对 UEFI 影响

Bootloader path for a permanently installed OS

When an operating system is installed permanently to a UEFI system, there is one new step that absolutely did not exist on classic BIOS. When installing the bootloader, four things are written to the NVRAM memory that holds the firmware settings:

-   Bootloader pathname on the EFI System Partition (ESP) that holds the bootloader(s)
-   the GUID of the ESP partition
-   a descriptive (human-friendly) name for this particular bootloader instance
-   optionally, some data for the bootloader

For Windows, the standard UEFI pathname for the Windows boot process will be `\EFI\Microsoft\Boot\bootmgfw.efi`, and the descriptive name will be "Windows Boot Manager". The optional data seems to contain a GUID reference to something within the Windows bootloader's BCD configuration file.

For Ubuntu, the pathname should be `\EFI\Ubuntu\grubx64.efi` if you don't need Secure Boot support, or `\EFI\Ubuntu\shimx64.efi` if the Secure Boot shim is used. The descriptive name is simply "ubuntu" and the optional data is not used.

In Ubuntu, these UEFI NVRAM boot settings can be viewed using the `sudo efibootmgr -v` command; in Windows, you can start a Command Prompt _as Administrator_ and then use the `bcdedit /enum firmware` command to view the settings.

The UEFI specification has a standard convention that each vendor should place the bootloader for a permanently installed OS within the path `\EFI\<vendor name>` on the ESP, so having multiple UEFI bootloaders co-exist on the same ESP is actually supported and should make things easier than with classic BIOS that had a single Master Boot Record per disk.

## 启动过程

### UEFI 启动流程

1. 系统开机 - 上电自检（Power On Self Test 或 POST）。
2. UEFI 固件被加载，并由它初始化启动要用的硬件。
3. 固件读取其引导管理器以确定从何处（比如，从哪个硬盘及分区）加载哪个 UEFI 应用。

    The EFI firmware has its own "boot menu", analogous to the menu presented by GRUB but at an earlier stage in the boot process. Just as GRUB lets you choose which Linux kernel to run, the EFI boot menu lets you choose which EFI boot program to run — choices being things like GRUB itself, or the Windows bootloader. (And, like GRUB's menu, the EFI boot menu is typically not shown by default; you have to press a hotkey during startup to see it.)

    The firmewire check the configuration data that's stored in the motherboard's NVRAM (the "BIOS settings" memory) for the entries in the EFI boot menu which are what we see in UEFI boot manager.

    These NVRAM boot entries are (typically) created by operating system installers. When you install an OS and it places a bootloader file in the EFI system partition, it also adds an entry to the NVRAM configuration so that the new bootloader will be available in the EFI boot menu. (In many cases, it also makes that new entry the default, so that the OS you've just installed will boot on its own without you needing to open the EFI boot menu and manually choose it.)

    Each entry holds a human-readable name (to show in the menu) and a path to a boot program in an EFI system partition, as well as a priority number that determines which entry is booted by default when you don't press the hotkey to see the menu.

4. 固件按照引导管理器中的启动项目，加载 UEFI 应用。

    1. 当选择从硬盘启动的时候，主板会去加载 `\EFI\Boot` 文件夹下的 `bootx64.efi`。

        这里可以做两个实验：

        1. 设置 boot 默认从硬盘启动

            将 `\EFI\Manjaro\grubx64.efi` 复制到 `\EFI\Boot` 重命名为 `bootx64.efi`，开机进入的是 grub

        2. 设置 boot 默认从硬盘启动

            `\EFI\Microsoft\Boot\bootmgfw.efi` 复制到 `\EFI\Boot` 重命名为 `bootx64.efi`，开机进入的是 windows

    2. 当选择从 Windows 启动的时候，主板会去加载 `\EFI\Microsoft\Boot` 文件夹下的 `bootmgfw.efi`。

        通过 `bootmgfw.efi` 文件来导入该目录下 BCD 文件，然后 BCD 文件根据自身的配置内容加载系统引导文件 `winload.efi`(对比 legacy bios 引导发现，UEFI 的引导文件 `winload.efi`,而 Legacy 的引导文件为 `winload.exe`)

    3. 当选择从 Manjaro 启动的时候，主板会去加载 `\EFI\Manjaro` 文件夹下的 `grubx64.efi`，然后进入 grub。而 grub 也是一个启动管理器，它会扫描并呈现本机的可用启动项供你选择。

5. 已启动的 UEFI 应用还可以启动其他应用（对应于 UEFI shell 或 rEFInd 之类的引导管理器的情况）或者启动内核及 initramfs（对应于 GRUB 之类引导器的情况），这取决于 UEFI 应用的配置。

### 系统引导流程

成功引导系统，需要具备以下条件：

1. UEFI 固件正常
2. UEFI 启动项对应正确的 `*.efi` 文件
3. EFI 分区存在
4. 引导器（`*.efi`）及其配置文件正常
5. 操作系统相关文件正常

满足这些条件后，系统启动的过程大致是：UEFI 根据 BootOrder 加载 EFI 分区中的某个引导器(`grubx64.efi`)，引导器加载配置文件(`grub.cfg`)呈现启动菜单(GRUB 菜单)，用户选择启动项后引导器加载操作系统内核。

装完双系统之后，在 UEFI 界面的 Boot Manager 选项那里也会添加对应的启动项，如之前的图所示。

通过 easy uefi 查看这些启动项指向的文件（Harddisk 项为空，因此没截图）：

![easy_uefi](https://raw.githubusercontent.com/violetu/blogimages/master/20200929155837.png)

## 测试与现象

下面首先看一下单/双系统的 EFI 目录结果以及一些现象，后面在启动过程详细讲述如何启动。

### Windows 单系统

Windows 启动过程中有一行：

![startup](https://raw.githubusercontent.com/violetu/blogimages/master/20200928213712.png)

说明它是根据 `bootmgfw.efi` 引导的。

#### EFI 结构

Boot 是计算机默认引导文件所在的目录，Microsoft 是微软 Windows 系统引导所在的目录。`bootmgfw.efi` 就是 windows 默认的系统引导文件

`\EFI\Boot` 文件夹：
![Boot](https://raw.githubusercontent.com/violetu/blogimages/master/20200928211725.png)

`\EFI\Microsoft\Boot` 文件夹：
![Microsoft](https://raw.githubusercontent.com/violetu/blogimages/master/20200928211833.png)

对比 `\EFI\Boot` 文件夹下的 `bootx64.efi` 与 `\EFI\Microsoft\Boot` 文件夹下的 `bootmgfw.efi` 的 SHA1：

![sha1sum](https://raw.githubusercontent.com/violetu/blogimages/master/20200928212106.png)

发现二者的 SHA1 值相同。

### 双系统

#### UEFI 的 Boot Manager 界面

安装 Manjaro GNOME Linux 之后，查看 UEFI 的 Boot Manager 界面：

1. Manjaro 启动使用的是`grubx64.efi` 引导

    ![Manjaro](https://raw.githubusercontent.com/violetu/blogimages/master/20200929100448.png)

2. Windows 启动使用 `bootmgfw.efi` 引导

    ![Windows](https://raw.githubusercontent.com/violetu/blogimages/master/20200929100607.png)

3. 硬盘启动，发现使用 Manjaro 的 Grub 界面

    ![harddisk](https://raw.githubusercontent.com/violetu/blogimages/master/20200929101035.png)

    从硬盘启动，走的是 `\EFI\Boot\bootx64.efi`，`\EFI\Boot\bootx64.efi` 指向哪个系统就走哪个系统（win 或者 Linux）。具体来说，就是你把哪个系统的引导（`bootmgfw.efi`或`grubx64.efi`）复制到这里，重命名为`bootx64.efi`，它就是对应系统的引导。

通过 DiskGenius 查看三者的引导：

对比 `\EFI\Boot` 文件夹下的 `bootx64.efi` 、 `\EFI\Microsoft\Boot` 文件夹下的 `bootmgfw.efi`、`\EFI\Manjaro` 文件夹下的 `grubx64.efi`的 SHA1：

![sha1](https://raw.githubusercontent.com/violetu/blogimages/master/20200929111326.png)

发现 `bootx64.efi` 和 `grubx64.efi` 的 SHA1 值相同。

> 补充：
> 有时候会看到 shimx64.efi， 它是 shim 引导程序（shim 用于安全启动 Secure Boot，调用 grub）。一般安装 Linux 的电脑会关闭 Secure Boot，这样 grubx64.efi 和 shimx64.efi 就没什么区别了。

#### 查看 EFI 目录结构

1. `\EFI\Booot`

    ![boot](https://raw.githubusercontent.com/violetu/blogimages/master/20200929163506.png)

2. `\EFI\Manjaro`

    ![manjaro](https://raw.githubusercontent.com/violetu/blogimages/master/20200929163543.png)

3. `\EFI\Microsoft\Boot`

    ![Microsoft](https://raw.githubusercontent.com/violetu/blogimages/master/20200929163623.png)

操作系统安装器会创建 `\EFI<distro>` 目录，把引导程序(`grubx64.efi`)放入其中，然后在 UEFI 启动管理器中创建入口点（开机不停按 ESC 键进入 UEFI 管理面板）。

Windows 安装时会首先创建自己的目录 `\EFI\Microsoft\Boot`，并在里面放置 `bootmgfw.efi`， 然后再把 `bootmgfw.efi` 拷一份到 `\EFI\Boot` 里并命名成 `bootx64.efi`，这样系统缺省就从 windows 启动了。

安装 manjaro 的时候, manjaro 也会创建 `\EFI\Manjaro` 目录，并放一个 `grubx64.efi`，然后再把 `grubx64.efi` 拷一份到 `\EFI\Boot` 里并命名成 `bootx64.efi`，因此我们先安装 Windows 再安装 Manjaro，开机启动看到的直接就是 grub 界面。

## 参考资料

> 1. [EFI system partition](https://wiki.archlinux.org/index.php/EFI_system_partition)
> 2. [Linux UEFI 与备份还原(引导修复)](https://www.jianshu.com/p/7821027cc455)
> 3. [EFI 系统引导的一些零碎知识点](https://www.cnblogs.com/feipeng8848/p/10723661.html)
> 4. [Win10+Ubuntu 双系统：UEFI+GPT 和 Legacy+MBR 引导模式](https://blog.csdn.net/li_qing_xue/article/details/79228867#commentBox)
> 5. [How do multiple boot loaders work on an EFI system partition](https://unix.stackexchange.com/questions/160500/how-do-multiple-boot-loaders-work-on-an-efi-system-partition)
