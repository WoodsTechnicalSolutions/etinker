export FIP_DIR := $(ET_SOFTWARE_DIR)/fip
export FIP_BUILD_DIR := $(ET_BOOTLOADER_BUILD_DIR)/fip

define bootloader-depends-$(ET_BOARD_TYPE)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

# https://github.com/u-boot/u-boot/blob/master/doc/board/amlogic/libretech-cc.rst
define bootloader-finalize-$(ET_BOARD_TYPE)
	@if ! [ -d $(FIP_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR) && \
			wget https://github.com/BayLibre/u-boot/releases/download/v2017.11-libretech-cc/libretech-cc_fip_20180418.tar.gz && \
			tar -zxvf libretech-cc_fip_20180418.tar.gz); \
		if ! [ -f $(FIP_DIR)/gxl/aml_encrypt_gxl ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting Amlogic binary blobs FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@mkdir -p $(FIP_BUILD_DIR)
	@cp -av $(FIP_DIR)/gxl/bl2.bin $(FIP_BUILD_DIR)/
	@cp -av $(FIP_DIR)/gxl/acs.bin $(FIP_BUILD_DIR)/
	@cp -av $(FIP_DIR)/gxl/bl21.bin $(FIP_BUILD_DIR)/
	@cp -av $(FIP_DIR)/gxl/bl30.bin $(FIP_BUILD_DIR)/
	@cp -av $(FIP_DIR)/gxl/bl301.bin $(FIP_BUILD_DIR)/
	@cp -av $(FIP_DIR)/gxl/bl31.img $(FIP_BUILD_DIR)/
	@cp -av $(ET_BOOTLOADER_BUILD_IMAGE) $(FIP_BUILD_DIR)/bl33.bin
	$(FIP_DIR)/blx_fix.sh \
		$(FIP_BUILD_DIR)/bl30.bin \
		$(FIP_BUILD_DIR)/zero_tmp \
		$(FIP_BUILD_DIR)/bl30_zero.bin \
		$(FIP_BUILD_DIR)/bl301.bin \
		$(FIP_BUILD_DIR)/bl301_zero.bin \
		$(FIP_BUILD_DIR)/bl30_new.bin \
		bl30
	python2 $(FIP_DIR)/acs_tool.pyc $(FIP_BUILD_DIR)/bl2.bin $(FIP_BUILD_DIR)/bl2_acs.bin $(FIP_BUILD_DIR)/acs.bin 0
	$(FIP_DIR)/blx_fix.sh \
		$(FIP_BUILD_DIR)/bl2_acs.bin \
		$(FIP_BUILD_DIR)/zero_tmp \
		$(FIP_BUILD_DIR)/bl2_zero.bin \
		$(FIP_BUILD_DIR)/bl21.bin \
		$(FIP_BUILD_DIR)/bl21_zero.bin \
		$(FIP_BUILD_DIR)/bl2_new.bin \
		bl2
	$(FIP_DIR)/gxl/aml_encrypt_gxl --bl3enc --input $(FIP_BUILD_DIR)/bl30_new.bin
	$(FIP_DIR)/gxl/aml_encrypt_gxl --bl3enc --input $(FIP_BUILD_DIR)/bl31.img
	$(FIP_DIR)/gxl/aml_encrypt_gxl --bl3enc --input $(FIP_BUILD_DIR)/bl33.bin
	$(FIP_DIR)/gxl/aml_encrypt_gxl --bl2sig --input $(FIP_BUILD_DIR)/bl2_new.bin --output $(FIP_BUILD_DIR)/bl2.n.bin.sig
	$(FIP_DIR)/gxl/aml_encrypt_gxl --bootmk \
		--output $(FIP_BUILD_DIR)/u-boot.bin \
		--bl2    $(FIP_BUILD_DIR)/bl2.n.bin.sig \
		--bl30   $(FIP_BUILD_DIR)/bl30_new.bin.enc \
		--bl31   $(FIP_BUILD_DIR)/bl31.img.enc \
		--bl33   $(FIP_BUILD_DIR)/bl33.bin.enc
	@cp -av $(FIP_BUILD_DIR)/u-boot.bin* $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-finalize-$(ET_BOARD_TYPE)-gxlimg
	$(call software-check,gxlimg,gxlimg)
	$(call software-check,arm-trusted-firmware,arm-trusted-firmware)
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	@(cd $(ET_SOFTWARE_DIR)/gxlimg && \
		$(MAKE) --no-print-directory \
			clean \
			image \
			UBOOT=$(ET_BOOTLOADER_BUILD_IMAGE) && \
		cp -av build/fip/gxl/u-boot.bin.enc $(ET_BOOTLOADER_DIR)/boot/u-boot.bin && \
		cp -av build/gxl-boot.bin $(ET_BOOTLOADER_DIR)/boot/)
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "FIP_DIR: $(FIP_DIR)\n"
	@printf "FIP_BUILD_DIR: $(FIP_BUILD_DIR)\n"
endef
