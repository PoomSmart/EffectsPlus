GO_EASY_ON_ME = 1
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EffectsPlus
EffectsPlus_FILES = Tweak.xm CINone.m
EffectsPlus_FRAMEWORKS = AssetsLibrary CoreGraphics CoreImage QuartzCore UIKit
EffectsPlus_PRIVATE_FRAMEWORKS = PhotoLibrary PhotoLibraryServices

include $(THEOS_MAKE_PATH)/tweak.mk

