#import "../Common.h"
#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

static BOOL TweakEnabled;
static BOOL FillGrid;
static BOOL AutoHideBB;
static BOOL oldEditor;

static BOOL internalBlurHook = NO;
static BOOL globalFilterHook = NO;

static CGFloat CISepiaTone_inputIntensity;
static CGFloat CIVibrance_inputAmount;
static CGFloat CIColorMonochrome_inputIntensity;
static CGFloat CIColorMonochrome_R, CIColorMonochrome_G, CIColorMonochrome_B;
static CGFloat CIColorPosterize_inputLevels;
static CGFloat CIGloom_inputRadius, CIGloom_inputIntensity;
static CGFloat CIBloom_inputRadius, CIBloom_inputIntensity;
static CGFloat CISharpenLuminance_inputSharpness;
static CGFloat CIPixellate_inputScale;
static CGFloat CIGaussianBlur_inputRadius;
static CGFloat CIFalseColor_R1, CIFalseColor_G1, CIFalseColor_B1;
static CGFloat CIFalseColor_R2, CIFalseColor_G2, CIFalseColor_B2;
static CGFloat CITwirlDistortion_inputRadius, CITwirlDistortion_inputAngle;
static CGFloat CITriangleKaleidoscope_inputSize, CITriangleKaleidoscope_inputDecay;
static CGFloat CIPinchDistortion_inputRadius, CIPinchDistortion_inputScale;
static CGFloat CILightTunnel_inputRadius, CILightTunnel_inputRotation;
static CGFloat CIHoleDistortion_inputRadius;
static CGFloat CICircleSplashDistortion_inputRadius;
static CGFloat CICircularScreen_inputWidth, CICircularScreen_inputSharpness;
static CGFloat CILineScreen_inputAngle, CILineScreen_inputWidth, CILineScreen_inputSharpness;
static CGFloat CIMirror_inputAngle;

static CGFloat qualityFactor;
static int mode = 1;

static NSArray *enabledArray = nil;
static PLProgressHUD *epHUD = nil;

%hook CIImage

- (CIImage *)_imageByApplyingBlur:(double)blur
{
	if (!internalBlurHook)
		return %orig;
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[gaussianBlurFilter setValue:self forKey:@"inputImage"]; 
	[gaussianBlurFilter setValue:[NSNumber numberWithDouble:blur] forKey:@"inputRadius"];
	CIImage *resultImage = [gaussianBlurFilter valueForKey:@"outputImage"];
	return resultImage;
}

%end

static inline CIImage *ciImageInternalFixIfNecessary(CIImage *outputImage, CIFilter *itsFilter)
{
	if (!globalFilterHook)
		return outputImage;
	CGRect rect = itsFilter.inputImage.extent;
	CIImage *fixedImage = [outputImage imageByCroppingToRect:rect];
	return fixedImage;
}

static inline NSDictionary *dictionaryByAddingSomeNativeValues(NSDictionary *inputDict)
{
	NSMutableDictionary *mutableInputDict = [inputDict mutableCopy];
	NSMutableArray *filterCategoriesArray = [mutableInputDict[@"CIAttributeFilterCategories"] mutableCopy];
	if (filterCategoriesArray == nil)
		return inputDict;
	if (![filterCategoriesArray containsObject:@"CICategoryXMPSerializable"])
		[filterCategoriesArray addObject:@"CICategoryXMPSerializable"];
	[mutableInputDict setObject:filterCategoriesArray forKey:@"CIAttributeFilterCategories"];
	return (NSDictionary *)mutableInputDict;
}

@interface CINone : CIFilter {
    CIImage *inputImage;
}
@property (retain, nonatomic) CIImage *inputImage;
@end

@implementation CINone
@synthesize inputImage;

- (CIImage *)outputImage
{
    return inputImage;
}

@end

%hook CIFilter

+ (NSArray *)filterNamesInCategories:(NSArray *)categories
{
	NSMutableArray *orig = [%orig mutableCopy];
	if (orig != nil) {
		[orig addObject:CINoneName];
	}
	return orig;
}

