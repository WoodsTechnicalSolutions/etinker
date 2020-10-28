include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/kernel.mk

define kernel-depends-$(ET_BOARD)
	$(call kernel-depends-$(ET_BOARD_TYPE))
endef

define kernel-prepare-$(ET_BOARD)
	$(call kernel-prepare-$(ET_BOARD_TYPE))
endef

define kernel-build-$(ET_BOARD)
	$(call kernel-build-$(ET_BOARD_TYPE))
endef

define kernel-finalize-$(ET_BOARD)
	$(call kernel-finalize-$(ET_BOARD_TYPE))
endef

define kernel-info-$(ET_BOARD)
	$(call kernel-info-$(ET_BOARD_TYPE))
endef
