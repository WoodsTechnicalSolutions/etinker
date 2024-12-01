ifdef ET_BOARD_BIOS_REQUIRED

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/bios.mk

define bios-depends-$(ET_BOARD)
endef

define bios-software-$(ET_BOARD)
	$(call bios-software-$(ET_BOARD_TYPE))
endef

define bios-version-$(ET_BOARD)
	$(call bios-version-$(ET_BOARD_TYPE))
endef

define bios-clean-$(ET_BOARD)
	$(call bios-clean-$(ET_BOARD_TYPE))
endef

define bios-purge-$(ET_BOARD)
	$(call bios-purge-$(ET_BOARD_TYPE))
endef

define bios-info-$(ET_BOARD)
	$(call bios-info-$(ET_BOARD_TYPE))
endef

define bios-update-$(ET_BOARD)
	$(call bios-update-$(ET_BOARD_TYPE))
endef

define bios-$(ET_BOARD)
	$(call bios-$(ET_BOARD_TYPE))
	$(call bios-depends-$(ET_BOARD))
endef

.PHONY: bios-$(ET_BOARD) bios-$(ET_BOARD)-all
bios-$(ET_BOARD) bios-$(ET_BOARD)-all:
	$(call $@)

.PHONY: bios-clean-$(ET_BOARD)
bios-clean-$(ET_BOARD):
	$(call $@)

.PHONY: bios-purge-$(ET_BOARD)
bios-purge-$(ET_BOARD):
	$(call $@)

.PHONY: bios-version-$(ET_BOARD)
bios-version-$(ET_BOARD):
	$(call $@)

.PHONY: bios-software-$(ET_BOARD)
bios-software-$(ET_BOARD):
	$(call $@)

.PHONY: bios-info-$(ET_BOARD)
bios-info-$(ET_BOARD):
	$(call $@)

.PHONY: bios-update-$(ET_BOARD)
bios-update-$(ET_BOARD):
	$(call $@)

bios-$(ET_BOARD)-%:
	$(call bios-$(ET_BOARD),$(*F))

endif
# ET_BOARD_BIOS_REQUIRED
