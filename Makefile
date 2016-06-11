DEBUG = 0
PACKAGE_VERSION = 1.3-3

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = EffectsPlusTweak
SUBPROJECTS = Tweak Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
