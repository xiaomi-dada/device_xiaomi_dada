#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# GApps build (WITH_GMS=true): MindTheGapps (vendor/gapps) built in, named
# lineage-<version>-<date>-UNOFFICIAL-GAPPS-dada. The build ID must be set before
# Lineage's config, which derives the version from it.
ifeq ($(WITH_GMS),true)
TARGET_UNOFFICIAL_BUILD_ID := GAPPS
$(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)
# Its makefiles add $(LOCAL_PATH) as their namespace, which inherit-product doesn't set.
PRODUCT_SOONG_NAMESPACES += \
    vendor/gapps/arm64 \
    vendor/gapps/common
endif

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from dada device
$(call inherit-product, device/xiaomi/dada/device.mk)

PRODUCT_NAME := lineage_dada
PRODUCT_DEVICE := dada
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := 24129PN74G

PRODUCT_SYSTEM_NAME := dada_eea
PRODUCT_SYSTEM_DEVICE := dada

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="dada_eea-user 15 AQ3A.250226.002 OS3.0.305.0.WOCEUXM release-keys" \
    BuildFingerprint=Xiaomi/dada_eea/dada:15/AQ3A.250226.002/OS3.0.305.0.WOCEUXM:user/release-keys \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Updates for each build flavour, from its own index
PRODUCT_PRODUCT_PROPERTIES += \
    lineage.updater.uri=https://dl.ilovekt.com/lineage/{device}/$(if $(filter true,$(WITH_GMS)),gapps,vanilla)/{incr}.json
