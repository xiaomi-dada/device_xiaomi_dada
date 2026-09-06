#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# dtbo.img holds the device overlay on its own.
#
# QCOM's merge script folds the techpack fragments into every tree it is
# handed, and the kernel task hands it the overlay alongside the eight base
# trees.  That is right for the bases -- it is how dtb.img comes by its
# camera, display and audio nodes -- and wrong for the overlay.  The vendor
# ships the overlay unmerged, and a merged one picks up references to labels
# the base trees do not export (xo_calib_data, WCAL_PBS, hwfence_shbuf), so
# the bootloader cannot apply it and the device tree it boots on is the bare
# SoC one.
#
# The merge leaves the unmerged copies behind in $(DTBS_BASE), so take the
# overlay from there, after the dtb.img rule has run.
#

MKDTBOIMG := $(HOST_OUT_EXECUTABLES)/mkdtboimg$(HOST_EXECUTABLE_SUFFIX)

$(BOARD_PREBUILT_DTBOIMAGE): $(INSTALLED_DTBIMAGE_TARGET) $(MKDTBOIMG)
	@echo "Building dtbo.img"
	@mkdir -p $(dir $@)
	$(MKDTBOIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) \
		$(DTBS_BASE)/dada-overlay.dtbo
