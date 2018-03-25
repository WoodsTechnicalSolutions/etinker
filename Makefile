#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

include etinker.mk

.PHONY: all
all: toolchain

# embedded toolchains (GCC, GDB, and LIBC) are built using crosstool-NG

ET_TOOLCHAIN_TARGETS_FINAL ?= \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gcc \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gdb
ET_TOOLCHAIN_GENERATOR_DIR := $(ET_DIR)/toolchain/generator
ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/ct-ng
ET_TOOLCHAIN_CONFIG := $(ET_CONFIG_DIR)/crosstool-ng/config
ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGETS_FINAL)
$(ET_TOOLCHAIN_TARGETS_FINAL):
	$(MAKE) toolchain-build

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)
	@(cd $(ET_TOOLCHAIN_BUILD_DIR) && CT_ARCH=$(ET_ARCH) $(ET_TOOLCHAIN_GENERATOR) $(*F))
	@tail -n +5 $< > $(ET_TOOLCHAIN_CONFIG)

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_CONFIG)
	@mkdir -p $(ET_TARBALLS_DIR)
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)
	@cat $< > $@
	@$(MAKE) toolchain-generator
	@$(MAKE) toolchain-oldconfig

.PHONY: toolchain-generator
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	@if ! [ -d $(ET_TOOLCHAIN_GENERATOR_DIR) ]; then \
		mkdir -p $(ET_DIR)/toolchain; \
		cp -a $(ET_SOFTWARE_DIR)/crosstool-ng $(ET_TOOLCHAIN_GENERATOR_DIR); \
	fi
	@(cd $(ET_TOOLCHAIN_GENERATOR_DIR); \
		if ! [ -f .patched ]; then \
			for f in $(shell ls $(ET_PATCH_DIR)/crosstool-ng/*.patch); do \
				patch -p1 < $$f; \
			done; \
			touch .patched; \
		fi; \
		./bootstrap; \
		./configure --enable-local; \
		sed -i s,-dirty,, Makefile; \
		$(MAKE))
	@if ! [ -f $@ ]; then \
		printf "***** crosstool-NG 'ct-ng' build FAILED! *****\n"; \
		exit 2; \
	fi

.PHONY: clean
clean:
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE)

.PHONY: purge
purge:
	@$(RM) -r $(ET_TOOLCHAIN_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_GENERATOR_DIR)

.PHONY: build-essential
build-essential:
	@if [ -f /usr/bin/apt ]; then \
		sudo apt update; \
		sudo apt install -y \
			asciidoc \
			autoconf \
			autopoint \
			bash-completion \
			bc \
			bison \
			build-essential \
			ccache \
			chrpath \
			cifs-utils \
			cmake \
			cscope \
			curl \
			cvs \
			dblatex \
			device-tree-compiler \
			dia \
			docbook-utils \
			dosfstools \
			exuberant-ctags \
			fakeroot \
			flex \
			flip \
			gawk \
			gcc-7-doc \
			gcc-multilib \
			gettext \
			git-core \
			gitg \
			gitk \
			gperf \
			help2man \
			htop \
			indent \
			inkscape \
			intltool \
			kernel-package \
			libasound2-dev \
			libexpat1-dev \
			libglade2-dev \
			libglib2.0-dev \
			libgtk2.0-dev \
			libjpeg-dev \
			libncurses-dev \
			libreadline-dev \
			libssl-dev \
			libtool \
			libtool-bin \
			libusb-1.0-0-dev \
			libusb-dev \
			libx11-dev \
			libxml2-utils \
			lzma \
			lzop \
			man \
			manpages-dev \
			manpages-posix-dev \
			mc \
			mercurial \
			mtd-utils \
			openssh-client \
			pkg-config \
			qemu \
			rsync \
			screen \
			subversion \
			texinfo \
			tig \
			tmux \
			tree \
			u-boot-tools \
			uucp \
			uuid-dev \
			unzip \
			vim \
			w3m \
			wget \
			whiptail \
			whois \
			xmlto \
			xz-utils \
			zip; \
		if [ "$(shell uname -m)" = "x86_64" ]; then \
			sudo apt install -y libc6-dev-i386; \
		fi; \
		sudo apt autoremove; \
	fi
