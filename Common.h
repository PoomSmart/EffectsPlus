#import "../PS.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.EffectsPlus.plist"
#define PreferencesChangedNotification "com.PS.EffectsPlus.prefs"
#define kFontSize 14
#define NORMAL_EFFECT_COUNT 8
#define EXTRA_EFFECT_COUNT 23
static const NSString *ENABLED_EFFECT = @"EnabledEffects";
static const NSString *DISABLED_EFFECT = @"DisabledEffects";

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

@interface PLEffectFilterManager : NSObject
+ (PLEffectFilterManager *)sharedInstance;
- (unsigned)blackAndWhiteFilterStartIndex;
- (unsigned)filterCount;
- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
@end

@interface CAMEffectFilterManager : NSObject
+ (CAMEffectFilterManager *)sharedInstance;
- (unsigned)blackAndWhiteFilterStartIndex;
- (unsigned)filterCount;
- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
@end

@interface PLEffectSelectionViewController : UIViewController
- (void)_setSelectedIndexPath:(NSIndexPath *)indexPath;
@end

@interface CAMEffectSelectionViewController : UIViewController
- (void)_setSelectedIndexPath:(NSIndexPath *)indexPath;
@end

@interface PLEffectsGridView : UIView
- (unsigned)_cellCount;
- (BOOL)isBlackAndWhite;
@end

@interface CAMEffectsGridView : UIView
- (unsigned)_cellCount;
- (BOOL)isBlackAndWhite;
@end

@interface PLImageAdjustmentView : UIView
@property(retain) UIImage *editedImage;
- (void)setEditedImage:(UIImage *)image;
@end

@interface CAMBottomBar : UIToolbar
@end

@interface PLCameraView : UIView
@property(readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@end

@interface CAMCameraView : UIView
@property(readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@end

@interface _PLManagedAsset : NSObject
- (int)orientationValue;
@end

@interface PLManagedAsset : _PLManagedAsset
@property(readonly, nonatomic) NSString *pathForImageFile;
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
@end

@interface CAMCaptureController
+ (CAMCaptureController *)sharedInstance;
- (BOOL)isReady;
@end

@interface PLProgressHUD : UIView
- (void)done;
- (void)showInView:(id)view;
- (void)hide;
- (void)setText:(NSString *)text;
@end

@interface PLEditPhotoController (Addition)
- (void)EPSavePhoto;
@end

@interface PLCIFilterUtilties : NSObject
+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)inputImage orientation:(UIImageOrientation)orientation copyFiltersFirst:(BOOL)copyFirst;
@end

@interface UIImage (Addition)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

static NSString *displayNameFromCIFilterName(NSString *name)
{
	#define EPReturn(name1, name2) if ([name isEqualToString:name2]) return name1
	EPReturn(@"Mono", @"CIPhotoEffectMono");
	EPReturn(@"Noir", @"CIPhotoEffectNoir");
	EPReturn(@"Fade", @"CIPhotoEffectFade");
	EPReturn(@"Chrome", @"CIPhotoEffectChrome");
	EPReturn(@"Process", @"CIPhotoEffectProcess");
	EPReturn(@"Transfer", @"CIPhotoEffectTransfer");
	EPReturn(@"Instant", @"CIPhotoEffectInstant");
	EPReturn(@"Tonal", @"CIPhotoEffectTonal");
	
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
	EPReturn(@"X-Ray", @"CIXRay");
	EPReturn(@"Mirrors", @"CIWrapMirror");
	EPReturn(@"Stretch", @"CIStretch");
	EPReturn(@"Mirror", @"CIMirror");
	EPReturn(@"Triangle", @"CITriangleKaleidoscope");
	EPReturn(@"Squeeze", @"CIPinchDistortion");
	EPReturn(@"Thermal", @"CIThermal");
	EPReturn(@"Light Tunnel", @"CILightTunnel");
	//EPReturn(@"Bloom + Thermal", @"CIBloom_CIThermal");
	return @"";
}
