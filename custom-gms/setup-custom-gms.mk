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