# etinker
Embedded Tinkerer Sandbox

This is a basic embedded software sandbox that can be used to experiment
with some of the essential open source components used in low-level
development. Generating production quality software BSP images is
**NOT** a goal here. Gaining some understanding of how things are really
built, or can be built, is the purpose behind the work. As the name
suggests, this is about tinkering.

## Development Boards

- am335x-pocketbeagle [Octavo/TI ARM Cortex-A8]
- am3517-evm [TI ARM Cortex-A8]
- arm-bare-metal [Generic ARM MCU]
- ek-tm4c123gxl [TI TivaC ARM Cortex-M4]
- ek-tm4c1294xl [TI TivaC ARM Cortex-M4]
- nrf52840-dongle [Nordic ARM Cortex-M4]
- omap3-beagle-xm [TI ARM Cortex-A8]
- omap3-beagle [TI ARM Cortex-A8]
- omap3-evm [TI ARM Cortex-A8]
- pynq-z2 [Xilinx Zynq-7020 ARM Cortex-A9]
- sama5d3-xpld [ARM Cortex-A5]

## Quick Start Guide

1. Clone etinker

```
$ git clone https://github.com/WoodsTechnicalSolutions/etinker
```

2. Install build dependencies (Assumes Ubuntu 18.04 LTS or newer)

```
$ cd etinker
$ ./scripts/host/setup
```

3. Build your first board

```
$ ET_BOARD=am335x-pocketbeagle make sandbox
```

Depending on your workstation hardware, the build time could be 1.5
hours or greater. The GNU C/C++ compiler, library, and debugger
(toolchain) are built, from source, using **crosstool-ng**. This will
account for at least half the build time typically. The build tools
need access to a network with a route to the Internet. All of the
source code will be pulled from online locations. Slow network
connections will also impact build time significantly, for the first
build. Repositories and tarballs are cached locally. The download
time penalty is paid only at the time of initial builds and upgrades.

4. Verify build artifacts

```
$ tree -L 1 toolchain bootloader kernel rootfs
toolchain
├── arm-cortexa8-linux-gnueabihf
├── build
└── generator
bootloader
├── am335x-pocketbeagle
└── build
kernel
├── am335x-pocketbeagle
└── build
rootfs
├── am335x-pocketbeagle
└── build

9 directories, 0 files

$ tree rootfs/am335x-pocketbeagle/
rootfs/am335x-pocketbeagle/
└── arm-cortexa8-linux-gnueabihf
    └── images
        ├── rootfs.tar
        └── rootfs.ubifs

2 directories, 2 files

$ du -chs etinker
84G     etinker
84G     total
```

5. Format SD/MMC card

The provided **mksdcard** script is used to setup the 'etinker'
preferred disk layout:

Partition | Type  | Size (MiB) | Label  | Mount Point
----------|-------|------------|--------|------------
1         | fat16 | 256        | BOOT   | /media/user/BOOT
2         | ext4  | <balance>  | rootfs | /media/user/rootfs

Makefile tooling and scripts expect this arrangement.

```
$ sudo ./scripts/mksdcard am335x-pocketbeagle /dev/sdX
```

The **/dev/sdX** depends on the media that you have chosen. It can
be an MMC block device also. ( i.e. **/dev/mmcblkX**) The resultant
SD/MMC will have two partitions. [1 GiB SD/MMC used as example]

```
$ sudo parted --list
[...]
Model: Mass Storage Device (scsi)
Disk /dev/sdX: 988MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End    Size   Type     File system  Flags
 1      1049kB  269MB  268MB  primary  fat16        boot, lba
 2      269MB   988MB  719MB  primary  ext4
[...]
```

You should properly unmount and eject the SD/MMC card and re-insert to
verify partitions were created correctly.

```
$ df
Filesystem     1K-blocks      Used Available Use% Mounted on
[...]
/dev/sdX2         674520      1384    624004   1% /media/<user>/rootfs
/dev/sdX1         261868         0    261868   0% /media/<user>/BOOT

```

6. Setup SD/MMC card for booting

```
$ ET_BOARD=am335x-pocketbeagle make rootfs-sync-mmc
$ ET_BOARD=am335x-pocketbeagle make bootloader-sync-mmc
$ ET_BOARD=am335x-pocketbeagle make kernel-sync-mmc
```

Each make command, shown above, results in a 'sync' of the fileystem.
So it may take a minute or two to complete, depending on file sizes.

Your SD/MMC card is now ready to boot your board. Enjoy.
