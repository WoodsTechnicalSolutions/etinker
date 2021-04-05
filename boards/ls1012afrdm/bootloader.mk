include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/bootloader.mk

export LSDK_RCW_DIR := $(ET_SOFTWARE_DIR)/qoriq/rcw
export LSDK_RCW_BIN := $(LSDK_RCW_DIR)/$(LSDK_MACHINE)/N_SSNP_3305/rcw_800.bin
export LSDK_PPA_DIR := $(ET_SOFTWARE_DIR)/qoriq/ppa-generic
export LSDK_PPA_BIN := $(LSDK_PPA_DIR)/ppa/soc-ls1012/build/obj/ppa.itb
export LSDK_PFE_DIR := $(ET_SOFTWARE_DIR)/qoriq/qoriq-engine-pfe-bin
export LSDK_PFE_ELF := $(LSDK_PFE_DIR)/ls1012a/slow_path/*.elf
export LSDK_PFE_BIN := $(LSDK_PFE_DIR)/ls1012a/u-boot/pfe_fw_sbl.itb

define bootloader-depends-$(ET_BOARD)
	$(call bootloader-depends-$(ET_BOARD_TYPE))
endef

define bootloader-prepare-$(ET_BOARD)
	$(call bootloader-prepare-$(ET_BOARD_TYPE))
endef

define bootloader-finalize-$(ET_BOARD)
	$(call bootloader-finalize-$(ET_BOARD_TYPE))
	@mkdir -p $(ET_SOFTWARE_DIR)/qoriq
	@if ! [ -d $(LSDK_RCW_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/qoriq && \
			git clone https://source.codeaurora.org/external/qoriq/qoriq-components/rcw $(LSDK_RCW_DIR)); \
		if ! [ -d $(LSDK_RCW_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting NXP QorIQ 'rcw' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@echo
	(cd $(LSDK_RCW_DIR) && echo && \
		git fetch --all && \
		git checkout origin/integration && echo && \
		cd $(LSDK_MACHINE) && \
			make clean all)
	@if ! [ -f $(LSDK_RCW_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building 'integration' $(LSDK_RCW_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@echo
	@cp -av $(LSDK_RCW_BIN) $(ET_BOOTLOADER_DIR)/boot/
	@if ! [ -d $(LSDK_PPA_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/qoriq && \
			git clone https://source.codeaurora.org/external/qoriq/qoriq-components/ppa-generic $(LSDK_PPA_DIR)); \
		if ! [ -d $(LSDK_PPA_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting NXP QorIQ 'ppa-generic' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@echo
	(cd $(LSDK_PPA_DIR) && echo && \
		git fetch --all && \
		git checkout origin/github.qoriq-os/integration && echo && \
		cd ppa && CROSS_COMPILE=$(ET_CROSS_COMPILE) \
			./build dev frdm-fit ls1012)
	@if ! [ -f $(LSDK_PPA_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building 'integration' $(LSDK_PPA_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@echo
	@cp -av $(LSDK_PPA_BIN) $(ET_BOOTLOADER_DIR)/boot/
	@if ! [ -d $(LSDK_PFE_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/qoriq && \
			git clone https://github.com/NXP/qoriq-engine-pfe-bin.git $(LSDK_PFE_DIR)); \
		if ! [ -d $(LSDK_PFE_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting NXP QorIQ 'PFE Firmware' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@echo
	(cd $(LSDK_PFE_DIR) && echo && \
		git fetch --all && \
		git checkout origin/integration)
	@if ! [ -f $(LSDK_PFE_BIN) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building 'integration' $(LSDK_PFE_BIN) FAILED! *****\n\n"; \
		exit 2; \
	fi
	@echo
	@cp -av $(LSDK_PFE_ELF) $(ET_BOOTLOADER_DIR)/boot/
	@cp -av $(LSDK_PFE_BIN) $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-info-$(ET_BOARD)
	$(call bootloader-info-$(ET_BOARD_TYPE))
	@printf "LSDK_RCW_DIR: $(LSDK_RCW_DIR)\n"
	@printf "LSDK_RCW_BIN: $(LSDK_RCW_BIN)\n"
	@printf "LSDK_PPA_DIR: $(LSDK_PPA_DIR)\n"
	@printf "LSDK_PPA_BIN: $(LSDK_PPA_BIN)\n"
	@printf "LSDK_PFE_DIR: $(LSDK_PFE_DIR)\n"
	@printf "LSDK_PFE_ELF: $(LSDK_PFE_ELF)\n"
	@printf "LSDK_PFE_BIN: $(LSDK_PFE_BIN)\n"
endef
