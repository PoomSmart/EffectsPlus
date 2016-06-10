#import "Tweak.h"
#import "../EffectsFunctions.h"
#import "../Prefs.h"
#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

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

static CIImage *ciImageInternalFixIfNecessary(CIImage *outputImage, CIFilter *itsFilter)
{
	if (!globalFilterHook)
		return outputImage;
	CGRect rect = itsFilter.inputImage.extent;
	CIImage *fixedImage = [outputImage imageByCroppingToRect:rect];
	return fixedImage;
}

static NSDictionary *dictionaryByAddingSomeNativeValues(NSDictionary *inputDict)
{
	NSMutableDictionary *mutableInputDict = [NSMutableDictionary dictionary];
	[mutableInputDict addEntriesFromDictionary:inputDict];
	NSMutableArray *filterCategoriesArray = [NSMutableArray array];
	[filterCategoriesArray addObjectsFromArray:mutableInputDict[@"CIAttributeFilterCategories"]];
	if (filterCategoriesArray == nil)
		return inputDict;
	if (![filterCategoriesArray containsObject:@"CICategoryXMPSerializable"])
		[filterCategoriesArray addObject:@"CICategoryXMPSerializable"];
	[mutableInputDict setObject:filterCategoriesArray forKey:@"CIAttributeFilterCategories"];
	return mutableInputDict;
}

%hook CIFilter

+ (NSArray *)filterNamesInCategories:(NSArray *)categories
{
	NSMutableArray *orig = [NSMutableArray array];
	[orig addObjectsFromArray:%orig];
	if (orig != nil)
		[orig addObject:CINoneName];
	return orig;
}

- (NSString *)_serializedXMPString
{
	NSString *name = %orig;
	return name == nil ? self.name : name;
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

PLProgressHUD *epHUD = nil;

static void effectCorrection(CIFilter *filter, CGRect extent, int orientation)
{
	NSString *filterName = filter.name;
	CIVector *normalHalfExtent = [CIVector vectorWithX:extent.size.width / 2 Y:extent.size.height / 2];
	CIVector *invertHalfExtent = [CIVector vectorWithX:extent.size.height / 2 Y:extent.size.width / 2];
	BOOL normal = (orientation == 5 || orientation == 6);
	CIVector *globalCenter = normal ? normalHalfExtent : invertHalfExtent;
	#define valueCorrection(value) @((extent.size.width / 640) * value)
	if ([filterName isEqualToString:@"CIMirror"]) {
		[(CIMirror *)filter setInputPoint:normalHalfExtent];
		[(CIMirror *)filter setInputAngle:@(1.5 * M_PI + CIMirror_inputAngle)];
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
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI / 2 + CITwirlDistortion_inputAngle)];
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
	NSUInteger filtersCount = filters.count;
	if (filtersCount == 0)
		return %orig;
	internalBlurHook = YES;
	globalFilterHook = YES;
	CGRect extent = [image extent];
	for (CIFilter *filter in filters) {
		if (![filter respondsToSelector:@selector(_outputProperties)])
			effectCorrection(filter, extent, orientation);
	}

	/*NSMutableArray *mutableFiltersArray = [NSMutableArray array];
	[mutableFiltersArray addObjectsFromArray:filters];*/
	/*if (filtersCount > 1) {
		for (NSUInteger i = 0; i < filters.count; i++) {
			if (![(CIFilter *)mutableFiltersArray[i] respondsToSelector:@selector(_outputProperties)]) {
				if (i != 0) {
					[mutableFiltersArray insertObject:mutableFiltersArray[i] atIndex:0];
					[mutableFiltersArray removeObjectAtIndex:i + 1];
				}
			}
		}
	}*/
	CIImage *outputImage = %orig(/*mutableFiltersArray*/filters, image, orientation, copyFirst);
	internalBlurHook = NO;
	globalFilterHook = NO;
	return outputImage;
}

%end

static void _addCIEffect(NSString *displayName, NSString *filterName, NSObject <effectFilterManagerDelegate> *manager)
{
	CIFilter *filter = [CIFilter filterWithName:filterName];
	if (![MSHookIvar<NSMutableArray *>(manager, "_effects") containsObject:filter]) {
		configEffect(filter);
		[manager _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter];
	}
}

static void addExtraSortedEffects(NSObject <effectFilterManagerDelegate> *effectFilterManager)
{
	#define addCIEffect(arg) _addCIEffect(displayNameFromCIFilterName(arg), arg, effectFilterManager)
	if (enabledArray == nil)
		return;
	NSMutableArray *allEffects = MSHookIvar<NSMutableArray *>(effectFilterManager, "_effects");
	NSMutableArray *names = MSHookIvar<NSMutableArray *>(effectFilterManager, "_names");
	NSMutableArray *aggdNames = MSHookIvar<NSMutableArray *>(effectFilterManager, "_aggdNames");
	[allEffects removeAllObjects];
	[names removeAllObjects];
	[aggdNames removeAllObjects];
	for (int i = 0; i < enabledArray.count; i++) {
		NSString *string = enabledArray[i];
		addCIEffect(string);
	}
}

