ifdef ET_BOARD_BIOS_REQUIRED

include $(ET_DIR)/packages/k3-$(TI_K3_SOC)-r5-sk.mk

define bios-depends-$(ET_BOARD_TYPE)
endef

define bios-software-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-software)
endef

define bios-version-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-version)
endef

define bios-clean-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-clean)
endef

define bios-purge-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-purge)
endef

define bios-info-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-info)
endef

define bios-update-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk-update)
endef

define bios-$(ET_BOARD_TYPE)
	$(call k3-$(TI_K3_SOC)-r5-sk)
endef

.PHONY: bios-$(ET_BOARD_TYPE) bios-$(ET_BOARD_TYPE)-all
bios-$(ET_BOARD_TYPE) bios-$(ET_BOARD_TYPE)-all:
	$(call $@)

.PHONY: bios-clean-$(ET_BOARD_TYPE)
bios-clean-$(ET_BOARD_TYPE):
	$(call $@)

.PHONY: bios-purge-$(ET_BOARD_TYPE)
bios-purge-$(ET_BOARD_TYPE):
	$(call $@)

.PHONY: bios-version-$(ET_BOARD_TYPE)
bios-version-$(ET_BOARD_TYPE):
	$(call $@)

.PHONY: bios-software-$(ET_BOARD_TYPE)
bios-software-$(ET_BOARD_TYPE):
	$(call $@)

.PHONY: bios-info-$(ET_BOARD_TYPE)
bios-info-$(ET_BOARD_TYPE):
	$(call $@)

.PHONY: bios-update-$(ET_BOARD_TYPE)
bios-update-$(ET_BOARD_TYPE):
	$(call $@)

bios-$(ET_BOARD_TYPE)-%:
	$(call bios-$(ET_BOARD_TYPE),$(*F))

endif
# ET_BOARD_BIOS_REQUIRED