- (NSString *)_serializedXMPString
{
	NSString *name = %orig;
	return name == nil ? [self name] : name;
}

%end

%hook CISharpenLuminance

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (void)setInputSharpness:(NSNumber *)sharpness
{
	%orig(globalFilterHook ? @(CISharpenLuminance_inputSharpness) : sharpness);
}

%end

%hook CIGaussianBlur

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIPixellate

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIMirror

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIXRay

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CICircleSplashDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIStretch

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIThermal

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIColorInvert

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CITriangleKaleidoscope

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIHoleDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIWrapMirror

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIPinchDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CILightTunnel

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CITwirlDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIColorMonochrome

- (void)setInputIntensity:(NSNumber *)intensity
{
	%orig(globalFilterHook ? @(CIColorMonochrome_inputIntensity) : intensity);
}

- (void)setInputColor:(CIColor *)color
{
	%orig(globalFilterHook ? [CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B] : color);
}

%end

%hook CIColorPosterize

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (void)setInputLevels:(NSNumber *)levels
{
	%orig(globalFilterHook ? @(CIColorPosterize_inputLevels) : levels);
}

%end

%hook CISepiaTone

- (void)setInputIntensity:(NSNumber *)intensity
{
	%orig(globalFilterHook ? @(CISepiaTone_inputIntensity) : intensity);
}

%end

%hook CIVibrance

- (void)setInputAmount:(NSNumber *)amount
{
	%orig(globalFilterHook ? @(CIVibrance_inputAmount) : amount);
}

%end

%hook CIBloom

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIGloom

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CICircularScreen

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CILineScreen

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

/*%hook PLEffectsGridLabelsView

- (void)_replaceLabelViews:(id)view
{
	%orig;
	if (MSHookIvar<_UIBackdropView *>(self, "__backdropView") != nil) {
		[MSHookIvar<_UIBackdropView *>(self, "__backdropView") removeFromSuperview];
		[MSHookIvar<_UIBackdropView *>(self, "__backdropView") release];
		MSHookIvar<_UIBackdropView *>(self, "__backdropView") = nil;
	}
}

- (void)backdropViewDidChange:(id)change
{
}

- (void)set_backdropView:(id)view
{
}

- (id)_backdropView
{
	return nil;
}

%end*/

