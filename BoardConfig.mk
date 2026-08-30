#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/dada
KERNEL_PATH := $(DEVICE_PATH)-kernel

# Inherit from sm8750-common
include device/xiaomi/sm8750-common/BoardConfigCommon.mk

# Display
TARGET_SCREEN_DENSITY := 520

# Dtb/o
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PATH)/dtb

# Kernel
TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8750
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/sun_perf.config \
    vendor/dada_perf.config

# Kernel modules.
#
# The stock prebuilts were built against the android15-6.6 KMI; the
# interconnect, cfg80211 and DRM-DP symbol CRCs have moved since, so the
# techpacks have to be rebuilt against the kernel above rather than copied.

# Kernel modules.
#
# The stock prebuilts were built against a kernel close to Xiaomi's own; the
# symbol CRCs of anything outside the frozen KMI track the exact source, so the
# techpacks are rebuilt here rather than copied.
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8750-modules-qcom
TARGET_KERNEL_EXT_MODULES := \
    qcom/opensource/mmrm-driver \
    qcom/opensource/mm-drivers/hw_fence \
    qcom/opensource/mm-drivers/msm_ext_display \
    qcom/opensource/mm-drivers/sync_fence \
    qcom/opensource/audio-kernel \
    qcom/opensource/securemsm-kernel \
    qcom/opensource/synx-kernel \
    qcom/opensource/camera-kernel \
    qcom/opensource/data-kernel/drivers/smem-mailbox \
    qcom/opensource/datarmnet-ext/mem \
    qcom/opensource/dataipa/drivers/platform/msm \
    qcom/opensource/datarmnet/core \
    qcom/opensource/datarmnet-ext/aps \
    qcom/opensource/datarmnet-ext/offload \
    qcom/opensource/datarmnet-ext/perf \
    qcom/opensource/datarmnet-ext/perf_tether \
    qcom/opensource/datarmnet-ext/sch \
    qcom/opensource/datarmnet-ext/shs \
    qcom/opensource/datarmnet-ext/wlan \
    qcom/opensource/display-drivers/msm \
    qcom/opensource/dsp-kernel \
    qcom/opensource/eva-kernel \
    qcom/opensource/graphics-kernel \
    qcom/opensource/spu-kernel \
    qcom/opensource/touch-drivers \
    qcom/opensource/video-driver \
    qcom/opensource/wlan/platform \
    qcom/opensource/wlan/qcacld-3.0 \
    qcom/opensource/bt-kernel

# Kernel modules
include $(DEVICE_PATH)/prebuilt-kernel-modules.mk

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(filter-out $(DADA_EXCLUDED_KERNEL_MODULES),\
    $(strip $(shell cat $(KERNEL_PATH)/vendor_ramdisk/modules.load)))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(filter-out $(DADA_EXCLUDED_KERNEL_MODULES),\
    $(strip $(shell cat $(KERNEL_PATH)/vendor_ramdisk/modules.load.recovery)))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(filter-out $(DADA_EXCLUDED_KERNEL_MODULES),\
    $(strip $(shell cat $(KERNEL_PATH)/vendor_dlkm/modules.load)))

# The touchscreen driver is built from source now, and the techpack names it
# synaptics_tcm2_ts rather than synaptics_tcm2.  It sits on QTI Touch
# Services, so that goes in ahead of it.
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(patsubst synaptics_tcm2.ko,qts.ko synaptics_tcm2_ts.ko,\
    $(BOARD_VENDOR_KERNEL_MODULES_LOAD))

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(KERNEL_PATH)/system_dlkm_flatten/,$(TARGET_COPY_OUT_SYSTEM_DLKM)/flatten/lib/modules) \
    $(call find-copy-subdir-files,*,$(KERNEL_PATH)/system_dlkm/,$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/6.6.77-android15-8-g63ce7556864c-ab13994517-4k)

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/properties/odm.prop

# Inherit from the proprietary version
include vendor/xiaomi/dada/BoardConfigVendor.mk

# Firmware
-include vendor/xiaomi/dada-firmware/BoardConfigVendor.mk
