# Build custom-gms
PRODUCT_PACKAGES += \
	DevicePersonalizationPrebuiltPixel2025-playstore_aiai_20250306.00_RC10 \
	Maps \
	Photos \
	PrebuiltBugle \
	PrebuiltGmail \
	PrebuiltGmsCoreVic \
	Velvet \
	YouTube

# Pixel Launcher
TARGET_SUPPORT_PIXEL_LAUNCHER ?= true

ifeq ($(TARGET_SUPPORT_PIXEL_LAUNCHER),true)
PRODUCT_PACKAGES += \
    NexusLauncherRelease \
	NexusLauncherRelease-Overlay
endif

# GoogleExtServices
PRODUCT_PACKAGES += \
	GoogleExtServices \
	privapp_allowlist_com.google.android.ext.services.xml

# Build Tensorflow & symlink to MagicPortrait
PRODUCT_PACKAGES += \
    libtensorflowlite_jni \
    MagicPortraitSymLink