static void effectCorrection(CIFilter *filter, CGRect extent, int orientation)
{
	NSString *filterName = filter.name;
	CIVector *normalHalfExtent = [CIVector vectorWithX:extent.size.width/2 Y:extent.size.height/2];
	CIVector *invertHalfExtent = [CIVector vectorWithX:extent.size.height/2 Y:extent.size.width/2];
	BOOL normal = (orientation == 0 || orientation == 1 || orientation == 3 || orientation == 5 || orientation == 6 || orientation == 8);
	CIVector *globalCenter = normal ? normalHalfExtent : invertHalfExtent;
	#define valueCorrection(value) @((extent.size.width/640)*value)
	if ([filterName isEqualToString:@"CIMirror"]) {
		[(CIMirror *)filter setInputPoint:normalHalfExtent];
		[(CIMirror *)filter setInputAngle:@(1.5*M_PI + CIMirror_inputAngle)];
	}
	else if ([filterName isEqualToString:@"CITriangleKaleidoscope"]) {
		[(CITriangleKaleidoscope *)filter setInputPoint:normalHalfExtent];
		[(CITriangleKaleidoscope *)filter setInputSize:valueCorrection(CITriangleKaleidoscope_inputSize)];
	}
	else if ([filterName isEqualToString:@"CIPixellate"]) {
		[(CIPixellate *)filter setInputScale:valueCorrection(CIPixellate_inputScale)];
		[(CIPixellate *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CIStretch"])
		[(CIStretch *)filter setInputPoint:globalCenter];
	else if ([filterName isEqualToString:@"CIPinchDistortion"]) {
		[(CIPinchDistortion *)filter setInputRadius:valueCorrection(CIPinchDistortion_inputRadius)];
		[(CIPinchDistortion *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CITwirlDistortion"]) {
		[(CITwirlDistortion *)filter setInputRadius:valueCorrection(CITwirlDistortion_inputRadius)];
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI/2+CITwirlDistortion_inputAngle)];
		[(CITwirlDistortion *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CICircleSplashDistortion"]) {
		[(CICircleSplashDistortion *)filter setInputRadius:valueCorrection(CICircleSplashDistortion_inputRadius)];
		[(CICircleSplashDistortion *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CIHoleDistortion"]) {
		[(CIHoleDistortion *)filter setInputRadius:valueCorrection(CIHoleDistortion_inputRadius)];
		[(CIHoleDistortion *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CILightTunnel"]) {
		[(CILightTunnel *)filter setInputRadius:valueCorrection(CILightTunnel_inputRadius)];
		[(CILightTunnel *)filter setInputCenter:globalCenter];
	}
	else if ([filterName isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputRadius:valueCorrection(CIGloom_inputRadius)];
	else if ([filterName isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputRadius:valueCorrection(CIBloom_inputRadius)];
	else if ([filterName isEqualToString:@"CIGaussianBlur"])
		[(CIGaussianBlur *)filter setInputRadius:valueCorrection(CIGaussianBlur_inputRadius)];
	else if ([filterName isEqualToString:@"CISharpenLuminance"])
		[(CISharpenLuminance *)filter setInputSharpness:valueCorrection(CISharpenLuminance_inputSharpness)];
	else if ([filterName isEqualToString:@"CIColorMonochrome"])
		[(CIColorMonochrome *)filter setInputColor:[CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B]];
	else if ([filterName isEqualToString:@"CIFalseColor"]) {
		[(CIFalseColor *)filter setInputColor0:[CIColor colorWithRed:CIFalseColor_R1 green:CIFalseColor_G1 blue:CIFalseColor_B1]];
		[(CIFalseColor *)filter setInputColor1:[CIColor colorWithRed:CIFalseColor_R2 green:CIFalseColor_G2 blue:CIFalseColor_B2]];
	}
	else if ([filterName isEqualToString:@"CICircularScreen"]) {
		[(CICircularScreen *)filter setInputCenter:globalCenter];
		[(CICircularScreen *)filter setInputWidth:valueCorrection(CICircularScreen_inputWidth)];
	}
	else if ([filterName isEqualToString:@"CILineScreen"])
		[(CILineScreen *)filter setInputWidth:valueCorrection(CILineScreen_inputWidth)];
}

%hook PLCIFilterUtilities

+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)image orientation:(UIImageOrientation)orientation copyFiltersFirst:(BOOL)copyFirst
{
	if ([filters count] == 0)
		return %orig;
	internalBlurHook = YES;
	globalFilterHook = YES;
	CGRect extent = [image extent];
	for (CIFilter *filter in filters) {
		if (![filter respondsToSelector:@selector(_outputProperties)])
			effectCorrection(filter, extent, orientation);
	}

	NSMutableArray *mutableFiltersArray = [filters mutableCopy];
	if ([filters count] > 1) {
		for (NSUInteger i = 0; i < [filters count]; i++) {
			if (![(CIFilter *)mutableFiltersArray[i] respondsToSelector:@selector(_outputProperties)]) {
				if (i != 0) {
					[mutableFiltersArray insertObject:mutableFiltersArray[i] atIndex:0];
					[mutableFiltersArray removeObjectAtIndex:i+1];
				}
			}
		}
	}
	CIImage *outputImage = %orig(mutableFiltersArray, image, orientation, copyFirst);
	internalBlurHook = NO;
	globalFilterHook = NO;
	return outputImage;
}

%end

static void configEffect(CIFilter *filter)
{
	NSString *filterName = filter.name;
	if ([filterName isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputIntensity:@(CIGloom_inputIntensity)];
	else if ([filterName isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputIntensity:@(CIBloom_inputIntensity)];
	else if ([filterName isEqualToString:@"CITwirlDistortion"])
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI/2+CITwirlDistortion_inputAngle)];
	else if ([filterName isEqualToString:@"CIPinchDistortion"])
		[(CIPinchDistortion *)filter setInputScale:@(CIPinchDistortion_inputScale)];
	else if ([filterName isEqualToString:@"CIVibrance"])
		[(CIVibrance *)filter setInputAmount:@(CIVibrance_inputAmount)];
	else if ([filterName isEqualToString:@"CISepiaTone"])
		[(CISepiaTone *)filter setInputIntensity:@(CISepiaTone_inputIntensity)];
	else if ([filterName isEqualToString:@"CIColorMonochrome"])
		[(CIColorMonochrome *)filter setInputColor:[CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B]];
	else if ([filterName isEqualToString:@"CIFalseColor"]) {
		CIColor *color0 = [CIColor colorWithRed:CIFalseColor_R1 green:CIFalseColor_G1 blue:CIFalseColor_B1];
		CIColor *color1 = [CIColor colorWithRed:CIFalseColor_R2 green:CIFalseColor_G2 blue:CIFalseColor_B2];
		[(CIFalseColor *)filter setInputColor0:color0];
		[(CIFalseColor *)filter setInputColor1:color1];
	}
	else if ([filterName isEqualToString:@"CILightTunnel"])
		[(CILightTunnel *)filter setInputRotation:@(CILightTunnel_inputRotation)];
	else if ([filterName isEqualToString:@"CICircularScreen"]) {
		[(CICircularScreen *)filter setInputWidth:@(CICircularScreen_inputWidth)];
		[(CICircularScreen *)filter setInputSharpness:@(CICircularScreen_inputSharpness)];
	}
	else if ([filterName isEqualToString:@"CILineScreen"]) {
		[(CILineScreen *)filter setInputAngle:@(CILineScreen_inputAngle)];
		[(CILineScreen *)filter setInputSharpness:@(CILineScreen_inputSharpness)];
	}
}

static void _addCIEffect(NSString *displayName, NSString *filterName, NSObject *manager)
{
	CIFilter *filter = [CIFilter filterWithName:filterName];
	if (![MSHookIvar<NSMutableArray *>(manager, "_effects") containsObject:filter]) {
		configEffect(filter);
		[(id)manager _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter];
	}
}

static void addExtraSortedEffects(NSObject *effectFilterManager)
{
	#define addCIEffect(arg) _addCIEffect(displayNameFromCIFilterName(arg), arg, effectFilterManager)
	NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (prefDict != nil) {
		NSMutableArray *effects = [prefDict[ENABLED_EFFECT] mutableCopy];
		if (effects == nil)
			return;
		
		NSMutableArray *allEffects = MSHookIvar<NSMutableArray *>(effectFilterManager, "_effects");
		NSMutableArray *names = MSHookIvar<NSMutableArray *>(effectFilterManager, "_names");
		NSMutableArray *aggdNames = MSHookIvar<NSMutableArray *>(effectFilterManager, "_aggdNames");
		[allEffects removeAllObjects];
		[names removeAllObjects];
		[aggdNames removeAllObjects];
		
		for (NSUInteger i = 0; i < [effects count]; i++) {
			NSString *string = effects[i];
			addCIEffect(string);
		}
	}
}

static void showFilterSelectionAlert(id self)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Effects+" message:@"ERROR: The selected filter isn't existed in the current library. You have to enable this filter in settings first." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

%group iOS7

%hook PLImageAdjustmentView

- (void)replaceEditedImage:(UIImage *)image
{
	[MSHookIvar<UIImage *>(self, "_editedImage") release];
	MSHookIvar<UIImage *>(self, "_editedImage") = [image retain];
	[self setEditedImage:MSHookIvar<UIImage *>(self, "_editedImage")];
	[MSHookIvar<UIImageView *>(self, "_imageView") setImage:MSHookIvar<UIImage *>(self, "_editedImage")];
}

%end

%hook PLEffectFilterManager

- (PLEffectFilterManager *)init
{
	PLEffectFilterManager *manager = %orig;
	addExtraSortedEffects(manager);
	return manager;
}

%end

%hook PLEffectsGridView

- (NSUInteger)_filterIndexForGridIndex:(unsigned)index
{
	return [self isBlackAndWhite] ? index + [[%c(PLEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_gridIndexForFilterIndex:(unsigned)index
{
	return [self isBlackAndWhite] ? index - [[%c(PLEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_cellsPerRow
{
	NSUInteger filterCount = [[%c(PLEffectFilterManager) sharedInstance] filterCount];
	NSUInteger i = 1;
	do {
		if (filterCount <= i*i)
			break;
		i++;
	} while (1);
	return i;
}

- (NSUInteger)_cellCount
{
	NSUInteger orig = %orig;
	if (FillGrid)
		return orig;
	return enabledArray != nil ? [enabledArray count] : orig;
}

- (void)_updatePixelBufferPoolForSize:(CGSize)size
{
	%orig(CGSizeMake(size.width*qualityFactor, size.height*qualityFactor));
}

- (CVBufferRef)_createPixelBufferForSize:(CGSize)size
{
	return %orig(CGSizeMake(size.width*qualityFactor, size.height*qualityFactor));
}

%end

%hook PLCameraView

- (void)_updateFilterButtonOnState
{
	%orig;
	CIFilter *currentFilter = [[%c(PLEffectFilterManager) sharedInstance] filterForIndex:[[%c(PLCameraController) sharedInstance] _activeFilterIndex]];
	CAMFilterButton *filterButton = MSHookIvar<CAMFilterButton *>(self, "__filterButton");
	BOOL shouldOn;
	if (currentFilter == nil)
		shouldOn = NO;
	else
		shouldOn = ![currentFilter.name isEqualToString:CINoneName];
	[filterButton setOn:shouldOn];
}

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	if (AutoHideBB) {
		if (self._bottomBar != nil)
			self._bottomBar.hidden = showEffectsGrid;
		if (self._topBar != nil)
			self._topBar.hidden = showEffectsGrid;
	}
}

%end

%hook PLEffectSelectionViewController

- (NSArray *)_generateFilters
{
	PLEffectFilterManager *manager = [%c(PLEffectFilterManager) sharedInstance];
	NSUInteger filterCount = [manager filterCount];
    NSMutableArray *effects = [[NSMutableArray alloc] initWithCapacity:filterCount];
    NSUInteger index = 0;
	do {
		CIFilter *filter = [manager filterForIndex:index];
		if (![filter.name isEqualToString:CINoneName])
			[effects addObject:filter];
		index++;
	} while (filterCount != index);
	MSHookIvar<NSArray *>(self, "_effects") = effects;
    return effects;
}

- (void)setSelectedEffect:(CIFilter *)filter
{
	%log;
	if (filter != nil) {
		NSArray *filters = MSHookIvar<NSArray *>(self, "_effects");
		for (NSUInteger i = 0; i < [filters count]; i++) {
			if ([((CIFilter *)filters[i]).name isEqualToString:filter.name]) {
				[self _setSelectedIndexPath:[NSIndexPath indexPathForItem:i inSection:1]];
				return;
			}
		}
		showFilterSelectionAlert(self);
	} else
		%orig;
}

%end

%end

%group iOS8

%hook CAMEffectFilterManager

- (CAMEffectFilterManager *)init
{
	CAMEffectFilterManager *manager = %orig;
	addExtraSortedEffects(manager);
	return manager;
}

%end

%hook CAMEffectsGridView

- (NSUInteger)_filterIndexForGridIndex:(unsigned)index
{
	return [self isBlackAndWhite] ? index + [[%c(CAMEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_gridIndexForFilterIndex:(unsigned)index
{
	return [self isBlackAndWhite] ? index - [[%c(CAMEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_cellsPerRow
{
	NSUInteger filterCount = [[%c(CAMEffectFilterManager) sharedInstance] filterCount];
	NSUInteger i = 1;
	do {
		if (filterCount <= i*i)
			break;
		i++;
	} while (1);
	return i;
}

- (NSUInteger)_cellCount
{
	NSUInteger orig = %orig;
	if (FillGrid)
		return orig;
	return enabledArray != nil ? [enabledArray count] : orig;
}

%end

%hook CAMCameraView

- (void)_updateFilterButtonOnState
{
	%orig;
	CIFilter *currentFilter = [[%c(CAMEffectFilterManager) sharedInstance] filterForIndex:[[%c(CAMCaptureController) sharedInstance] _activeFilterIndex]];
	CAMFilterButton *filterButton = MSHookIvar<CAMFilterButton *>(self, "__filterButton");
	BOOL shouldOn;
	if (currentFilter == nil)
		shouldOn = NO;
	else
		shouldOn = ![currentFilter.name isEqualToString:CINoneName];
	[filterButton setOn:shouldOn];
}

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	if (AutoHideBB) {
		if (self._bottomBar != nil)
			self._bottomBar.hidden = showEffectsGrid;
		if (self._topBar != nil)
			self._topBar.hidden = showEffectsGrid;
	}
}

%end

%hook CAMEffectSelectionViewController

- (NSArray *)_generateFilters
{
	PLEffectFilterManager *manager = [%c(CAMEffectFilterManager) sharedInstance];
	NSUInteger filterCount = [manager filterCount];
    NSMutableArray *effects = [[NSMutableArray alloc] initWithCapacity:filterCount];
    NSUInteger index = 0;
	do {
		CIFilter *filter = [manager filterForIndex:index];
		if (![filter.name isEqualToString:CINoneName])
			[effects addObject:filter];
		index++;
	} while (filterCount != index);
	MSHookIvar<NSArray *>(self, "_effects") = effects;
    return effects;
}

- (void)setSelectedEffect:(CIFilter *)filter
{
	if (filter != nil) {
		NSArray *filters = MSHookIvar<NSArray *>(self, "_effects");
		for (NSUInteger i = 0; i < [filters count]; i++) {
			if ([((CIFilter *)[filters objectAtIndex:i]).name isEqualToString:filter.name]) {
				[self _setSelectedIndexPath:[NSIndexPath indexPathForItem:i inSection:1]];
				return;
			}
		}
		showFilterSelectionAlert(self);
	} else
		%orig;
}

%end

%hook PUPhotoEditProtoSettings

- (BOOL)useOldPhotosEditor2
{
	return oldEditor ? YES : %orig;
}

- (void)setUseOldPhotosEditor2:(BOOL)use
{
	%orig(oldEditor ? YES : use);
}

%end

%hook PLPhotoEffect

static NSMutableArray *effects = nil;
static NSMutableArray *effectsForiOS8()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		effects = [NSMutableArray array];
		CAMEffectFilterManager *manager = [%c(CAMEffectFilterManager) sharedInstance];
		NSMutableArray *camEffects = MSHookIvar<NSMutableArray *>(manager, "_effects");
		NSMutableArray *ourCamEffects = [NSMutableArray arrayWithArray:camEffects];
		if (![[%c(PUPhotoEditProtoSettings) sharedInstance] useOldPhotosEditor2]) {
			NSMutableArray *camEffectsToBeRemoved = [NSMutableArray array];
			for (NSUInteger i = 0; i < [ourCamEffects count]; i++) {
				CIFilter *noneFilter = ourCamEffects[i];
				NSString *noneFilterName = noneFilter.name;
				if ([effectsThatNotSupportedModernEditor() containsObject:noneFilterName])
					[camEffectsToBeRemoved addObject:noneFilter];
			}
			[ourCamEffects removeObjectsInArray:camEffectsToBeRemoved];
		}
		NSUInteger filterCount = ourCamEffects.count;
    	NSUInteger index = 0;
		do {
			CIFilter *filter = ourCamEffects[index];
			NSString *filterName = filter.name;
			NSString *displayName = displayNameFromCIFilterName(filterName);
			PLPhotoEffect *effect = [%c(PLPhotoEffect) _effectWithIdentifier:displayName CIFilterName:filterName displayName:displayName];
			[effects addObject:effect];
			index++;
		} while (filterCount != index);
		[effects retain];
	});
	return effects;
}

+ (NSArray *)allEffects
{
    return effectsForiOS8();
}

+ (PLPhotoEffect *)effectWithIdentifier:(NSString *)identifier
{
	NSArray *allEffects = effectsForiOS8();
	PLPhotoEffect *effect = allEffects[[self indexOfEffectWithIdentifier:identifier]];
	return effect;
}

+ (PLPhotoEffect *)effectWithCIFilterName:(NSString *)filterName
{
	PLPhotoEffect *targetEffect = nil;
	NSArray *allEffects = effectsForiOS8();
	for (NSUInteger i = 0; i < [allEffects count]; i++) {
		PLPhotoEffect *effect = allEffects[i];
		NSString *effectFilterName = [effect CIFilterName];
		if ([effectFilterName isEqualToString:filterName]) {
			targetEffect = effect;
			break;
		}
	}
	return targetEffect;
}

+ (NSUInteger)indexOfEffectWithIdentifier:(NSString *)identifier
{
	NSUInteger index = 0;
	NSArray *allEffects = effectsForiOS8();
	for (NSUInteger i = 0; i < [allEffects count]; i++) {
		PLPhotoEffect *effect = allEffects[i];
		NSString *effectIdentifier = [effect filterIdentifier];
		if ([effectIdentifier isEqualToString:identifier]) {
			index = i;
			break;
		}
	}
	return index;
}

%end

%end

%hook PLEditPhotoController

%new
- (void)ep_save:(int)mode
{
	switch (mode) {
		case 2:
			[self save:nil];
			break;
		case 3:
			[self _setControlsEnabled:NO animated:NO];
			epHUD = [[PLProgressHUD alloc] init];
			[epHUD setText:PLLocalizedFrameworkString(@"SAVING_PHOTO", nil)];
			[epHUD showInView:self.view];
			[self EPSavePhoto];
			break;
		case 4:
			MSHookIvar<BOOL>(self, "_savesAdjustmentsToCameraRoll") = YES;
			[self saveAdjustments];
			MSHookIvar<BOOL>(self, "_savesAdjustmentsToCameraRoll") = NO;
			break;
	}
}

%new
- (void)ep_showOptions
{
	if (mode == 1) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select saving options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Default", @"New image", @"New image (w/ adjustments)", nil];
		sheet.tag = 9598;
		[sheet showInView:self.view];
		[sheet release];
	} else
		[self ep_save:mode];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (popup.tag == 9598) {
		int mode = buttonIndex + 2;
		[self ep_save:mode];
	} else
		%orig;
}

%new
- (void)EPSavePhoto
{
	PLManagedAsset *asset = MSHookIvar<PLManagedAsset *>(self, "_editedPhoto");
	NSString *actualImagePath = isiOS8 ? [asset pathForOriginalFile] : [asset pathForImageFile];
	UIImage *actualImage = [UIImage imageWithContentsOfFile:actualImagePath];
	NSMutableArray *effectFilters = [[self _currentNonGeometryFiltersWithEffectFilters:MSHookIvar<NSArray *>(self, "_effectFilters")] mutableCopy];
	CIImage *ciImage = [self _newCIImageFromUIImage:actualImage];
	
	// Fixing image orientation, still dirt (?)
	int orientation = 1;
	float rotation = MSHookIvar<float>(self, "_rotationAngle");
	float angle = rotation;
	
	if (angle > 6)
		angle = fmodf(rotation, 6.28319);
	if (round(abs(angle)) == 3)
		orientation = 3;
	else if (round(angle) == 2)
		orientation = 8;
	else if (round(angle) == 5 || (round(angle) == -2 && angle < 0))
		orientation = 6;
	
	NSArray *cropAndStraightenFilters = [self _cropAndStraightenFiltersForImageSize:ciImage.extent.size forceSquareCrop:NO forceUseGeometry:NO];
	[effectFilters addObjectsFromArray:cropAndStraightenFilters];
	CIImage *ciImageWithFilters = [%c(PLCIFilterUtilities) outputImageFromFilters:effectFilters inputImage:ciImage orientation:orientation copyFiltersFirst:NO];
	CGImageRef cgImage = [MSHookIvar<CIContext *>(self, "_ciContextFullSize") createCGImage:ciImageWithFilters fromRect:[ciImageWithFilters extent]];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeImageToSavedPhotosAlbum:cgImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
		CGImageRelease(cgImage);
		if (epHUD != nil) {
			[epHUD hide];
			[epHUD release];
		}
		[self _setControlsEnabled:YES animated:NO];
		[self cancel:nil];
	}];
	[library release];
}

- (UIBarButtonItem *)_rightButtonForMode:(int)mode enableDone:(BOOL)done enableSave:(BOOL)save
{
	UIBarButtonItem *item = %orig;
	if (mode == 0 && !done && save)
		[item setAction:@selector(ep_showOptions)];
	return item;
}

%end

static void EPLoader()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	enabledArray = [[dict objectForKey:ENABLED_EFFECT] retain];
	TweakEnabled = [dict[@"Enabled"] boolValue];
	FillGrid = [dict[@"FillGrid"] boolValue];
	AutoHideBB = [dict[@"AutoHideBB"] boolValue];
	oldEditor = [dict[@"useOldEditor"] boolValue];
	#define readFloat(val, defaultVal) \
		val = dict[[NSString stringWithUTF8String:#val]] ? [dict[[NSString stringWithUTF8String:#val]] floatValue] : defaultVal;
	readFloat(CIColorMonochrome_R, 0.5)
	readFloat(CIColorMonochrome_G, 0.6)
	readFloat(CIColorMonochrome_B, 0.7)
	readFloat(CIFalseColor_R1, 0.2)
	readFloat(CIFalseColor_G1, 0.3)
	readFloat(CIFalseColor_B1, 0.5)
	readFloat(CIFalseColor_R2, 0.6)
	readFloat(CIFalseColor_G2, 0.8)
	readFloat(CIFalseColor_B2, 0.9)
	readFloat(CISepiaTone_inputIntensity, 1)
	readFloat(CIVibrance_inputAmount, 1)
	readFloat(CIColorMonochrome_inputIntensity, 1)
	readFloat(CIColorPosterize_inputLevels, 6)
	readFloat(CIGloom_inputRadius, 10)
	readFloat(CIGloom_inputIntensity, 1)
	readFloat(CIBloom_inputRadius, 10)
	readFloat(CIBloom_inputIntensity, 1)
	readFloat(CISharpenLuminance_inputSharpness, .4)
	readFloat(CIPixellate_inputScale, 8)
	readFloat(CIGaussianBlur_inputRadius, 10)
	readFloat(CITwirlDistortion_inputRadius, 200)
	readFloat(CITwirlDistortion_inputAngle, 3.14)
	readFloat(CITriangleKaleidoscope_inputSize, 300)
	readFloat(CITriangleKaleidoscope_inputDecay, 0.85)
	readFloat(CIPinchDistortion_inputRadius, 200)
	readFloat(CIPinchDistortion_inputScale, 0.5)
	readFloat(CILightTunnel_inputRadius, 90)
	readFloat(CILightTunnel_inputRotation, 0)
	readFloat(CIHoleDistortion_inputRadius, 150)
	readFloat(CICircleSplashDistortion_inputRadius, 150)
	readFloat(CICircularScreen_inputWidth, 6)
	readFloat(CICircularScreen_inputSharpness, 0.7)
	readFloat(CILineScreen_inputAngle, 0)
	readFloat(CILineScreen_inputWidth, 6)
	readFloat(CILineScreen_inputSharpness, 0.7)
	readFloat(CIMirror_inputAngle, 0.0)
	
	readFloat(qualityFactor, 1)
	mode = integerValueForKey(saveMode, 1);
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall Camera MobileSlideShow");
	system("launchctl kickstart -k system/com.apple.assetsd");
	EPLoader();
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, PreferencesChangedNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
	EPLoader();
	if (TweakEnabled) {
		%init;
		if (isiOS7) {
			%init(iOS7);
		}
		else if (isiOS8) {
			dlopen("/System/Library/PrivateFrameworks/PhotoLibraryServices.framework/PhotoLibraryServices", RTLD_LAZY);
			dlopen("/System/Library/Frameworks/PhotosUI.framework/PhotosUI", RTLD_LAZY);
			%init(iOS8);
		}
	}
	[pool drain];
}
