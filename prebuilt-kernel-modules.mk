# SPDX-License-Identifier: Apache-2.0
#
# Vendor modules with no source in this tree, so they cannot be built.
# Everything else the device loads is built from kernel/xiaomi/sm8750 and
# kernel/xiaomi/sm8750-modules-qcom; copying a prebuilt over one of those
# would replace a module built against this kernel with one built against
# another, so only the modules listed here are taken from the prebuilts.
#
# Variants for parts this board does not have are left out: its device tree
# names the peach wlan chip and cs35l43 amplifiers, so the prebuilt modules for
# the other wlan chips and for the aw882xx, tfa98xx, fs19xx and sia91xx
# amplifiers are not shipped.

# Parts this board does not have.  They are in the stock module load list, so
# they have to be taken out of it as well as not shipped.
DADA_EXCLUDED_KERNEL_MODULES := \
    qca_cld3_kiwi_v2.ko \
    qca_cld3_peach.ko \
    qca_cld3_qca6750.ko \
    qca_cld3_wcn7750.ko \
    aw882xx_dlkm.ko \
    fs19xx_dlkm.ko \
    sia91xx_dlkm.ko \
    tfa98xx_dlkm.ko

DADA_PREBUILT_KERNEL_MODULES := \
    binder_prio.ko \
    block2mtd.ko \
    bootmonitor.ko \
    bq27z561.ko \
    cameralog.ko \
    cameramsger.ko \
    charger_partition.ko \
    chipreg.ko \
    cifs_arc4.ko \
    cifs.ko \
    cifs_md4.ko \
    cs35l43_dlkm.ko \
    cs_dsp.ko \
    dns_resolver.ko \
    dump_display.ko \
    ftun.ko \
    gpio-mi-t1.ko \
    hangdetect.ko \
    hardwareinfo.ko \
    hl7603.ko \
    lb.ko \
    mca_adsp_glink.ko \
    mca_basic_wireless.ko \
    mca_bmd.ko \
    mca_buckchg_jeita.ko \
    mca_business_battery_comp.ko \
    mca_business_charger_comp.ko \
    mca_business_misc_comp.ko \
    mca_charge_interface.ko \
    mca_charge_mievent.ko \
    mca_charger_thermal.ko \
    mca_common.ko \
    mca_connector_antiburn.ko \
    mca_event.ko \
    mca_hwid.ko \
    mca_ibat_ocp_monitor.ko \
    mca_log.ko \
    mca_lpd_detect.ko \
    mca_parse_dts.ko \
    mca_path_control.ko \
    mca_pd_auth.ko \
    mca_platform_base.ko \
    mca_platform_bc12_class.ko \
    mca_platform_buckchg_class.ko \
    mca_platform_cp_class.ko \
    mca_platform_fg_ic_ops.ko \
    mca_platform_loadsw_class.ko \
    mca_platform_wireless_class.ko \
    mca_protocol_class.ko \
    mca_protocol_pd_class.ko \
    mca_protocol_qc_class.ko \
    mca_qcom_panel.ko \
    mca_qcom_smem.ko \
    mca_qcom_subpmic_proxy.ko \
    mca_qcom_sysfs.ko \
    mca_quick_wireless.ko \
    mca_smart_charge.ko \
    mca_soc_limit.ko \
    mca_strategy_buckchg.ko \
    mca_strategy_class.ko \
    mca_strategy_fg_class.ko \
    mca_strategy_fg_comp.ko \
    mca_strategy_quickchg.ko \
    mca_sysfs.ko \
    mca_vbat_ovp_monitor.ko \
    mca_wireless_revchg.ko \
    mca_workqueue.ko \
    mibbr.ko \
    mi_damon.ko \
    migt.ko \
    miicmpfilter.ko \
    mi_mempool.ko \
    minet.ko \
    mi_perf_memory.ko \
    mi_stack.ko \
    mitee_dlkm.ko \
    mi_thermal_interface.ko \
    mi_trace.ko \
    mi_ubt_test.ko \
    miwill.ko \
    mi_wmark.ko \
    mtd_blkdevs.ko \
    mtdblock.ko \
    mtd.ko \
    mtdoops.ko \
    netfs.ko \
    nls_ucs2_utils.ko \
    nuvolta_1652.ko \
    nxp-nci.ko \
    ofpart.ko \
    perfmgr.ko \
    powersave.ko \
    process_monitor.ko \
    proc_exit.ko \
    qcom_adsp_pd_protocol.ko \
    rsmc_driver.ko \
    sc8581.ko \
    scene_swappiness.ko \
    sdca_registers_dlkm.ko \
    sia91xx_tuning_dlkm.ko \
    sla.ko \
    stm_nfc_i2c.ko \
    stm_st54se_gpio.ko \
    swinfo.ko \
    synaptics_tcm2.ko \
    tas25xx_dlkm.ko \
    typec_analog_acc_dlkm.ko \
    ufs_ffu.ko \
    unfairmem.ko \
    xiaomi_touch.ko \
    xiaomi_wifi_gpio.ko

PRODUCT_COPY_FILES += \
    $(foreach m,$(DADA_PREBUILT_KERNEL_MODULES),\
        $(KERNEL_PATH)/vendor_dlkm/$(m):$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/$(m))

