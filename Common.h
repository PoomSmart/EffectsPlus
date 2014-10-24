#import "../PS.h"

#define PREF_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.PS.EffectsPlus.plist"]
#define PreferencesChangedNotification "com.PS.EffectsPlus.prefs"
#define kFontSize 14
#define NORMAL_EFFECT_COUNT 8
#define EXTRA_EFFECT_COUNT 25
NSString *const ENABLED_EFFECT = @"EnabledEffects";
NSString *const DISABLED_EFFECT = @"DisabledEffects";
NSString *const saveMode = @"saveMode";
NSString *const CINoneName = @"CINone";

extern "C" NSString *PLLocalizedFrameworkString(NSString *key, NSString *comment);

@interface _UIBackdropView : UIView
@end

@interface CIFilter (Addition)
@property(retain, nonatomic) CIImage *inputImage;
//@property (nonatomic, copy) NSString *anotherFilter;
- (NSDictionary *)_outputProperties;
@end

@interface PBFilter : CIFilter
@end

@interface CIColorPosterize : CIFilter
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

@interface CIThermal : CIFilter
@end

@interface CIXRay : CIFilter
@end

@interface CIPixellate : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
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

@interface CIHoleDistortion : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputRadius;
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

@interface CIWrapMirror : CIFilter
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

@interface CILightTunnel : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputRotation;
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CICircleSplashDistortion : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CICircularScreen : CIFilter
@property(retain, nonatomic) CIVector *inputCenter;
@property(retain, nonatomic) NSNumber *inputWidth;
@property(retain, nonatomic) NSNumber *inputSharpness;
@end

@interface CILineScreen : CIFilter
@property(retain, nonatomic) NSNumber *inputAngle;
@property(retain, nonatomic) NSNumber *inputWidth;
@property(retain, nonatomic) NSNumber *inputSharpness;
@end

@interface PLEffectFilterManager : NSObject
+ (id)sharedInstance;
- (unsigned)blackAndWhiteFilterStartIndex;
- (unsigned)filterCount;
- (CIFilter *)filterForIndex:(unsigned)index;
- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
@end

@interface CAMEffectFilterManager : NSObject
+ (id)sharedInstance;
- (unsigned)blackAndWhiteFilterStartIndex;
- (unsigned)filterCount;
- (CIFilter *)filterForIndex:(unsigned)index;
- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
@end

@interface PLEffectSelectionViewController : UIViewController
- (void)_setSelectedIndexPath:(NSIndexPath *)indexPath;
@end

@interface CAMEffectSelectionViewController : UIViewController
- (void)_setSelectedIndexPath:(NSIndexPath *)indexPath;
@end

@interface PLGLView
- (CGFloat)drawableHeight;
- (CGFloat)drawableWidth;
@end

@interface CAMGLView
- (CGFloat)drawableHeight;
- (CGFloat)drawableWidth;
@end

@interface PLEffectsGridView : PLGLView
- (unsigned)_cellCount;
- (unsigned)_filterIndexForGridIndex:(unsigned)index;
- (BOOL)isBlackAndWhite;
- (BOOL)isSquare;
- (CGRect)rectForFilterIndex:(unsigned)index;
- (CGRect)_squareCropFromRect:(CGRect)rect;
@end

@interface CAMEffectsGridView : CAMGLView
- (unsigned)_cellCount;
- (unsigned)_filterIndexForGridIndex:(unsigned)index;
- (BOOL)isBlackAndWhite;
- (BOOL)isSquare;
- (CGRect)rectForFilterIndex:(unsigned)index;
- (CGRect)_squareCropFromRect:(CGRect)rect;
@end

@interface PLImageAdjustmentView : UIView
@property(retain) UIImage *editedImage;
- (void)setEditedImage:(UIImage *)image;
@end

@interface CAMTopBar : UIControl
@end

@interface CAMBottomBar : UIControl
@end

@interface PLCameraView : UIView
@property(readonly, assign, nonatomic) CAMTopBar *_topBar;
@property(readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@end

@interface CAMCameraView : UIView
@property(readonly, assign, nonatomic) CAMTopBar *_topBar;
@property(readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@end

@interface _PLManagedAsset : NSObject
- (int)orientationValue;
@end

@interface PLManagedAsset : _PLManagedAsset
@property(readonly, nonatomic) NSString *pathForImageFile;
@property(readonly, nonatomic) NSString *pathForOriginalFile;
@end

@interface PLEditPhotoController : UIViewController <UIActionSheetDelegate>
@property(readonly) struct CGRect normalizedCropRect;
- (UINavigationItem *)navigationItem;
- (CIImage *)_newCIImageFromUIImage:(UIImage *)image;
- (NSArray *)_currentNonGeometryFiltersWithEffectFilters:(NSArray *)filters;
- (NSArray *)_cropAndStraightenFiltersForImageSize:(struct CGSize)size forceSquareCrop:(BOOL)crop forceUseGeometry:(BOOL)geometry;
- (void)_setControlsEnabled:(BOOL)enabled animated:(BOOL)animated;
- (void)_presentSavingHUD;
- (void)_dismissSavingHUD;
- (void)save:(UIBarButtonItem *)item;
- (void)cancel:(UIBarButtonItem *)item;
- (void)saveAdjustments;
@end

@interface PLCameraController
+ (PLCameraController *)sharedInstance;
- (BOOL)isReady;
- (unsigned)_activeFilterIndex;
@end

@interface CAMCaptureController
+ (CAMCaptureController *)sharedInstance;
- (BOOL)isReady;
- (unsigned)_activeFilterIndex;
@end

@interface CAMFilterButton
- (void)setOn:(BOOL)on;
@end

@interface PLProgressHUD : UIView
- (void)done;
- (void)showInView:(id)view;
- (void)hide;
- (void)setText:(NSString *)text;
@end

@interface PLEditPhotoController (Addition)
- (void)EPSavePhoto;
- (void)ep_save:(int)mode;
@end

@interface PLCIFilterUtilties : NSObject
+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)inputImage orientation:(UIImageOrientation)orientation copyFiltersFirst:(BOOL)copyFirst;
@end

@interface PLPhotoEffect : NSObject
+ (NSArray *)allEffects;
+ (PLPhotoEffect *)_effectWithIdentifier:(NSString *)identifier CIFilterName:(NSString *)filterName displayName:(NSString *)displayName;
+ (PLPhotoEffect *)_effectWithIdentifier:(NSString *)identifier;
+ (PLPhotoEffect *)_effectWithCIFilterName:(NSString *)identifier;
+ (NSUInteger)indexOfEffectWithIdentifier:(NSString *)identifier;
- (NSString *)displayName;
- (NSString *)filterIdentifier;
- (NSString *)CIFilterName;
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
