ifdef ET_BOARD_BIOS_REQUIRED

include $(ET_DIR)/packages/opensbi.mk

define bios-depends-$(ET_BOARD_TYPE)
endef

define bios-software-$(ET_BOARD_TYPE)
	$(call opensbi-software)
endef

define bios-version-$(ET_BOARD_TYPE)
	$(call opensbi-version)
endef

define bios-clean-$(ET_BOARD_TYPE)
	$(call opensbi-clean)
endef

define bios-purge-$(ET_BOARD_TYPE)
	$(call opensbi-purge)
endef

define bios-info-$(ET_BOARD_TYPE)
	$(call opensbi-info)
endef

define bios-update-$(ET_BOARD_TYPE)
	$(call opensbi-update)
endef

define bios-$(ET_BOARD_TYPE)
	$(call bios-depends-$(ET_BOARD_TYPE))
	$(call opensbi)
endef

.PHONY: bios-$(ET_BOARD_TYPE)
bios-$(ET_BOARD_TYPE): $(ET_BIOS_TARGET_LIST)

bios-%-$(ET_BOARD_TYPE):
	$(call bios-$(*F)-$(ET_BOARD_TYPE))

endif
# ET_BOARD_BIOS_REQUIRED
