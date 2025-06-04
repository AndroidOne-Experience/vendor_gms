LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := MinimalPackage
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_OVERRIDES_PACKAGES += \
    CalendarGooglePrebuilt \
    PixelWallpapers2023 \
    RecorderPrebuilt_675788680 \
    WeatherPixelPrebuilt_24D1 \
    AccessibilityMenu \
    PrebuiltGmail \
    Drive \
    Maps \
    YouTube \
    YouTubeMusicPrebuilt \

LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := /dev/null
include $(BUILD_PREBUILT)