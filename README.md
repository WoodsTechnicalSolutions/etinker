# etinker
Embedded Tinkerer Sandbox

This is a basic embedded software sandbox that can be used to experiment
with some of the essential open source components used in low-level
development. Generating production quality software BSP images is
**NOT** a goal here. Gaining some understanding of how things are really
built, or can be built, is the purpose behind the work. It is used to
evaluate upstream changes to toolchain components, Linux, U-Boot, and
Buildroot. Being close to upstream development helps with the task of
contributing back to those projects. As the name suggests, this is
about tinkering.

## Development Boards

- am335x-pocketbeagle [Octavo/TI ARM Cortex-A8]
- am3517-evm [TI ARM Cortex-A8]
- aml-s905x-cc [Amlogic ARM Cortex-A53]
- ek-tm4c123gxl [TI TivaC ARM Cortex-M4]
- ek-tm4c1294xl [TI TivaC ARM Cortex-M4]
- ls1012afrdm [NXP Layerscape ARM Cortex-A53]
- ls1043ardb [NXP Layerscape ARM Cortex-A53]
- nrf52840-dongle [Nordic ARM Cortex-M4]
- omap3-beagle-xm [TI ARM Cortex-A8]
- omap3-beagle [TI ARM Cortex-A8]
- omap3-evm [TI ARM Cortex-A8]
- pynq-z2 [Xilinx Zynq-7020 ARM Cortex-A9]
- sama5d3-xpld [ARM Cortex-A5]

### Special Boards

#### Virtual Boards

These boards are not directly built, but rather provide common SOC
definitions used by higher level real boards. This tracks the Linux
kernel view of what is common to a given platform. Configuration
files for Linux, U-Boot, and Buildroot reside in the virtual boards.

- layerscape [ls1043ardb]
- meson [aml-s905x-cc]
- omap2plus [am335x-pocketbeagle, am3517-evm, omap3-beagle, omap3-beagle-xm, omap3-evm]
- sama5 [sama5d3-xpld]
- zynq [pynq-z2]

#### Toolchain Boards

These boards allow building toolchains in the same manner as a
higher level board. The configuration files for crosstool-ng reside
with the toolchain boards. This concept is useful for testing new
and/or variant toolchains.

- aarch64-cortexa53-linux-gnu [layerscape, meson]
- arm-none-eabi
- arm-none-eabihf [ek-tm4c123gxl, ek-tm4c1294xl, nrf52840-dongle]
- arm-cortexa5-linux-gnueabihf [sama5]
- arm-cortexa8-linux-gnueabihf [omap2plus]
- arm-cortexa9-linux-gnueabihf [zynq]

## Quick Start Guide

1. Clone etinker

```
$ git clone https://github.com/WoodsTechnicalSolutions/etinker
```

2. Install build dependencies (Assumes Ubuntu 20.04 LTS or newer)

```
$ cd etinker
$ ./scripts/host/setup
```

3. Build your first board

```
$ ET_BOARD=am335x-pocketbeagle make sandbox
```

Depending on your workstation hardware, the build time could be 1.5
hours or greater. The GNU toolchain (C/C++ compiler, C library, and
debugger) is built, from source, by **crosstool-ng**. This will
account for at least half the build time typically. The build tools
need access to a network with a route to the Internet. All of the
source code will be pulled from online locations. Slow network
connections will also impact build time significantly, for the first
build. Repositories and tarballs are cached locally. The download
time penalty is paid only at the time of initial builds and upgrades.

4. Verify build artifacts

```
$ tree -L 2 toolchain bootloader kernel rootfs
toolchain
├── arm-cortexa8-linux-gnueabihf
│   ├── arm-cortexa8-linux-gnueabihf
│   ├── bin
│   ├── build.log.bz2
│   ├── include
│   ├── lib
│   ├── libexec
│   └── share
├── build
│   └── arm-cortexa8-linux-gnueabihf
└── generator

bootloader
├── am335x-pocketbeagle
│   └── arm-cortexa8-linux-gnueabihf
└── build
    └── am335x-pocketbeagle

kernel
├── am335x-pocketbeagle
│   └── arm-cortexa8-linux-gnueabihf
└── build
    └── omap2plus

rootfs
├── am335x-pocketbeagle
│   └── arm-cortexa8-linux-gnueabihf
└── build
    └── omap2plus

$ tree -L 3 rootfs/am335x-pocketbeagle/
rootfs/am335x-pocketbeagle/
└── arm-cortexa8-linux-gnueabihf
    └── images
        └── rootfs.tar

$ du -chs etinker
84G     etinker
84G     total
```

5. Format SD/MMC card

The provided **mksdcard** script is used to setup the 'etinker'
preferred disk layout:

Partition | Type  | Size (MiB) | Label  | Mount Point
----------|-------|------------|--------|------------
MBR/GPT   |       | 68         |        |
1         | fat16 | 128        | BOOT   | /media/user/BOOT
2         | ext4  | 2048       | rootfs | /media/user/rootfs
3         | ext4  | 5120       | backup | /media/user/backup
4         | ext4  | remaining  | data   | /media/user/data

Makefile tooling and scripts expect this arrangement.

```
$ sudo ./scripts/mksdcard am335x-pocketbeagle /dev/sdX
```

The **/dev/sdX** depends on the media that you have chosen. It can
be an MMC block device also. ( i.e. **/dev/mmcblkX**) The resultant
SD/MMC will have four partitions. [64 GiB SD/MMC used as example]
**NOTE:** Use higher quality SD/MMC cards (Class 10, UHS-1 or better)

```
$ sudo parted --list
[...]
Model: SD SR64G (sd/mmc)
Disk /dev/mmcblk0: 63.9GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      71.3MB  206MB   134MB   primary  fat16        boot, lba
 2      206MB   2353MB  2147MB  primary  ext4
 3      2353MB  7722MB  5369MB  primary  ext4
 4      7722MB  63.9GB  56.1GB  primary  ext4
[...]
```

You should properly unmount and eject the SD/MMC card and re-insert to
verify partitions were created correctly.

```
$ df
Filesystem  1K-blocks  Used Available Use% Mounted on
[...]
/dev/sdX1      130798     0    130798   0% /media/<user>/BOOT
/dev/sdX2     1998672  6144   1871288   1% /media/<user>/rootfs
/dev/sdX3     5095040 20472   4796040   1% /media/<user>/backup
/dev/sdX4    53702984 53272  50891980   1% /media/<user>/data
[...]
```

6. Setup SD/MMC card for booting

The media is expected to be partitioned, formatted, and have
'/media/<user>/BOOT' and '/media/<user>/rootfs' mounted. The
following make commands will populate the media:

```
$ ET_BOARD=am335x-pocketbeagle make rootfs-sync-mmc
$ ET_BOARD=am335x-pocketbeagle make bootloader-sync-mmc
$ ET_BOARD=am335x-pocketbeagle make kernel-sync-mmc
$ ET_BOARD=am335x-pocketbeagle make overlay-sync-mmc

OR simply

$ ET_BOARD=am335x-pocketbeagle make sync
```

Each make command, shown above, results in a 'sync' of the fileystem.
So it may take a minute or two to complete, depending on file sizes.

Your SD/MMC card is now ready to boot your board. Enjoy.
