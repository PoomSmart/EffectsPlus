include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = EffectsPlusPref
EffectsPlusPref_FILES = Preferences.mm
EffectsPlusPref_FRAMEWORKS = CoreGraphics Social UIKit
EffectsPlusPref_PRIVATE_FRAMEWORKS = PhotoLibrary Preferences
EffectsPlusPref_INSTALL_PATH = /Library/PreferenceBundles
EffectsPlusPref_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EffectsPlusPref.plist$(ECHO_END)