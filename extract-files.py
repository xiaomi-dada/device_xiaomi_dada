#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/xiaomi/dada',
    'device/xiaomi/sm8750-common',
    'hardware/qcom-caf/sm8750',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/xiaomi/sm8750-common',
]

# Xiaomi built these frozen camera interfaces themselves (camera.device V2
# against graphics.common V5), and the camera provider expects their
# parcelable layouts. Ship and link Xiaomi's copies under a _prebuilt name.
xiaomi_camera_aidl_libs = (
    'android.hardware.camera.common-V1-ndk',
    'android.hardware.camera.device-V2-ndk',
    'android.hardware.camera.metadata-V2-ndk',
    'android.hardware.camera.provider-V2-ndk',
    'android.hardware.graphics.common-V5-ndk',
    'vendor.qti.hardware.camera.offlinecamera-V2-ndk',
)


def xiaomi_camera_aidl_fixup() -> blob_fixup:
    fixup = blob_fixup()
    for lib in xiaomi_camera_aidl_libs:
        fixup.replace_needed(f'{lib}.so', f'{lib}_prebuilt.so')
    return fixup


blob_fixups: blob_fixups_user_type = {
    # tinyxml2 11 widened the XMLDocument members, so blobs built against the
    # older headers need the matching library.
    (
        'odm/lib64/camera/plugins/com.xiaomi.plugin.anchor.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineawbideal.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineb2y.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineformatconvertor.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinehdrraw2y.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineheic.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinei2y.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinejpeg.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinemfnr.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinemlawb.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinetintless.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlinetintlesshdr.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineyuveis.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineyuvreprocess.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.offlineyuvsplit.so',
        'odm/lib64/com.xiaomi.plugin.ecdengine.so',
        'odm/lib64/libcamxcoreutils.so',
        'odm/lib64/libcamxods.so',
        'odm/lib64/libmicamera_hal_core.so',
        'odm/lib64/libsimulation.so',
    ): blob_fixup()
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    (
        'odm/etc/camera/enhance_motiontuning.xml',
        'odm/etc/camera/motiontuning.xml',
        'odm/etc/camera/snsc_bokeh_motiontuning.xml',
        'odm/etc/camera/snsc_enhance_motiontuning.xml',
        'odm/etc/camera/snsc_motiontuning.xml',
        'odm/etc/camera/snsc_noface_motiontuning.xml',
    ): blob_fixup()
        .regex_replace('xml=version', 'xml version'),
    # Xiaomi's android.hardware.biometrics.fingerprint-V5-ndk carries the
    # interface hash of the frozen V4, so it is V4 under another name.
    'odm/bin/hw/mfp-daemon': blob_fixup()
        .replace_needed('android.hardware.biometrics.fingerprint-V5-ndk.so', 'android.hardware.biometrics.fingerprint-V4-ndk.so')
        .replace_needed('android.hardware.sensors-V2-ndk.so', 'android.hardware.sensors-V3-ndk.so'),
    (
        'odm/bin/hw/vendor.xiaomi.hw.touchfeature-service',
        'odm/lib64/hw/camera.qcom.so',
    ): blob_fixup()
        .replace_needed('android.hardware.sensors-V2-ndk.so', 'android.hardware.sensors-V3-ndk.so'),
    (
        'odm/lib64/hw/fingerprint.qcom_us.so',
        'odm/lib64/libqc_hal.so',
    ): blob_fixup()
        .replace_needed('android.hardware.biometrics.fingerprint-V5-ndk.so', 'android.hardware.biometrics.fingerprint-V4-ndk.so'),
    # The vendor libnativewindow stub exports these without a version.
    (
        'odm/lib64/libAncHumanPreviewBokeh.so',
        'odm/lib64/libMiEmojiEffect.so',
        'odm/lib64/libMiPhotoFilter.so',
        'odm/lib64/libTrueSight.so',
        'odm/lib64/libwa_widelens_undistort.so',
    ): blob_fixup()
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_isSupported')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_lockPlanes')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),
    # These link both allocator V1 and V2, ahead of V1, and V2 exports
    # every V1 symbol.
    (
        'odm/lib64/camera/components/com.qti.node.dewarp.so',
        'odm/lib64/hw/com.qti.chi.override.so',
        'odm/lib64/libchifeature2.so',
    ): blob_fixup()
        .remove_needed('android.hardware.graphics.allocator-V1-ndk.so'),
    # These use the API of the libultrahdr that Xiaomi ships, not the
    # platform's newer one.
    (
        'odm/lib64/camera/plugins/com.xiaomi.plugin.gainmap.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.jpegrAggr.so',
    ): blob_fixup()
        .replace_needed('libultrahdr.so', 'libultrahdr_prebuilt.so'),
    # The CIT sensor service uses no graphics.common or sensors AIDL symbols,
    # so link the versions we ship.
    'odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl': blob_fixup()
        .replace_needed('android.hardware.graphics.common-V5-ndk.so', 'android.hardware.graphics.common-V7-ndk.so')
        .replace_needed('android.hardware.sensors-V2-ndk.so', 'android.hardware.sensors-V3-ndk.so')
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    (
        'odm/lib64/camx.device-impl.so',
        'odm/lib64/libmicamera_aidl_device.so',
        'odm/lib64/libmicamera_aidl_utils.so',
        'vendor/lib64/android.hardware.camera.common-V1-ndk_prebuilt.so',
        'vendor/lib64/android.hardware.camera.device-V2-ndk_prebuilt.so',
        'vendor/lib64/android.hardware.camera.metadata-V2-ndk_prebuilt.so',
        'vendor/lib64/android.hardware.camera.provider-V2-ndk_prebuilt.so',
        'vendor/lib64/android.hardware.graphics.common-V5-ndk_prebuilt.so',
        'vendor/lib64/vendor.qti.hardware.camera.offlinecamera-V2-ndk_prebuilt.so',
    ): xiaomi_camera_aidl_fixup(),
    (
        'odm/bin/hw/vendor.qti.camera.provider-service_64',
        'odm/lib64/libmicamera_aidl_provider.so',
    ): xiaomi_camera_aidl_fixup()
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    'odm/lib64/vendor.qti.hardware.camera.offlinecamera-service-impl.so': xiaomi_camera_aidl_fixup()
        .remove_needed('android.hardware.graphics.allocator-V1-ndk.so'),
    'odm/lib64/libcamximageformatutils.so': blob_fixup()
        .remove_needed('android.hardware.graphics.allocator-V1-ndk.so')
        .replace_needed('vendor.qti.hardware.display.config-V2-ndk.so', 'vendor.qti.hardware.display.config-V12-ndk.so'),
    # The camera provider loads camera.device V2 well before V1, so on stock
    # these already bind to V2's symbols.
    (
        'vendor/lib64/vendor.xiaomi.hardware.camera.injection-V1-ndk.so',
        'vendor/lib64/vendor.xiaomi.hardware.camera.injection-client.so',
        'vendor/lib64/vendor.xiaomi.hardware.camera.injection-service.so',
    ): xiaomi_camera_aidl_fixup()
        .replace_needed('android.hardware.camera.device-V1-ndk.so', 'android.hardware.camera.device-V2-ndk_prebuilt.so'),
    # Android 16 added a member to android::GraphicBuffer, which these blobs
    # allocate themselves. libui-v34 still has the Android 15 layout.
    (
        'odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl',
        'odm/lib64/camera/components/com.arcsoft.node.videobokeh.so',
        'odm/lib64/camera/components/com.mi.node.aiasd.so',
        'odm/lib64/camera/components/com.mi.node.facealign.so',
        'odm/lib64/camera/components/com.mi.node.tsskinbeautifier.so',
        'odm/lib64/camera/components/com.mi.node.videofilter.so',
        'odm/lib64/camera/components/com.mi.node.videonight.so',
        'odm/lib64/camera/components/com.qti.node.dewarp.so',
        'odm/lib64/camera/components/com.qti.node.intelligentfocus.so',
        'odm/lib64/camera/components/com.xiaomi.node.gme.so',
        'odm/lib64/camera/components/com.xiaomi.node.misv2.so',
        'odm/lib64/camera/components/com.xiaomi.node.misv3.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.arcsoftvideobokeh.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.beautydeformation.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.facealignpreview.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.filter.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.skinbeautifierpreview.so',
        'odm/lib64/camera/plugins/com.xiaomi.plugin.tsskinbeautifier.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.aihighlight.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.bokehrawhdr.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.bokehsmartae.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.default.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.dsac.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.ell.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.fusion.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.hdr.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.leica.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.mfnr.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.motion.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.nightmotion.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.nightmotionzslbanding.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.single.so',
        'odm/lib64/camera/zsl/com.xiaomi.zsl.sr.so',
        'odm/lib64/camx.device-impl.so',
        'odm/lib64/com.xiaomi.camhal.extmodel.ec_executor.so',
        'odm/lib64/com.xiaomi.camhal.overlap.so',
        'odm/lib64/com.xiaomi.camhal.submodel.camxfrag.so',
        'odm/lib64/com.xiaomi.camhal.submodel.chifrag.so',
        'odm/lib64/com.xiaomi.immunesystem.client.so',
        'odm/lib64/com.xiaomi.immunesystem.core.so',
        'odm/lib64/com.xiaomi.immunesystem.hook.mivi.so',
        'odm/lib64/com.xiaomi.immunesystem.hook.mtkhal.so',
        'odm/lib64/com.xiaomi.messagecenter.so',
        'odm/lib64/libcom.xiaomi.ecoenginemonitor.so',
        'odm/lib64/libcom.xiaomi.grallocutils.so',
        'odm/lib64/libcom.xiaomi.ionutils.so',
        'odm/lib64/libcom.xiaomi.mawutilsold.so',
        'odm/lib64/libcom.xiaomi.mawutils.so',
        'odm/lib64/libcom.xiaomi.pluginutils.so',
        'odm/lib64/libcom.xiaomi.sensorpolicy.so',
        'odm/lib64/libecoengine.so',
        'odm/lib64/libmialgoengine.so',
        'odm/lib64/libmicamera_hal_core.so',
        'odm/lib64/libmicamera_hal_policy.so',
        'odm/lib64/libmis_plugin_his.so',
        'odm/lib64/vendor.qti.hardware.camera.offlinecamera-service-impl.so',
        'vendor/lib64/vendor.xiaomi.hardware.camera.injection-service.so',
    ): blob_fixup()
        .replace_needed('libui.so', 'libui-v34.so'),
    # These also use the two GraphicBufferMapper calls Android 15 introduced.
    (
        'odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl',
        'odm/lib64/camx.device-impl.so',
        'odm/lib64/libmicamera_hal_core.so',
        'odm/lib64/vendor.qti.hardware.camera.offlinecamera-service-impl.so',
    ): blob_fixup()
        .add_needed('libui-v34_shim.so'),
    # Android 16 also grew image_io's JpegInfoBuilder, which these construct.
    (
        'odm/lib64/camera/plugins/com.xiaomi.plugin.jpegrAggr.so',
        'vendor/lib64/libultrahdr_prebuilt.so',
    ): blob_fixup()
        .replace_needed('libimage_io.so', 'libimage_io_prebuilt.so'),
    'vendor/lib64/libcameraopt.so': blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
    'vendor/lib64/libultrahdr_prebuilt.so': blob_fixup()
        .replace_needed('libjpegdecoder.so', 'libjpegdecoder_prebuilt.so')
        .replace_needed('libjpegencoder.so', 'libjpegencoder_prebuilt.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'dada',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
    check_elf=True,
    add_firmware_proprietary_file=True,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'sm8750-common', module.vendor
    )
    utils.run()
