#import "../PS.h"

NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.EffectsPlus.plist";
CFStringRef const PreferencesChangedNotification = CFSTR("com.PS.EffectsPlus.prefs");
#define kFontSize 14
#define NORMAL_EFFECT_COUNT 8
#define EXTRA_EFFECT_COUNT 25
NSString *const ENABLED_EFFECT = @"EnabledEffects";
NSString *const DISABLED_EFFECT = @"DisabledEffects";
NSString *const saveMode = @"saveMode";
NSString *const CINoneName = @"CINone";

extern "C" NSString *PLLocalizedFrameworkString(NSString *key, NSString *comment);

@interface CIFilter (Addition)
@property(retain, nonatomic) CIImage *inputImage;
//@property (nonatomic, copy) NSString *anotherFilter;
- (NSDictionary *)_outputProperties;
@end

@interface PLEditPhotoController (Addition)
- (void)EPSavePhoto;
- (void)ep_save:(int)mode;
@end

static NSString *displayNameFromCIFilterName(NSString *name)
{
	#define EPReturn1(name1, name2) if ([name isEqualToString:name2]) return name1
	#define EPReturn(name3, name4) else if ([name isEqualToString:name4]) return name3
	EPReturn1(PLLocalizedFrameworkString(@"FILTER_MONO", nil), @"CIPhotoEffectMono");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_NOIR", nil), @"CIPhotoEffectNoir");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_FADE", nil), @"CIPhotoEffectFade");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_CHROME", nil), @"CIPhotoEffectChrome");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_NONE", nil), CINoneName);
	EPReturn(PLLocalizedFrameworkString(@"FILTER_PROCESS", nil), @"CIPhotoEffectProcess");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_TRANSFER", nil), @"CIPhotoEffectTransfer");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_INSTANT", nil), @"CIPhotoEffectInstant");
	EPReturn(PLLocalizedFrameworkString(@"FILTER_TONAL", nil), @"CIPhotoEffectTonal");
	
	EPReturn(@"Sepia", @"CISepiaTone");
	EPReturn(@"Vibrance", @"CIVibrance");
	EPReturn(@"Invert", @"CIColorInvert");
	EPReturn(@"Replace", @"CIColorMonochrome");
	EPReturn(@"Posterize", @"CIColorPosterize");
	EPReturn(@"Gloom", @"CIGloom");
	EPReturn(@"Bloom", @"CIBloom");
	EPReturn(@"Sharp", @"CISharpenLuminance");
	EPReturn(@"SRGB", @"CILinearToSRGBToneCurve");
	EPReturn(@"Pixel", @"CIPixellate");
	EPReturn(@"Blur", @"CIGaussianBlur");
	EPReturn(@"False", @"CIFalseColor");
	EPReturn(@"Hole", @"CIHoleDistortion");
	EPReturn(@"Twirl", @"CITwirlDistortion");
	EPReturn(@"Circle", @"CICircleSplashDistortion");
	EPReturn(@"Circular", @"CICircularScreen");
	EPReturn(@"Line", @"CILineScreen");
	
	EPReturn(@"X-Ray", @"CIXRay");
	EPReturn(@"Mirrors", @"CIWrapMirror");
	EPReturn(@"Stretch", @"CIStretch");
	EPReturn(@"Mirror", @"CIMirror");
	EPReturn(@"Triangle", @"CITriangleKaleidoscope");
	EPReturn(@"Squeeze", @"CIPinchDistortion");
	EPReturn(@"Thermal", @"CIThermal");
	EPReturn(@"Light Tunnel", @"CILightTunnel");
	return nil;
}

static NSDictionary *prefDict()
{
	return [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
}

static int integerValueForKey(NSString *key, int defaultValue)
{
	NSDictionary *pref = prefDict();
	return pref[key] ? [pref[key] intValue] : defaultValue;
}

static NSMutableArray *effectsThatNotSupportedModernEditor()
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:CINoneName];
	[array addObject:@"CIMirror"];
	[array addObject:@"CITriangleKaleidoscope"];
	[array addObject:@"CILightTunnel"];
	[array addObject:@"CIPinchDistortion"];
	[array addObject:@"CITwirlDistortion"];
	[array addObject:@"CIStretch"];
	[array addObject:@"CIWrapMirror"];
	[array addObject:@"CIHoleDistortion"];
	[array addObject:@"CICircleSplashDistortion"];
	return array;
}