static void showFilterSelectionAlert(id self)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tweakName message:@"ERROR: The selected filter isn't existed in the current library. You have to enable this filter in settings first." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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

- (NSUInteger)_filterIndexForGridIndex:(NSUInteger)index
{
	return [self isBlackAndWhite] ? index + [(PLEffectFilterManager *)[%c(PLEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_gridIndexForFilterIndex:(NSUInteger)index
{
	return [self isBlackAndWhite] ? index - [(PLEffectFilterManager *)[%c(PLEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_cellsPerRow
{
	NSUInteger filterCount = [(PLEffectFilterManager *)[%c(PLEffectFilterManager) sharedInstance] filterCount];
	int i = 1;
	do {
		if (filterCount <= i * i)
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
	return enabledArray != nil ? enabledArray.count : orig;
}

- (void)_updatePixelBufferPoolForSize:(CGSize)size
{
	%orig(CGSizeMake(size.width * qualityFactor, size.height * qualityFactor));
}

- (CVBufferRef)_createPixelBufferForSize:(CGSize)size
{
	return %orig(CGSizeMake(size.width * qualityFactor, size.height * qualityFactor));
}

%end

%hook PLCameraView

- (void)_updateFilterButtonOnState
{
	%orig;
	CIFilter *currentFilter = [(PLEffectFilterManager *)[%c(PLEffectFilterManager) sharedInstance] filterForIndex:[(PLCameraController *)[%c(PLCameraController) sharedInstance] _activeFilterIndex]];
	CAMFilterButton *filterButton = MSHookIvar<CAMFilterButton *>(self, "__filterButton");
	BOOL shouldOn = currentFilter == nil ? NO : ![currentFilter.name isEqualToString:CINoneName];
	[filterButton setOn:shouldOn];
}

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	if (AutoHideBB) {
		self._bottomBar.hidden = showEffectsGrid;
		self._topBar.hidden = showEffectsGrid;
	}
}

%end

%hook PLEffectSelectionViewController

- (NSArray *)_generateFilters
{
	PLEffectFilterManager *manager = (PLEffectFilterManager *)[%c(PLEffectFilterManager) sharedInstance];
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
	if (filter) {
		NSArray *filters = MSHookIvar<NSArray *>(self, "_effects");
		for (int i = 0; i < filters.count; i++) {
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

- (NSUInteger)_cellsPerRow
{
	NSUInteger filterCount = [(CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance] filterCount];
	int i = 1;
	do {
		if (filterCount <= i * i)
			break;
		i++;
	} while (1);
	return i;
}

- (NSUInteger)_filterIndexForGridIndex:(NSUInteger)index
{
	return [self isBlackAndWhite] ? index + [(CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

- (NSUInteger)_gridIndexForFilterIndex:(NSUInteger)index
{
	return [self isBlackAndWhite] ? index - [(CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance] blackAndWhiteFilterStartIndex] : index;
}

%end

%hook CAMCameraView

- (void)_updateFilterButtonOnState
{
	%orig;
	CIFilter *currentFilter = [(CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance] filterForIndex:[(CAMCaptureController *)[%c(CAMCaptureController) sharedInstance] _activeFilterIndex]];
	CAMFilterButton *filterButton = MSHookIvar<CAMFilterButton *>(self, "__filterButton");
	BOOL shouldOn = currentFilter == nil ? NO : ![currentFilter.name isEqualToString:CINoneName];
	filterButton.on = shouldOn;
}

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	if (AutoHideBB) {
		self._bottomBar.hidden = showEffectsGrid;
		self._topBar.hidden = showEffectsGrid;
	}
}

%end

%hook CAMEffectSelectionViewController

- (NSArray *)_generateFilters
{
	CAMEffectFilterManager *manager = (CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance];
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
	if (filter) {
		NSArray *filters = MSHookIvar<NSArray *>(self, "_effects");
		for (int i = 0; i < filters.count; i++) {
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

%end

%group iOS9

//BOOL mirrorRendering = NO;

%hook CAMEffectsRenderer

/*- (void)setMirrorFilterRendering:(BOOL)mirror
{
	%orig(mirrorRendering = mirror);
}*/

%end

%hook CAMEffectFilterManager

+ (NSString *)ciFilterNameForType:(int)type
{
	if (enabledArray.count == 0 || type > enabledArray.count)
		return %orig;
	return enabledArray[type - 1];
}

+ (CIFilter *)newFilterForType:(int)type
{
	if (cachedEffects.count == 0 || type > cachedEffects.count)
		return %orig;
	CIFilter *filter = [cachedEffects[type - 1] retain];
	configEffect(filter);
	return filter;
}

+ (NSString *)displayNameForType:(int)type
{
	if (enabledArray.count == 0 || type > enabledArray.count)
		return %orig;
	return displayNameFromCIFilterName(enabledArray[type - 1]);
}

+ (NSString *)aggdNameForType:(int)type
{
	if (enabledArray.count == 0 || type > enabledArray.count)
		return %orig;
	return [[self displayNameForType:type] lowercaseString];
}

%end

%hook CAMEffectsGridView

- (NSUInteger)_cellsPerRow
{
	NSUInteger filterCount = enabledArray.count;
	if (filterCount == 0)
		return %orig;
	int i = 1;
	do {
		if (filterCount <= i * i)
			break;
		i++;
	} while (1);
	return i;
}

- (NSArray *)filterTypes
{
	NSUInteger filterCount = enabledArray.count;
	if (filterCount == 0)
		return %orig;
	NSMutableArray *filters = [NSMutableArray array];
	for (NSInteger i = 0; i < filterCount; i++)
		[filters addObject:[NSNumber numberWithInteger:(i + 1)]];
	return filters;
}

/*- (void)_setGridFilters:(NSDictionary *)filters
{
	int orientation = mirrorRendering ? 5 : 6;
	NSMutableDictionary *mfilters = [NSMutableDictionary dictionary];
	[mfilters addEntriesFromDictionary:filters];
	NSArray *allKeys = [mfilters allKeys];
	for (int i = 0; i < allKeys.count; i++) {
		CIFilter *filter = [mfilters[allKeys[i]] retain];
		effectCorrection(filter, [self rectForFilterType:i], orientation);
		[mfilters setObject:filter forKey:allKeys[i]];
		[filter release];
	}
	%orig(mfilters);
}*/

- (NSUInteger)_filterTypeForGridIndex:(NSUInteger)index
{
	return index + 1;
}

- (NSUInteger)_gridIndexForFilterType:(NSUInteger)type
{
	if (type == 0)
		return 0;
	return type - 1;
}

%end

// CAMCaptureEngine completeLegacyStillImageCaptureRequest:withResult:

%hook CAMEffectsFullsizeView

- (CIFilter *)_updateSelectedFilter
{
	CIFilter *filter = [%orig retain];
	//int orientation = mirrorRendering ? 5 : 6;
	//CGSize size = self.fixedSize;
	//effectCorrection(filter, CGRectMake(0, 0, size.width, size.height), orientation);
	cachedEffects[self.filterType - 1] = filter;
	return [filter autorelease];
}

%end

%end

%group iOS8Up

%hook CAMEffectsGridView

- (NSUInteger)_cellCount
{
	NSUInteger orig = %orig;
	if (FillGrid)
		return orig;
	return enabledArray ? enabledArray.count : orig;
}

%end

%hook PLPhotoEffect

static NSMutableArray *effects = nil;
static NSMutableArray *effectsForiOS8()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		effects = [NSMutableArray array];
		CAMEffectFilterManager *manager = (CAMEffectFilterManager *)[%c(CAMEffectFilterManager) sharedInstance];
		NSMutableArray *camEffects = MSHookIvar<NSMutableArray *>(manager, "_effects");
		NSMutableArray *ourCamEffects = [NSMutableArray arrayWithArray:camEffects];
		if (![(PUPhotoEditProtoSettings *)[%c(PUPhotoEditProtoSettings) sharedInstance] useOldPhotosEditor2]) {
			NSMutableArray *camEffectsToBeRemoved = [NSMutableArray array];
			for (NSUInteger i = 0; i < ourCamEffects.count; i++) {
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
	for (NSUInteger i = 0; i < allEffects.count; i++) {
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
	for (int i = 0; i < allEffects.count; i++) {
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
	NSString *actualImagePath = isiOS8Up ? asset.pathForOriginalFile : asset.pathForImageFile;
	UIImage *actualImage = [UIImage imageWithContentsOfFile:actualImagePath];
	NSMutableArray *effectFilters = [NSMutableArray array];
	[effectFilters addObjectsFromArray:[self _currentNonGeometryFiltersWithEffectFilters:MSHookIvar<NSArray *>(self, "_effectFilters")]];
	CIImage *ciImage = [self _newCIImageFromUIImage:actualImage];
	
	// Fixing image orientation, still dirt (?)
	int orientation = 1;
	CGFloat rotation = MSHookIvar<CGFloat>(self, "_rotationAngle");
	CGFloat angle = rotation;
	
	if (angle > 6)
		angle = fmodf(rotation, 2 * M_PI);
	if (round(fabs(angle)) == 3)
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

%ctor
{
	HaveObserver()
	callback();
	BOOL isAssetsd = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.assetsd"];
	if (TweakEnabled) {
		if (!isAssetsd) {
			if (isiOS8Up) {
				dlopen("/System/Library/PrivateFrameworks/PhotoLibraryServices.framework/PhotoLibraryServices", RTLD_LAZY);
				dlopen("/System/Library/Frameworks/PhotosUI.framework/PhotosUI", RTLD_LAZY);
				if (isiOS9Up) {
					openCamera9();
					%init(iOS9);
				} else {
					openCamera8();
					%init(iOS8);
				}
				%init(iOS8Up);
			}
			else if (isiOS7) {
				openCamera7();
				%init(iOS7);
			}
			%init;
		}
	}
}