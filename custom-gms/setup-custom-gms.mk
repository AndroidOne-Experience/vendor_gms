# Build custom-gms
PRODUCT_PACKAGES += \
	DevicePersonalizationPrebuiltPixel2024-U.32_V.7_playstore_aiai_20240725.00_RC08 \
	Photos \
	PrebuiltBugle \
	PrebuiltGmail \
	PrebuiltGmsCore \
	Velvet \
	YouTube

# GoogleExtServices
PRODUCT_COPY_FILES += \
	vendor/gms/custom-gms/GoogleExtServices/permissions/privapp_allowlist_com.google.android.ext.services.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp_allowlist_com.google.android.ext.services.xml
PRODUCT_PACKAGES += \
	GoogleExtServices

# Live Wallpaper - from crosshatch
TARGET_SUPPORT_LIVE_WALLPAPER ?= true

ifeq ($(TARGET_SUPPORT_LIVE_WALLPAPER),true)
PRODUCT_PACKAGES += \
    WallpapersBReel2018
endif

