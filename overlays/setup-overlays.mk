PRODUCT_PACKAGES += \
    AvatarPickerPixelOverlay \
    CellBroadcastReceiverOverlay \
    CellBroadcastServiceOverlay \
    GlanceableHubConfigOverlay \
    GlanceableHubSettingsConfigOverlay \
    GlanceableHubSettingsConfigOverlay2022 \
    GlanceableHubSysuiConfigOverlay \
    GoogleConfigOverlay \
    GoogleDeviceLockControllerOverlay \
    GoogleHealthConnectOverlay \
    GooglePermissionControllerOverlay \
    GoogleWebViewOverlay \
    ManagedProvisioningPixelOverlay \
    PixelAccessibilityMenu \
    PixelBuiltInPrintService \
    PixelConfigOverlay2018 \
    PixelConfigOverlay2019 \
    PixelConfigOverlay2019Midyear \
    PixelConfigOverlay2021 \
    PixelConfigOverlayCommon \
    PixelContactsProvider \
    PixelDeviceDiagnostics \
    PixelDocumentsUIGoogleOverlay \
    Pixelframework-res \
    PixelSettingsGoogle \
    PixelSettingsProvider \
    PixelSetupWizardOverlayExpressive \
    PixelSystemUIGoogle \
    PixelTelecom \
    PixelTeleService \
    SystemUIGXOverlay \
    UdfpsOverlay \
    WildlifeSettingsVpnOverlay2022

# Pixel
PRODUCT_PACKAGES += \
    GoogleSettingsOverlay \
    GoogleSystemUIOverlay

# When PixelLauncher is not included, override launcher_overlayable_package to
# com.android.launcher3 for Wallpaper & style (ThemePicker).
ifneq ($(TARGET_SUPPORT_PIXEL_LAUNCHER),true)
PRODUCT_PACKAGES += \
    Launcher3WallpaperOverlay
endif

# CarrierSettings overlay
PRODUCT_PACKAGES += \
    CarrierSettingsConfigOverlay \
    CarrierSettingsOverlay \
    CarrierSettingsProviderOverlay \
    CarrierSettingsSystemUIOverlay

# PixelLauncher overlay 
PRODUCT_PACKAGES += \
    PixelLauncherOverlay
