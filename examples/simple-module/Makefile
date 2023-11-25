# 
# https://www.kernel.org/doc/html/latest/kbuild/modules.html
#
# KERNEL_DIR refers to the path of the kernel source tree
# MODULE_DIR refers to the path of the kernel module source tree
# ROOTFS_DIR refers to the path of the target rootfs installation (i.e. '/')
#
# NOTE: Known to work on Ubuntu 20.04+ LTS systems
#
# $ sudo make clean all
# $ sudo make install
# $ sudo modprobe -v simple-module
# $ dmesg | tail | grep simple
#

MNAME := simple-module

obj-m += $(MNAME).o

# add CFLAGS, if needed
#ccflags-y += -Wno-date-time
#ccflags-y += -Wno-missing-attributes

ARCH ?= $(shell uname -m)

MODULE_DIR ?= $(shell pwd)
KERNEL_DIR ?= /lib/modules/$(shell uname -r)/build

all: modules

install: modules
ifeq ($(ARCH),x86_64)
	@if ! [ -f $(KERNEL_DIR)/System.map ]; then \
		(cd $(KERNEL_DIR)/ && \
			rm -f System.map vmlinuz; \
			ln -s /boot/System.map-$(shell uname -r) System.map; \
			ln -s /boot/vmlinuz-$(shell uname -r) vmlinuz); \
	fi
endif
	$(MAKE) -C $(KERNEL_DIR) \
		M=$(MODULE_DIR) \
		INSTALL_MOD_PATH=$(ROOTFS_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		ARCH=$(ARCH) \
		modules_install

modules:
ifeq ($(ARCH),x86_64)
	@if [ -f /sys/kernel/btf/vmlinux ]; then \
		sudo cp /sys/kernel/btf/vmlinux /usr/lib/modules/$(shell uname -r)/build/; \
		sudo cp /sys/kernel/btf/vmlinux /boot/; \
	fi
endif
	$(MAKE) -C $(KERNEL_DIR) \
		M=$(MODULE_DIR) \
		INSTALL_MOD_PATH=$(ROOTFS_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		ARCH=$(ARCH) \
		modules

clean:
	$(RM) -r arch include kernel *.o *.ko .*cmd .*mod *.order *.symvers $(MNAME).cmd $(MNAME).mod*
