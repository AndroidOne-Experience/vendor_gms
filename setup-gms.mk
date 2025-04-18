# Inherit GMS
$(call inherit-product, vendor/gms/partner-gms/partner-gms-vendor.mk)

# Build Split GMS
$(call inherit-product, vendor/gms/custom-gms/setup-custom-gms.mk)

# Build GMS overlays
$(call inherit-product, vendor/gms/overlays/setup-overlays.mk)

# Build offline voice recognition models
$(call inherit-product, vendor/gms/voice/voice-vendor.mk)

# Build Pixel Sounds
$(call inherit-product, vendor/gms/media/media-vendor.mk)
