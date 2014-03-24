#import "../Common.h"
#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>

static BOOL TweakEnabled;
static BOOL FillGrid;
static BOOL AutoHideBB;

static BOOL internalBlurHook = NO;
static BOOL globalFilterHook = NO;

static float CISepiaTone_inputIntensity;
static float CIVibrance_inputAmount;
static float CIColorMonochrome_inputIntensity;
static float CIColorMonochrome_R, CIColorMonochrome_G, CIColorMonochrome_B;
static float CIColorPosterize_inputLevels;
static float CIGloom_inputRadius, CIGloom_inputIntensity;
static float CIBloom_inputRadius, CIBloom_inputIntensity;
static float CISharpenLuminance_inputSharpness;
static float CIPixellate_inputScale;
static float CIGaussianBlur_inputRadius;
static float CIFalseColor_R1, CIFalseColor_G1, CIFalseColor_B1;
static float CIFalseColor_R2, CIFalseColor_G2, CIFalseColor_B2;
static float CITwirlDistortion_inputRadius, CITwirlDistortion_inputAngle;
static float CITriangleKaleidoscope_inputSize, CITriangleKaleidoscope_inputDecay;
static float CIPinchDistortion_inputRadius, CIPinchDistortion_inputScale;
static float CILightTunnel_inputRadius, CILightTunnel_inputRotation;
static float CIHoleDistortion_inputRadius;
static float CICircleSplashDistortion_inputRadius;

static float qualityFactor;

//NSString * const anotherFilter = nil;

%hook CIImage

// This method will be very nice if it doesn't reduce the image size, so we have to fix that
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

// Some CIFilters reduce the image size, we have to fix that
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
	NSMutableArray *filterCategoriesArray = [(NSArray *)[mutableInputDict objectForKey:@"CIAttributeFilterCategories"] mutableCopy];
	if (filterCategoriesArray == nil)
		return inputDict;
	if (![filterCategoriesArray containsObject:@"CICategoryXMPSerializable"])
		[filterCategoriesArray addObject:@"CICategoryXMPSerializable"];
	[mutableInputDict setObject:filterCategoriesArray forKey:@"CIAttributeFilterCategories"];
	return (NSDictionary *)mutableInputDict;
}

%hook CIFilter

// Some filters that cannot be serialized will be replaced their fake serialized XMP string with their name instead
- (NSString *)_serializedXMPString
{
	NSString *name = %orig;
	return name == nil ? [self name] : name;
}

%end

%hook CIGaussianBlur

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

/*%new
- (void)setAnotherFilter:(NSString *)filter
{
	objc_setAssociatedObject(self, anotherFilter, filter, OBJC_ASSOCIATION_COPY);
}
 
%new
- (NSString *)anotherFilter
{
	return objc_getAssociatedObject(self, anotherFilter);
}
*/

%hook PLCameraView

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	if (AutoHideBB)
		self._bottomBar.hidden = showEffectsGrid;
}

%end

%hook PLEffectsGridView

// Set the exact cell count per row of the filters grid to fit all filters there
- (unsigned)_cellsPerRow
{
	unsigned filterCount = 1 + [[%c(PLEffectFilterManager) sharedInstance] filterCount];
	if (filterCount <= 9)
		return %orig;
	if (filterCount <= 16)
		return 4;
	if (filterCount <= 25)
		return 5;
	if (filterCount <= 36)
		return 6;
	return %orig;
}

// Return the exact filters count to reduce the CPU processing for filters
- (unsigned)_cellCount
{
	if (FillGrid)
		return %orig;
	NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	NSArray *enabledArray = (NSArray *)[prefDict objectForKey:ENABLED_EFFECT];
	return enabledArray != nil ? 1 + [enabledArray count] : %orig;
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
		[(CIMirror *)filter setInputAngle:@(1.5*M_PI)];
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
}

%hook PLImageAdjustmentView
//_editedImageFullSize
// The replaced implementation without image size check, to prevent crashing exception
- (void)replaceEditedImage:(UIImage *)image
{
	[MSHookIvar<UIImage *>(self, "_editedImage") release];
	MSHookIvar<UIImage *>(self, "_editedImage") = [image retain];
	[MSHookIvar<UIImageView *>(self, "_imageView") setImage:[MSHookIvar<UIImage *>(self, "_editedImage") retain]];
	[self setEditedImage:[MSHookIvar<UIImage *>(self, "_editedImage") retain]];
}

%end

/*%hook PLEditPhotoController

%new
- (void)EPSavePhoto
{
	[self _saveAdjustmentsToCopy];
}

- (void)_updateToolbarSetHiddenState:(int)arg1
{
	%orig;
	UIBarButtonItem *old = ((UINavigationItem *)[self navigationItem]).rightBarButtonItem;
	if ([old.title isEqualToString:@"EP+"])
		return;
	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"EP+" style:UIBarButtonItemStylePlain target:self action:@selector(EPSavePhoto)];
	[((UINavigationItem *)[self navigationItem]) setRightBarButtonItems:@[old, save] animated:YES];
	[save release];
}

%end*/

