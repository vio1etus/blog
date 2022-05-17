---
title: EFI 初识
comments: true
toc: true
tags:
    - os
    - efi
description: 本文主要介绍 EFI 的结构以及各个 efi 文件功能等理论知识，为后面双系统测试实践打下理论基础。
categories:
    - os
date: 2020-09-30 20:33:55
---

UEFI+GPT 的结构的分区样子是：

![partition](https://raw.githubusercontent.com/violetu/blogimages/master/20200929165639.png)

三个分区：恢复分区、ESP（一般为 FAT32 隐藏分区）、MSR 分区（没什么用，不用管）

## EFI

The EFI system partition (also called ESP) is an OS independent partition that acts as the storage place for the EFI bootloaders, applications and drivers to be launched by the UEFI firmware. It is mandatory for UEFI boot. 其中 Boot Loader 是在操作系统内核运行之前运行的一段小程序。这段小程序可以将系统的软硬件环境带到一个合适的状态，以便为最终调用操作系统内核准备好正确的环境。

EFI 系统分区,带有 efi、boot 标志标记，因此 ESP 不再限制必须要放在开头的第一个分区里面，它可以在整块硬盘的任意一个分区位置。扫描寻找 ESP 的时候是从前向后扫描，因此默认情况下最先找到的是硬盘中靠前的 ESP，并对其中的 efi 进行加载。

The UEFI specification mandates support for the FAT12, FAT16, and FAT32 file systems, but any conformant vendor can optionally add support for additional file systems; for example, the firmware in Apple Macs supports the HFS+ file system.

通常情况下，ESP 的大小至少为 100 MB，文件系统格式为 FAT-12/16/32。实际情况下，ESP 一般设置为 100MB 的 FAT32 分区。在 Linux 上一般将其挂载到 `/boot/efi`。为了确认它是否是 ESP,可以挂载，然后检查它是否包含名为 EFI 的目录，如果包含，则为 ESP。

Win+Linux 双系统 ESP（The EFI system partition）文件结构：

> 其中`***`表示多行类似文件，我手动改的，因为行数太多了

```txt
├── Boot
│   └── bootx64.efi
├── EFI.txt
├── Manjaro
│   └── grubx64.efi
└── Microsoft
    ├── Boot
    │   ├── BCD
    │   ├── BCD.LOG
    │   ├── BCD.LOG1
    │   ├── BCD.LOG2
    │   ├── bootmgfw.efi
    │   ├── bootmgr.efi
    │   ├── BOOTSTAT.DAT
    │   ├── boot.stl
    │   ├── en-US
    │   │   ├── bootmgfw.efi.mui
    │   │   ├── bootmgr.efi.mui
    │   │   └── memtest.efi.mui
    │   ├── Fonts
    │   │   ├── chs_boot.ttf
    │   │   ├── ××××××××
    │   │   └── wgl4_boot.ttf
    │   ├── kd_02_10df.dll
    │   ├── ××××××××
    │   ├── kdstub.dll
    │   ├── memtest.efi
    │   ├── qps-ploc
    │   │   └── memtest.efi.mui
    │   ├── Resources
    │   │   ├── bootres.dll
    │   │   ├── en-US
    │   │   │   └── bootres.dll.mui
    │   │   └── zh-CN
    │   │       └── bootres.dll.mui
    │   ├── winsipolicy.p7b
    │   ├── zh-CN
    │   │   ├── bootmgfw.efi.mui
    │   │   ├── bootmgr.efi.mui
    │   │   └── memtest.efi.mui
    │   └── zh-TW
    │       ├── bootmgfw.efi.mui
    │       ├── bootmgr.efi.mui
    │       └── memtest.efi.mui
    └── Recovery
        ├── BCD
        ├── BCD.LOG
        ├── BCD.LOG1
        └── BCD.LOG2
13 directories, 58 files
```

## NVRAM

NVRAM is the non-volatile storage that contains the firmware settings, which on classic PCs was also known as CMOS memory but on modern systems may actually use some technology other than CMOS (Complementary Metal Oxide Semiconductor)

## `\EFI\Boot\bootx64.efi`

The `\EFI\Boot\bootx64.efi` program is a fallback for when the EFI hasn't been configured with any NVRAM boot entries that refer to other boot programs on the disk. It's important for removable media like bootable CDs and USB drives, but **on a hard drive, it's generally not used**.

Windows will install a copy of its bootloader to this path automatically as a fail-safe; when installing GRUB, the `grub-install` (or `grub2-install` depending on Linux distribution) command may also put a copy of the respective bootloader here if it does not already exist. If you want, you can use `grub-install --removable` to tell it to install to the fallback boot path, or `grub-install --force-extra-removable` to overwrite any existing bootloader in the fallback path and replace it with GRUB.

If you want to create a Secure Boot-compatible USB stick for UEFI, you should place a copy of the shim as `EFI\boot\bootx64.efi` and a copy of GRUB as `EFI\boot\grubx64.efi`, as the shim bootloader will look for `grubx64.efi` in the same directory the shim bootloader is in.

## `\EFI\Microsoft\Boot\bootmgfw.efi`

`bootmgfw.efi` isn't Windows bootloader, it's Windows Boot Manager, `\Windows\System32\winload.efi` is called Windows bootloader

## Secure Boot: `shimx64.efi` and the reasons for it

Secure Boot requires that a bootloader must be signed by a certificate that is included in the system's Secure Boot NVRAM variable `db`, or the bootloader's SHA256 hash must be whitelisted in the same NVRAM variable. A SHA256 hash will only match a specific version of a particular bootloader, so updates won't be possible unless the firmware variable is also updated. So the certificates are the way to go.

Unfortunately, many system vendors will only include a few Secure Boot certificates to their products: often only the vendor's own certificate (for firmware updates and hardware debugging/OEM configuration tools) and Microsoft's Secure Boot certificates. Some systems will allow editing the list of Secure Boot certificates through firmware settings (="BIOS settings"), but others won't. So an independent solution was needed.

Microsoft offers an UEFI bootloader signing service for anyone, but at least initially the turnaround time for signing was quite long, so the requirement to sign every version of GRUB directly would have caused unacceptable delays in bootloader updates. To solve the problem, the shim bootloader was developed: it's basically the simplest reasonable UEFI program that will add one or more certificates to the Secure Boot accepted list. The simplicity will hopefully reduce the need to update the shim itself, so the open-source OS distributions (Linux and others) can just get their version of the shim signed by Microsoft just once and then sign any version of GRUB with their own certificates, whose public part is embedded in the shim and allows Secure Boot accept the distribution's version of GRUB.

Two similar terms are often used interchangeably, but in fact they refer to different things:

## Boot Loaders vs. Boot Managers

-   **Boot managers** present a menu of boot options, or provide some other way to control the boot process. The user can then select an option, and the boot manager passes control to the selected tool.
-   **Boot loaders** handle the task of loading an OS kernel into memory, often along with support files such as a Linux initial RAM disk (initrd) file, and starting the kernel running.

## 参考资料

> 1. [EFI\boot\bootx64.efi vs EFI\ubuntu\grubx64.efi vs /boot/grub/x86_64-efi/grub.efi vs C:\Windows\Boot\EFI\*](https://unix.stackexchange.com/questions/565615/efi-boot-bootx64-efi-vs-efi-ubuntu-grubx64-efi-vs-boot-grub-x86-64-efi-grub-efi)
> 2. [Managing EFI Boot Loaders for Linux:Basic Principles](https://www.rodsbooks.com/efi-bootloaders/principles.html)
> 3. [EFI system partition](https://en.wikipedia.org/wiki/EFI_system_partition')
