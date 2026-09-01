# SPDX-License-Identifier: Apache-2.0
#
# Vendor modules with no source in this tree, so they cannot be built.
#
# Everything else the device loads is built from kernel/xiaomi/sm8750 and
# kernel/xiaomi/sm8750-modules-qcom.  What decides whether a prebuilt still
# binds is not the kernel release in its vermagic -- with CONFIG_MODVERSIONS
# the loader skips that and compares symbol CRCs, which is why the stock
# device runs 6.6.77 with vendor modules built against 6.6.57 -- but whether
# every symbol it imports has the same CRC here.  Each module below was
# checked that way against this kernel.
#
# The charging stack used to be here in its entirety -- fifty-two modules that
# resolve against each other, so none of them could be replaced until all of
# them were.  They are all built from source now and none are taken from the
# prebuilts.  So is the SMB client: cifs and the netfs, DNS resolver, NLS and
# hashing helpers it pulls in are plain kernel code that only needed
# CONFIG_CIFS, which Xiaomi's own dada_perf.config sets and this tree had
# dropped.
#
# Four groups are excluded.
#
# Parts this board does not have: its device tree names the peach wlan chip,
# cs35l43 amplifiers and an ST NFC controller, so the prebuilts for the other
# wlan chips, for the aw882xx, tfa98xx, fs19xx, sia91xx and tas25xx amplifiers
# and for the NXP NFC controller are not shipped.
#
# The MTD stack -- mtd, mtd_blkdevs, mtdblock, block2mtd, chipreg and ofpart
# -- is on this device only to give mtdoops somewhere to write, and mtdoops is
# MIUI crash logging that is excluded below.  mtd_blkdevs would not bind here
# anyway: __get_mtd_device and __mtd_next_device changed shape since the
# kernel it was built against.
#
# MIUI instrumentation.  mi_stack, mi_trace, mi_damon, mi_wmark,
# mi_perf_memory, unfairmem, scene_swappiness, powersave, lb, sla, swinfo,
# hangdetect, proc_exit, process_monitor, dump_display, ftun, binder_prio,
# mibbr, minet, miwill and miicmpfilter bind to this kernel, but nothing here
# wants them: they are scheduler and memory tuning, boot and hang timing,
# backtrace capture and network extensions, none of it driving hardware and
# none of it exporting a symbol another module imports.  What does reference
# them does not survive the port -- /sys/kernel/mi_wmark/extra_free_kbytes is
# written by a vendor script gated on persist.vendor.spc.mi_extra_free_enable,
# and /proc/mi_mem_engine gets surfaceflinger's pid from a system partition
# init file that LineageOS rebuilds.  The rest is only chmod and chown lines
# that log a warning and carry on.
#
# Modules that will not bind: migt, perfmgr, mi_mempool, bootmonitor,
# mi_ubt_test, mtdoops, ufs_ffu, aw882xx, fs19xx, sia91xx, tfa98xx,
# xiaomi_touch, mi_thermal_interface and the wlan prebuilts for other chips
# each want a symbol this kernel does not export or exports with a different
# CRC.  migt alone wants eighty-one that exist only in Xiaomi's tree, from a
# frame-aware scheduler that is not published anywhere.  xiaomi_touch is the
# feature and telemetry layer above the touchscreen -- touch modes, gesture
# type, raw data for diagnostics, MiSight events and the under-display
# fingerprint press report -- and not the driver; synaptics_tcm2 is built from
# source and the QCOM source does not call into any of it, so the touchscreen
# works without it, and what goes with it is those features.
# mi_thermal_interface imports panel_event_notifier_register, whose signature
# takes a struct drm_panel, so its CRC follows the DRM core; theirs was
# computed against 6.6.30 and nothing here reproduces it.
#
# Everything still listed below does bind, and is shipped because there is no
# source for it: the CS35L43 amplifiers with their DSP and SDCA register
# helpers, the ST21NFC controller and its ST54 secure element GPIO, the USB-C
# analog accessory switch, OP-TEE, the camera log and messager devices -- the
# odm camera libraries open the first of those by name -- and the board glue
# Xiaomi wrote for this phone.

DADA_EXCLUDED_KERNEL_MODULES := \
    aw882xx_dlkm.ko \
    binder_prio.ko \
    block2mtd.ko \
    bootmonitor.ko \
    chipreg.ko \
    dump_display.ko \
    fs19xx_dlkm.ko \
    ftun.ko \
    hangdetect.ko \
    lb.ko \
    mi_damon.ko \
    mi_mempool.ko \
    mi_perf_memory.ko \
    mi_stack.ko \
    mi_thermal_interface.ko \
    mi_trace.ko \
    mi_ubt_test.ko \
    mi_wmark.ko \
    mibbr.ko \
    migt.ko \
    miicmpfilter.ko \
    minet.ko \
    miwill.ko \
    mtd.ko \
    mtd_blkdevs.ko \
    mtdblock.ko \
    mtdoops.ko \
    nxp-nci.ko \
    ofpart.ko \
    perfmgr.ko \
    powersave.ko \
    proc_exit.ko \
    process_monitor.ko \
    qca_cld3_kiwi_v2.ko \
    qca_cld3_peach.ko \
    qca_cld3_qca6750.ko \
    qca_cld3_wcn7750.ko \
    scene_swappiness.ko \
    sia91xx_dlkm.ko \
    sia91xx_tuning_dlkm.ko \
    sla.ko \
    swinfo.ko \
    tas25xx_dlkm.ko \
    tfa98xx_dlkm.ko \
    ufs_ffu.ko \
    unfairmem.ko \
    xiaomi_touch.ko

DADA_PREBUILT_KERNEL_MODULES := \
    cameralog.ko \
    cameramsger.ko \
    gpio-mi-t1.ko \
    hardwareinfo.ko \
    mitee_dlkm.ko \
    rsmc_driver.ko \
    stm_nfc_i2c.ko \
    stm_st54se_gpio.ko \
    xiaomi_wifi_gpio.ko

PRODUCT_COPY_FILES += \
    $(foreach m,$(DADA_PREBUILT_KERNEL_MODULES),\
        $(KERNEL_PATH)/vendor_dlkm/$(m):$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/$(m))