%hook PLCIFilterUtilities

// This method is very important for rendering filters (Yes, more than 1 filter is permitted) onto the image, is used by Camera and Photos app
// These CIFilter written here need some modification in order to make them work correctly
+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)image orientation:(int)orientation copyFiltersFirst:(BOOL)copyFirst
{
	if ([filters count] == 0)
		return %orig; // FIXME: This causes crashing if there are no filters in the array
	internalBlurHook = YES;
	globalFilterHook = YES;
	CGRect extent = [image extent];
	CIFilter *filter1;
	if ([filters count] > 1) {
		for (CIFilter *filter in filters) {
			if (![filter respondsToSelector:@selector(_outputProperties)]) {
				filter1 = filter;
				break;
			}
		}
	} else
		filter1 = (CIFilter *)[filters objectAtIndex:0];
	/*CIFilter *anotherFilter = nil;
	NSString *filter2 = filter1.anotherFilter;*/
	//BOOL multiple = (filter2 != nil);
	effectCorrection(filter1, extent, orientation);
	/*if (multiple) {
		anotherFilter = [CIFilter filterWithName:filter2];
		effectCorrection(anotherFilter, extent, orientation);
	}*/
	
	// Multiple filters is possible! I will add this feature soon ;)
	/*multiple ? @[filter1, anotherFilter] : */
	NSMutableArray *mutableFiltersArray = [filters mutableCopy];
	if ([filters count] > 1) {
		for (int i=0; i<[filters count]; i++) {
			NSString *filterName = ((CIFilter *)[mutableFiltersArray objectAtIndex:i]).name;
			if (![filterName isEqualToString:@"CICrop"] && ![filterName isEqualToString:@"CIRedEyeCorrections"] && ![filterName isEqualToString:@"CIAffineTransform"]) {
				if (i != 0) {
					[mutableFiltersArray insertObject:[mutableFiltersArray objectAtIndex:i] atIndex:0];
					[mutableFiltersArray removeObjectAtIndex:i+1];
				}
			}
		}
	}
	CIImage *outputImage = %orig((NSArray *)mutableFiltersArray, image, orientation, copyFirst);
	internalBlurHook = NO;
	globalFilterHook = NO;
	return outputImage;
}

%end

static void configEffect(CIFilter *filter)
{
	if ([filter.name isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputIntensity:@(CIGloom_inputIntensity)];
	else if ([filter.name isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputIntensity:@(CIBloom_inputIntensity)];
	else if ([filter.name isEqualToString:@"CITwirlDistortion"])
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI/2+CITwirlDistortion_inputAngle)];
	else if ([filter.name isEqualToString:@"CIPinchDistortion"])
		[(CIPinchDistortion *)filter setInputScale:@(CIPinchDistortion_inputScale)];
	else if ([filter.name isEqualToString:@"CIVibrance"])
		[(CIVibrance *)filter setInputAmount:@(CIVibrance_inputAmount)];
	else if ([filter.name isEqualToString:@"CISepiaTone"])
		[(CISepiaTone *)filter setInputIntensity:@(CISepiaTone_inputIntensity)];
	else if ([filter.name isEqualToString:@"CIColorMonochrome"])
		[(CIColorMonochrome *)filter setInputColor:[CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B]];
	else if ([filter.name isEqualToString:@"CIFalseColor"]) {
		CIColor *color0 = [CIColor colorWithRed:CIFalseColor_R1 green:CIFalseColor_G1 blue:CIFalseColor_B1];
		CIColor *color1 = [CIColor colorWithRed:CIFalseColor_R2 green:CIFalseColor_G2 blue:CIFalseColor_B2];
		[(CIFalseColor *)filter setInputColor0:color0];
		[(CIFalseColor *)filter setInputColor1:color1];
	}
	else if ([filter.name isEqualToString:@"CILightTunnel"])
		[(CILightTunnel *)filter setInputRotation:@(CILightTunnel_inputRotation)];
}

static void _addCIEffect(NSString *displayName, NSString *filterName, PLEffectFilterManager *manager)
{
	if ([filterName hasPrefix:@"CIPhotoEffect"])
		return;
	CIFilter *filter1 = nil;
	/*NSString *filter2 = nil;
	NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"_"];
	NSRange r = [filterName rangeOfCharacterFromSet:s];
	if (r.location != NSNotFound) {
		NSArray *effects = [filterName componentsSeparatedByString:@"_"];
		filter1 = [CIFilter filterWithName:(NSString *)[effects objectAtIndex:0]];
		filter2 = (NSString *)[effects objectAtIndex:1];
	} else*/
		filter1 = [CIFilter filterWithName:filterName];
	//filter1.anotherFilter = filter2;
	configEffect(filter1);
	[manager _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter1];
}

%hook PLEffectFilterManager

