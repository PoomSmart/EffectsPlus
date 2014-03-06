GO_EASY_ON_ME = 1
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = EffectsPlus
EffectsPlus_FILES = Tweak.xm
EffectsPlus_FRAMEWORKS = CoreImage UIKit CoreGraphics
EffectsPlus_PRIVATE_FRAMEWORKS = PhotoBoothEffects PhotoLibrary

include $(THEOS_MAKE_PATH)/tweak.mk

