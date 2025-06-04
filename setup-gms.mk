# Inherit GMS
$(call inherit-product, vendor/gms/partner-gms/partner-gms-vendor.mk)

# Build Split GMS
$(call inherit-product, vendor/gms/custom-gms/setup-custom-gms.mk)

# Build GMS overlays
$(call inherit-product, vendor/gms/overlays/setup-overlays.mk)

# Build offline voice recognition models
GMS_VOICE_MODEL_INCLUDED ?= true

ifeq ($(GMS_VOICE_MODEL_INCLUDED),true)
  $(call inherit-product, vendor/gms/voice/voice-vendor.mk)
endif

# Build Pixel Sounds
$(call inherit-product, vendor/gms/media/media-vendor.mk)

# Default ringtone/notification/alarm sounds
PRODUCT_PRODUCT_PROPERTIES += \
	ro.config.ringtone=The_big_adventure.ogg \
    ro.config.notification_sound=Popcorn.ogg \
    ro.config.alarm_alert=Bright_morning.ogg

# Gboard Props
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.ime.bs_theme=true \
    ro.com.google.ime.theme_id=5 \
    ro.com.google.ime.system_lm_dir=/product/usr/share/ime/google/d3_lms

# GMS Props
PRODUCT_PRODUCT_PROPERTIES += \
    ro.opa.eligible_device=true

# SetupWizard Props
PRODUCT_PRODUCT_PROPERTIES += \
    ro.setupwizard.enterprise_mode=1 \
    ro.setupwizard.esim_cid_ignore=00000001 \
    setupwizard.feature.baseline_setupwizard_enabled=true \
    setupwizard.feature.day_night_mode_enabled=true \
    setupwizard.feature.portal_notification=true \
    setupwizard.feature.enable_quick_start_flow=true \
    setupwizard.feature.enable_restore_anytime=true \
    setupwizard.feature.enable_wifi_tracker=true \
    setupwizard.feature.lifecycle_refactoring=true \
    setupwizard.feature.notification_refactoring=true \
    setupwizard.feature.show_pai_screen_in_main_flow.carrier1839=false \
    setupwizard.feature.show_pixel_tos=true \
    setupwizard.feature.show_support_link_in_deferred_setup=false \
    setupwizard.feature.skip_button_use_mobile_data.carrier1839=true \
    setupwizard.personal_safety_suw_enabled=true \
    setupwizard.theme=glif_v4_light

# Remove Packages
TARGET_SUPPORT_MINIMAL_GAPPS ?= false

ifeq ($(TARGET_SUPPORT_MINIMAL_GAPPS),true)
PRODUCT_PACKAGES += \
    MinimalPackage
GMS_VOICE_MODEL_INCLUDED := false
TARGET_SUPPORT_LIVE_WALLPAPER := false
endif