- (PLEffectFilterManager *)init
{
	PLEffectFilterManager *manager = %orig;
	if (manager != nil) {
		if ([manager filterCount] > NORMAL_EFFECT_COUNT + 1)
			return manager;
		#define addCIEffect(arg) _addCIEffect(displayNameFromCIFilterName(arg), arg, manager)
		NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
		if (prefDict != nil) {
			NSArray *effects = [prefDict objectForKey:ENABLED_EFFECT];
			if (effects == nil)
				return manager;
			for (int i=0;i<[effects count];i++) {
				NSString *string = [effects objectAtIndex:i];
				addCIEffect(string);
			}

			// Sorting codes!
			NSMutableArray *array = [NSMutableArray array];
			NSMutableArray *allEffects = MSHookIvar<NSMutableArray *>(self, "_effects");
			NSMutableArray *names = MSHookIvar<NSMutableArray *>(self, "_names");
			NSMutableArray *aggdNames = MSHookIvar<NSMutableArray *>(self, "_aggdNames");
			for (int i = 0; i < [allEffects count]; i++) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
										(CIFilter *)[allEffects objectAtIndex:i], @"Filter",
										[names objectAtIndex:i], @"displayName",
										[aggdNames objectAtIndex:i], @"aggdName", nil];
				[array addObject:dict];
			}
			for (int i=0;i<[effects count];i++) {
				NSString *string1 = [effects objectAtIndex:i];
				NSString *string2 = ((CIFilter *)[[array objectAtIndex:i] objectForKey:@"Filter"]).name;
				if (![string1 isEqualToString:string2]) {
					for (int j=0;j<[array count];j++) {
						NSString *string3 = ((CIFilter *)[[array objectAtIndex:j] objectForKey:@"Filter"]).name;
						if ([string3 isEqualToString:string1])
							[array exchangeObjectAtIndex:i withObjectAtIndex:j];
					}
				}
			}
			NSArray *disabledEffects = [prefDict objectForKey:DISABLED_EFFECT];
			BOOL deleteSome = (disabledEffects != nil);
			if (deleteSome) {
				for (int i=0;i<[disabledEffects count];i++) {
					for (int j=0;j<[array count];j++) {
						if ([((CIFilter *)[[array objectAtIndex:j] objectForKey:@"Filter"]).name isEqualToString:[disabledEffects objectAtIndex:i]])
							[array removeObjectAtIndex:j];
					}
				}
			}
			
			// Apply the sorted stuffs
			NSMutableArray *a1 = [NSMutableArray array];
			for (int i=0;i<[array count];i++) {
				[a1 addObject:[[array objectAtIndex:i] objectForKey:@"Filter"]];
			}
			[MSHookIvar<NSMutableArray *>(self, "_effects") setArray:a1];
			
			NSMutableArray *a2 = [NSMutableArray array];
			for (int i=0;i<[array count];i++) {
				[a2 addObject:[[array objectAtIndex:i] objectForKey:@"displayName"]];
			}
			[MSHookIvar<NSMutableArray *>(self, "_names") setArray:a2];
			
			NSMutableArray *a3 = [NSMutableArray array];
			for (int i=0;i<[array count];i++) {
				[a3 addObject:[[array objectAtIndex:i] objectForKey:@"aggdName"]];
			}
			[MSHookIvar<NSMutableArray *>(self, "_aggdNames") setArray:a3];
			
		}
	}
	return manager;
}

%end

static void EPLoader()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	TweakEnabled = [[dict objectForKey:@"Enabled"] boolValue];
	FillGrid = [[dict objectForKey:@"FillGrid"] boolValue];
	AutoHideBB = [[dict objectForKey:@"AutoHideBB"] boolValue];
	#define readFloat(val, defaultVal) \
		val = [dict objectForKey:[NSString stringWithUTF8String:#val]] ? [[dict objectForKey:[NSString stringWithUTF8String:#val]] floatValue] : defaultVal;
	readFloat(CIColorMonochrome_R, .5)
	readFloat(CIColorMonochrome_G, .6)
	readFloat(CIColorMonochrome_B, .7)
	readFloat(CIFalseColor_R1, .2)
	readFloat(CIFalseColor_G1, .3)
	readFloat(CIFalseColor_B1, .5)
	readFloat(CIFalseColor_R2, .6)
	readFloat(CIFalseColor_G2, .8)
	readFloat(CIFalseColor_B2, .9)
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
	CITwirlDistortion_inputAngle *= M_PI/180;
	readFloat(CITriangleKaleidoscope_inputSize, 300)
	readFloat(CITriangleKaleidoscope_inputDecay, .85)
	readFloat(CIPinchDistortion_inputRadius, 200)
	readFloat(CIPinchDistortion_inputScale, .5)
	readFloat(CILightTunnel_inputRadius, 90)
	readFloat(CILightTunnel_inputRotation, 0)
	readFloat(CIHoleDistortion_inputRadius, 150)
	readFloat(CICircleSplashDistortion_inputRadius, 150)
	
	readFloat(qualityFactor, 1)
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall Camera MobileSlideShow");
	EPLoader();
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	EPLoader();
	if (!TweakEnabled) {
		[pool drain];
		return;
	}
	%init;
	[pool drain];
}
