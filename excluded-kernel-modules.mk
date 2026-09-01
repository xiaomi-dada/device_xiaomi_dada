# SPDX-License-Identifier: Apache-2.0
#
# Vendor modules the stock device loads that this one does not.
#
# Everything the device does load is built from kernel/xiaomi/sm8750 and
# kernel/xiaomi/sm8750-modules-qcom; nothing is taken from the stock images.
# Where the reason for dropping a module is that it would not bind, that was
# decided on symbol CRCs and not on the kernel release in its vermagic -- with
# CONFIG_MODVERSIONS the loader skips the release, which is why the stock
# device runs 6.6.77 with vendor modules built against 6.6.57.
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
# A second round of MIUI instrumentation, this time in the first-stage list
# rather than the vendor_dlkm one: binder_gki, bootinfo, boottime, cpq,
# dcvs_main, debug_ext, kshrink_slabd, lz4asm, metis, mi_memory, mi_power,
# mi_schedule, mi_ubt, miev, the six millet modules, miloadtrace, mist,
# perf_helper, printk_enhance, rt_mod, sched-penalty, speed_touch and
# xm_power.  They are boot timing, backtrace capture, exception logging, an
# IO scheduler and a set of scheduler and memory tuners, none of them
# published anywhere and none of them needed to reach /vendor.  The stock
# modules.dep has much of the first-stage set depending on metis, mi_schedule,
# mist and miev, but that is Xiaomi's build: the modules here are built from
# QCOM and mainline source and from drivers/power/supply/mca, and every symbol
# each of them imports resolves without these.

# Modules with a device but no user here.  cameramsger biases camera thread
# placement through the scheduler vendor hooks and is driven over
# /dev/cam_msger by CameraMind and miui-cameraopt.jar; hardwareinfo publishes
# a board summary at /sys/kernel/hardware_info_to_dump/hardw_info that only
# /vendor/bin/hypsys_vendor reads; mitee_dlkm is the transport to Xiaomi's own
# trusted execution environment, whose whole userspace -- tee-supplicant,
# mitee_shell, miteelog, the mitrustedui HAL and the trusted applications in
# odm/mitee -- stays behind.  None of the four thousand blobs this port ships
# touches any of them, and no other module depends on them.
#
# rsmc_driver is the satellite modem stack.  It looks for a node with the
# xiaomi_rsmc compatible, which this board's device tree does not have, so it
# logs that it found none and stops; nothing else references it either.
#
# Nothing is shipped prebuilt any more.  What used to be here is built from
# source: the CS35L43 amplifiers with their DSP and SDCA register helpers and
# the USB-C analog accessory switch in the audio techpack, the camera log
# device in the camera techpack -- the odm camera libraries open it by name --
# the ST21NFC controller and its ST54 secure element GPIO under st/, and the
# WiFi SAR and T1 GPIO drivers in the kernel.

DADA_EXCLUDED_KERNEL_MODULES := \
    aw882xx_dlkm.ko \
    binder_gki.ko \
    binder_prio.ko \
    block2mtd.ko \
    bootinfo.ko \
    bootmonitor.ko \
    boottime.ko \
    cameramsger.ko \
    chipreg.ko \
    cpq.ko \
    dcvs_main.ko \
    debug_ext.ko \
    dump_display.ko \
    fs19xx_dlkm.ko \
    ftun.ko \
    hangdetect.ko \
    hardwareinfo.ko \
    kshrink_slabd.ko \
    lb.ko \
    lz4asm.ko \
    metis.ko \
    mi_damon.ko \
    mi_memory.ko \
    mi_mempool.ko \
    mi_perf_memory.ko \
    mi_power.ko \
    mi_schedule.ko \
    mi_stack.ko \
    mi_thermal_interface.ko \
    mi_trace.ko \
    mi_ubt.ko \
    mi_ubt_test.ko \
    mi_wmark.ko \
    mibbr.ko \
    miev.ko \
    migt.ko \
    miicmpfilter.ko \
    millet_binder.ko \
    millet_core.ko \
    millet_hs.ko \
    millet_oem_cgroup.ko \
    millet_pkg.ko \
    millet_sig.ko \
    miloadtrace.ko \
    minet.ko \
    mist.ko \
    mitee_dlkm.ko \
    miwill.ko \
    mtd.ko \
    mtd_blkdevs.ko \
    mtdblock.ko \
    mtdoops.ko \
    nxp-nci.ko \
    ofpart.ko \
    perf_helper.ko \
    perfmgr.ko \
    powersave.ko \
    printk_enhance.ko \
    proc_exit.ko \
    process_monitor.ko \
    qca_cld3_kiwi_v2.ko \
    qca_cld3_peach.ko \
    qca_cld3_qca6750.ko \
    qca_cld3_wcn7750.ko \
    rsmc_driver.ko \
    rt_mod.ko \
    scene_swappiness.ko \
    sched-penalty.ko \
    sia91xx_dlkm.ko \
    sia91xx_tuning_dlkm.ko \
    sla.ko \
    speed_touch.ko \
    swinfo.ko \
    tas25xx_dlkm.ko \
    tfa98xx_dlkm.ko \
    ufs_ffu.ko \
    unfairmem.ko \
    xiaomi_touch.ko \
    xm_power.ko
