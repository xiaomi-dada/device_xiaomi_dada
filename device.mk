#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from sm8750-common
$(call inherit-product, device/xiaomi/sm8750-common/common.mk)

# Get non-open-source specific aspects
$(call inherit-product, vendor/xiaomi/dada/dada-vendor.mk)

# Overlays
PRODUCT_PACKAGES += \
    ApertureResDada \
    FrameworksResDada \
    SettingsOverlayDada \
    SystemUIResDada

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
