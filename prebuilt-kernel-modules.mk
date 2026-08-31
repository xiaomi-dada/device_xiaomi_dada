# SPDX-License-Identifier: Apache-2.0
#
# Vendor modules with no source in this tree, so they cannot be built.
#
# Everything else the device loads is built from kernel/xiaomi/sm8750 and
# kernel/xiaomi/sm8750-modules-qcom.  A module binds to a kernel by the symbol
# CRCs of everything it imports, and those follow the source that kernel was
# built from, so copying a prebuilt over one of those would put back a module
# compiled against a different kernel.  Only the modules named here are taken
# from the prebuilts.
#
# The charging stack used to be here in its entirety -- fifty-two modules that
# resolve against each other, so none of them could be replaced until all of
# them were.  They are all built from source now and none are taken from the
# prebuilts.
#
# Three groups are left out entirely.
#
# Parts this board does not have: its device tree names the peach wlan chip
# and cs35l43 amplifiers, so the prebuilts for the other wlan chips and for
# the aw882xx, tfa98xx, fs19xx and sia91xx amplifiers are not shipped.
#
# MIUI instrumentation: migt, perfmgr, mi_mempool, bootmonitor, mi_ubt_test,
# mtdoops and ufs_ffu drive no hardware -- they are scheduler and memory
# tuning, boot timing, backtrace tests, crash logging to an MTD partition and
# a firmware update tool -- and each wants kernel symbols that exist only in
# Xiaomi's tree.  migt alone wants eighty-two of them, from a frame-aware
# scheduler that is not published anywhere.  xiaomi_touch belongs here too: it
# is the feature and telemetry layer above the touchscreen -- touch modes,
# gesture type, raw data for diagnostics, MiSight events and the under-display
# fingerprint press report -- and not the driver.  synaptics_tcm2 is built
# from source instead of taken from the prebuilts, and the QCOM source does
# not call into any of it, so the touchscreen works without it.  What goes
# with it is those features, the fingerprint press report among them.
#
# Panel event consumers: mi_thermal_interface imports
# panel_event_notifier_register, whose signature takes a struct drm_panel, so
# its CRC follows the DRM core.  Theirs was computed against 6.6.30 and
# nothing in this tree reproduces it on 6.6.142.  It only listens for the
# screen turning on and off and nothing depends on it.  mca_qcom_panel wanted
# the same symbol and was excluded for the same reason; it is built from
# source now, so its CRCs are this kernel's and it loads.

DADA_EXCLUDED_KERNEL_MODULES := \
    aw882xx_dlkm.ko \
    bootmonitor.ko \
    fs19xx_dlkm.ko \
    mi_mempool.ko \
    mi_thermal_interface.ko \
    mi_ubt_test.ko \
    migt.ko \
    mtdoops.ko \
    perfmgr.ko \
    qca_cld3_kiwi_v2.ko \
    qca_cld3_peach.ko \
    qca_cld3_qca6750.ko \
    qca_cld3_wcn7750.ko \
    sia91xx_dlkm.ko \
    tfa98xx_dlkm.ko \
    ufs_ffu.ko \
    xiaomi_touch.ko

DADA_PREBUILT_KERNEL_MODULES := \
    binder_prio.ko \
    block2mtd.ko \
    cameralog.ko \
    cameramsger.ko \
    chipreg.ko \
    cifs.ko \
    cifs_arc4.ko \
    cifs_md4.ko \
    cs35l43_dlkm.ko \
    cs_dsp.ko \
    dns_resolver.ko \
    dump_display.ko \
    ftun.ko \
    gpio-mi-t1.ko \
    hangdetect.ko \
    hardwareinfo.ko \
    lb.ko \
    mi_damon.ko \
    mi_perf_memory.ko \
    mi_stack.ko \
    mi_trace.ko \
    mi_wmark.ko \
    mibbr.ko \
    miicmpfilter.ko \
    minet.ko \
    mitee_dlkm.ko \
    miwill.ko \
    mtd.ko \
    mtd_blkdevs.ko \
    mtdblock.ko \
    netfs.ko \
    nls_ucs2_utils.ko \
    nxp-nci.ko \
    ofpart.ko \
    powersave.ko \
    proc_exit.ko \
    process_monitor.ko \
    rsmc_driver.ko \
    scene_swappiness.ko \
    sdca_registers_dlkm.ko \
    sia91xx_tuning_dlkm.ko \
    sla.ko \
    stm_nfc_i2c.ko \
    stm_st54se_gpio.ko \
    swinfo.ko \
    tas25xx_dlkm.ko \
    typec_analog_acc_dlkm.ko \
    unfairmem.ko \
    xiaomi_wifi_gpio.ko

PRODUCT_COPY_FILES += \
    $(foreach m,$(DADA_PREBUILT_KERNEL_MODULES),\
        $(KERNEL_PATH)/vendor_dlkm/$(m):$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/$(m))
