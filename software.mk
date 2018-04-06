#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

# check for existence of a source tree
define software-check
	@if ! [ -d $(ET_SOFTWARE_DIR)/$1 ]; then \
		printf "\n"; \
		printf "*****  MISSING $(ET_SOFTWARE_DIR)/$1 DIRECTORY  *****\n"; \
		printf "===>  PLEASE ADD $(ET_SOFTWARE_DIR)/$1 SOFTWARE  <===\n"; \
		printf "\n"; \
		exit 2; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$1 *****\n\n"
endef

# install typical host OS development packages
define software-development
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
endef
