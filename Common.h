#import "../PS.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.EffectsPlus.plist"
#define PreferencesChangedNotification CFSTR("com.PS.EffectsPlus.prefs")
#define kFontSize 14
#define NORMAL_EFFECT_COUNT 8
#define EXTRA_EFFECT_COUNT 25
#define ENABLED_EFFECT @"EnabledEffects"
#define DISABLED_EFFECT @"DisabledEffects"
#define saveMode @"saveMode"
#define CINoneName @"CINone"

@interface CIFilter (Addition)
@property(retain, nonatomic) CIImage *inputImage;
//@property (nonatomic, copy) NSString *anotherFilter;
- (NSDictionary *)_outputProperties;
@end

@interface PLEditPhotoController (Addition)
- (void)EPSavePhoto;
- (void)ep_save:(int)mode;
@end

extern "C" NSString *PLLocalizedFrameworkString(NSString *key, NSString *comment);