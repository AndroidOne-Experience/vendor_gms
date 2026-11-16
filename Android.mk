LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := MinimalPackage
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_OVERRIDES_PACKAGES += \
	AccessibilityMenu \
	AndroidAutoStubPrebuilt \
	CalendarGooglePrebuilt \
	Drive \
	GooglePrintRecommendationService \
	Maps \
	PixelLiveWallpaperPrebuilt-26000013 \
	PrebuiltGmail \
	RecorderPrebuilt_725581069 \
	SafetyHubPrebuilt \
	talkback \
	WallpaperEffect \
	YouTube \
	YouTubeMusicPrebuilt

LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := /dev/null
include $(BUILD_PREBUILT)