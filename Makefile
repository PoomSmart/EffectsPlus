DEBUG = 0
TARGET = iphone:latest:7.0
PACKAGE_VERSION = 1.3.4

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = EffectsPlusTweak
SUBPROJECTS = Tweak Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk