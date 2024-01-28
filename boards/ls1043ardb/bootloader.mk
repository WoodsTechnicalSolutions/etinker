include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/bootloader.mk

export LSDK_RCW_DIR := $(ET_SOFTWARE_DIR)/qoriq/rcw
export LSDK_RCW_BIN ?= $(LSDK_RCW_DIR)/$(LSDK_MACHINE)/RR_FQPP_1455/rcw_1600_sdboot.bin
export LSDK_ATF_DIR := $(ET_SOFTWARE_DIR)/qoriq/atf
export LSDK_ATF_BL2_BIN ?= $(ET_SOFTWARE_DIR)/qoriq/atf/build/$(LSDK_MACHINE)/release/bl2_$(LSDK_BOOTTYPE).pbl
export LSDK_ATF_FIP_BIN ?= $(LSDK_ATF_DIR)/build/$(LSDK_MACHINE)/release/fip.bin

define bootloader-depends-$(ET_BOARD)
	$(call bootloader-depends-$(ET_BOARD_TYPE))
endef

define bootloader-prepare-$(ET_BOARD)
	$(call bootloader-prepare-$(ET_BOARD_TYPE))
endef

define bootloader-finalize-$(ET_BOARD)
	$(call bootloader-finalize-$(ET_BOARD_TYPE))
	$(RM) $(ET_BOOTLOADER_DIR)/boot/bl2_$(LSDK_BOOTTYPE).pbl
	$(RM) $(ET_BOOTLOADER_DIR)/boot/fip.bin
	@mkdir -p $(ET_SOFTWARE_DIR)/qoriq
	@if ! [ -d $(LSDK_RCW_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/qoriq && \
		git clone https://github.com/nxp-qoriq/rcw.git $(LSDK_RCW_DIR)); \
		if ! [ -d $(LSDK_RCW_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) QorIQ 'rcw' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@echo
	(cd $(LSDK_RCW_DIR) && echo && \
		git fetch --all && \
		git checkout $(LSDK_VERSION) && echo && \
		cd $(LSDK_MACHINE) && \
			make clean all)
	@if ! [ -f $(LSDK_RCW_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building $(LSDK_VERSION) $(LSDK_RCW_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@if ! [ -d $(LSDK_ATF_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/qoriq && \
			git clone https://github.com/nxp-qoriq/atf.git $(LSDK_ATF_DIR)); \
		if ! [ -d $(LSDK_ATF_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) QorIQ 'atf' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@echo
	(cd $(LSDK_ATF_DIR) && echo && \
		git restore . && git clean -df && \
		git fetch --all && git fetch --tags && \
		git checkout $(LSDK_VERSION) && echo && \
		sed -i s,--fatal-warnings\ -O1,--fatal-warnings\ -O1\ --no-warn-rwx-segments\ --no-warn-execstack, Makefile && \
		git branch -D patched -f $(ET_NOERR); \
		git switch -c patched; \
		git commit -a -m "etinker: Fix compiler flags" && echo && \
		make PLAT=$(LSDK_MACHINE) clean && \
		make ARCH=aarch64 CROSS_COMPILE=$(ET_CROSS_TUPLE)- \
			PLAT=$(LSDK_MACHINE) bl2 \
			BOOT_MODE=$(LSDK_BOOTTYPE) \
			pbl RCW=$(LSDK_RCW_BIN))
	@if ! [ -f $(LSDK_ATF_BL2_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building $(LSDK_VERSION) $(LSDK_ATF_BL2_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@echo
	(cd $(LSDK_ATF_DIR) && echo && \
		make ARCH=aarch64 CROSS_COMPILE=$(ET_CROSS_TUPLE)- \
			PLAT=$(LSDK_MACHINE) fip \
			BOOT_MODE=$(LSDK_BOOTTYPE) \
			BL33=$(ET_BOOTLOADER_BUILD_IMAGE))
	@if ! [ -f $(LSDK_ATF_FIP_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building $(LSDK_VERSION) $(LSDK_ATF_FIP_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@echo
	@cp -av $(LSDK_ATF_BL2_BIN) $(ET_BOOTLOADER_DIR)/boot/
	@cp -av $(LSDK_ATF_FIP_BIN) $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-info-$(ET_BOARD)
	$(call bootloader-info-$(ET_BOARD_TYPE))
	@printf "LSDK_RCW_DIR: $(LSDK_RCW_DIR)\n"
	@printf "LSDK_RCW_BIN: $(LSDK_RCW_BIN)\n"
	@printf "LSDK_ATF_DIR: $(LSDK_ATF_DIR)\n"
	@printf "LSDK_ATF_BL2_BIN: $(LSDK_ATF_BL2_BIN)\n"
	@printf "LSDK_ATF_FIP_BIN: $(LSDK_ATF_FIP_BIN)\n"
endef
