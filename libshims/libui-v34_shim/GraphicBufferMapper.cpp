/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

// The camera blobs were built against Android 15's libui, which is
// layout-compatible with libui-v34 but adds two GraphicBufferMapper entry
// points. Implement them on top of the libui-v34 API.

#include <android-base/unique_fd.h>
#include <cutils/native_handle.h>
#include <sync/sync.h>
#include <utils/Errors.h>

namespace android {
class Rect;
}  // namespace android

using android::Rect;
using android::status_t;
using android::base::unique_fd;

extern "C" {

// android::GraphicBufferMapper::lock(buffer_handle_t, uint32_t, const Rect&, void**, int32_t*,
//                                    int32_t*), provided by libui-v34
status_t _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPvPiS9_(
        void* thisptr, buffer_handle_t handle, uint32_t usage, const Rect& bounds, void** vaddr,
        int32_t* outBytesPerPixel, int32_t* outBytesPerStride);

// android::GraphicBufferMapper::unlockAsync(buffer_handle_t, int*), provided by libui-v34
status_t _ZN7android19GraphicBufferMapper11unlockAsyncEPK13native_handlePi(void* thisptr,
                                                                          buffer_handle_t handle,
                                                                          int* fenceFd);

// android::GraphicBufferMapper::lock(buffer_handle_t, uint32_t, const Rect&, void**)
status_t _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPv(
        void* thisptr, buffer_handle_t handle, uint32_t usage, const Rect& bounds, void** vaddr) {
    return _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPvPiS9_(
            thisptr, handle, usage, bounds, vaddr, nullptr, nullptr);
}

// android::GraphicBufferMapper::unlock(buffer_handle_t, base::unique_fd*)
status_t
_ZN7android19GraphicBufferMapper6unlockEPK13native_handlePNS_4base14unique_fd_implINS4_13DefaultCloserEEE(
        void* thisptr, buffer_handle_t handle, unique_fd* outFence) {
    int fenceFd = -1;
    status_t status =
            _ZN7android19GraphicBufferMapper11unlockAsyncEPK13native_handlePi(thisptr, handle,
                                                                             &fenceFd);
    unique_fd fence(fenceFd);
    if (outFence) {
        *outFence = std::move(fence);
    } else if (fence.ok()) {
        sync_wait(fence.get(), -1);
    }
    return status;
}

}  // extern "C"
