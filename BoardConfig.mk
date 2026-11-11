#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/dada
KERNEL_PREBUILT_PATH := device/xiaomi/dada-kernel

# Inherit from sm8750-common
include device/xiaomi/sm8750-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := dada

# Display
TARGET_SCREEN_DENSITY := 520

# Kernel
TARGET_PREBUILT_KERNEL := $(KERNEL_PREBUILT_PATH)/Image

BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PREBUILT_PATH)/dtbs
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PREBUILT_PATH)/dtbo.img

# Kernel modules
BOARD_SYSTEM_DLKM_SRC := $(KERNEL_PREBUILT_PATH)/system_dlkm

BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(KERNEL_PREBUILT_PATH)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(KERNEL_PREBUILT_PATH)/vendor_dlkm/modules.blocklist
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PREBUILT_PATH)/vendor_dlkm/modules.load))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(KERNEL_PREBUILT_PATH)/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(KERNEL_PREBUILT_PATH)/vendor_ramdisk/modules.blocklist
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PREBUILT_PATH)/vendor_ramdisk/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PREBUILT_PATH)/vendor_ramdisk/modules.load.recovery))

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/properties/odm.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Include the proprietary files BoardConfig.
include vendor/xiaomi/dada/BoardConfigVendor.mk
