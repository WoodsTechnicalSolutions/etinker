include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/kernel.mk

export LSDK_PFE_DIR := $(ET_SOFTWARE_DIR)/qoriq/qoriq-engine-pfe-bin
export LSDK_PFE_ELF := $(LSDK_PFE_DIR)/ls1012a/slow_path/*.elf
export LSDK_PFE_BIN := $(LSDK_PFE_DIR)/ls1012a/u-boot/pfe_fw_sbl.itb

define kernel-depends-$(ET_BOARD)
	$(call kernel-depends-$(ET_BOARD_TYPE))
endef

define kernel-prepare-$(ET_BOARD)
	$(call kernel-prepare-$(ET_BOARD_TYPE))
	@mkdir -p $(ET_SOFTWARE_DIR)/qoriq
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
	@cp -av $(LSDK_PFE_ELF) $(ET_KERNEL_SOFTWARE_DIR)/drivers/firmware/
	@cp -av $(LSDK_PFE_BIN) $(ET_KERNEL_SOFTWARE_DIR)/drivers/firmware/
endef

define kernel-build-$(ET_BOARD)
	$(call kernel-build-$(ET_BOARD_TYPE))
endef

define kernel-finalize-$(ET_BOARD)
	$(call kernel-finalize-$(ET_BOARD_TYPE))
	@mkdir -p $(ET_KERNEL_DIR)/usr/lib/firmware
	@echo
	@cp -av $(LSDK_PFE_ELF) $(ET_KERNEL_DIR)/usr/lib/firmware/
	@cp -av $(LSDK_PFE_BIN) $(ET_KERNEL_DIR)/usr/lib/firmware/
	@echo
	@cp -av $(LSDK_PFE_ELF) $(ET_KERNEL_DIR)/boot/
	@cp -av $(LSDK_PFE_BIN) $(ET_KERNEL_DIR)/boot/
endef

define kernel-info-$(ET_BOARD)
	$(call kernel-info-$(ET_BOARD_TYPE))
	@printf "LSDK_PFE_DIR: $(LSDK_PFE_DIR)\n"
	@printf "LSDK_PFE_ELF: $(LSDK_PFE_ELF)\n"
	@printf "LSDK_PFE_BIN: $(LSDK_PFE_BIN)\n"
endef
