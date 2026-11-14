#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/dada

# Inherit from sm8750-common
include device/xiaomi/sm8750-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := dada

# Display
TARGET_SCREEN_DENSITY := 520
$(call soong_config_set,qtidisplay,panel_dimensions_in_tenth_mm,true)
$(call soong_config_set,qtidisplay,xiaomi_rgb_notifier,true)

# Kernel
TARGET_KERNEL_CONFIG += vendor/xiaomi/dada.config
TARGET_KERNEL_ADDITIONAL_FLAGS += CONFIG_DADA_DTB=y
TARGET_MERGE_DTBOS_WILDCARD := dada-sm8750-overlay

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/properties/odm.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Include the proprietary files BoardConfig.
include vendor/xiaomi/dada/BoardConfigVendor.mk
