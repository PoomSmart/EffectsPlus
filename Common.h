#import <Foundation/Foundation.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.EffectsPlus.plist"
#define PreferencesChangedNotification "com.PS.EffectsPlus.prefs"
#define kFontSize 14

@interface _UIBackdropView : UIView
@end

@interface CIFilter (Addition)
@property(retain, nonatomic) CIImage *inputImage;
- (NSDictionary *)_outputProperties;
@end

@interface CIPosterize : CIFilter
@property(retain, nonatomic) NSNumber *inputLevels;
@end

@interface CIColorMonochrome : CIFilter
@property(retain, nonatomic) NSNumber *inputIntensity;
@property(retain, nonatomic) CIColor *inputColor;
@end

@interface CIFalseColor : CIFilter
@property(retain, nonatomic) CIColor *inputColor0;
@property(retain, nonatomic) CIColor *inputColor1;
@end

@interface CISepiaTone : CIFilter
@property(retain, nonatomic) NSNumber *inputIntensity;
@end

@interface CIVibrance : CIFilter
@property(retain, nonatomic) NSNumber *inputAmount;
@end

@interface CIBloom : CIFilter
@property(retain, nonatomic) NSNumber *inputIntensity;
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGloom : CIFilter
@property(retain, nonatomic) NSNumber *inputIntensity;
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGaussianBlur : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIPixellate : CIFilter
@property(retain, nonatomic) NSNumber *inputScale;
@end

@interface CIStretch : CIFilter
@property(retain, nonatomic) CIVector *inputPoint;
@property(retain, nonatomic) CIVector *inputSize;
@end

@interface CITwirlDistortion : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputRadius;
@property(retain, nonatomic) NSNumber *inputAngle;
@end

@interface CIPinchDistortion : CIFilter
@property(retain, nonatomic) NSNumber *inputScale;
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIMirror : CIFilter
@property(retain, nonatomic) NSNumber *inputAngle;
@property(retain, nonatomic) CIVector *inputPoint;
@end

@interface CISharpenLuminance : CIFilter
@property(retain, nonatomic) NSNumber *inputSharpness;
@end

@interface CITriangleKaleidoscope : CIFilter
@property(retain, nonatomic) NSNumber *inputDecay;
@property(retain, nonatomic) NSNumber *inputSize;
@property(retain, nonatomic) NSNumber *inputAngle;
@property(retain, nonatomic) CIVector *inputPoint;
@end

@interface PLEffectFilterManager : NSObject
+ (id)sharedInstance;
- (id)aggdNameForFilter:(id)filter;
- (id)displayNameForFilter:(id)filter;
- (id)displayNameForIndex:(unsigned)index;
- (unsigned)_indexForFilter:(id)filter;
- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
- (unsigned)blackAndWhiteFilterCount;
- (unsigned)blackAndWhiteFilterStartIndex;
- (id)filterForIndex:(unsigned)index;
- (unsigned)filterCount;
- (id)init;
- (void)dealloc;
@end

@interface PLEffectsGridView
- (unsigned)_cellCount;
@end

@interface PLImageAdjustmentView
- (void)setEditedImage:(UIImage *)image;
@end

@interface CAMBottomBar : UIToolbar
@end

@interface PLCameraView
@property(readonly, assign, nonatomic) CAMBottomBar* _bottomBar;
@end

static NSString *displayNameFromCIFilterName(NSString *name)
{
	#define EPReturn(name1, name2) if ([name isEqualToString:name2]) return name1
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
	EPReturn(@"Twirl", @"CITwirlDistortion");
	EPReturn(@"Mirrors", @"CIWrapMirror");
	EPReturn(@"Stretch", @"CIStretch");
	EPReturn(@"Mirror", @"CIMirror");
	EPReturn(@"Triangle", @"CITriangleKaleidoscope");
	EPReturn(@"Squeeze", @"CIPinchDistortion");
	EPReturn(@"Thermal", @"CIThermal");
	return @"";
}
