#import "../Common.h"
#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>

static BOOL TweakEnabled;
static BOOL FillGrid;
static BOOL AutoHideBB;

static NSString *identifierFix;
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

static float qualityFactor;

%hook PLManagedAsset

// Workaround for bypassing the filter identifier checking
- (id)_serializedPropertyDataFromFilter:(CIFilter *)filter
{
	return [filter _outputProperties];
}

// -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] is called here
- (CIImage *)filteredImage:(CIImage *)inputImage withCIContext:(CIContext *)context
{
	globalFilterHook = YES;
	internalBlurHook = YES;
	CIImage *outputImage = %orig();
	globalFilterHook = NO;
	internalBlurHook = NO;
	return outputImage;
}

// -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] is called here
- (void)generateThumbnailsWithImageSource:(CGImageSourceRef)arg1 imageData:(id)arg2 updateExistingLargePreview:(BOOL)arg3 allowMediumPreview:(BOOL)arg4 outSmallThumbnail:(id *)arg5 outLargeThumbnail:(id *)arg6
{
	globalFilterHook = YES;
	internalBlurHook = YES;
	%orig;
	globalFilterHook = NO;
	internalBlurHook = NO;
}

%end

NSString * const anotherFilter = nil;

%hook CIFilter

// This method returns filters identifier
- (NSString *)_serializedXMPString
{
	return identifierFix != nil ? identifierFix : %orig;
}

// The identifier of the unofficial filters are injected in this method
+ (id)_pl_propertyArrayFromFilters:(NSArray *)filterArray inputImageExtent:(id)arg2
{
	identifierFix = NSStringFromClass([[filterArray objectAtIndex:0] class]);
	return %orig;
}

%end

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
	CGRect rect = self.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:resultImage fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

// Some CIFilters reduce the image size, we have to fix that
static inline CIImage *ciImageInternalFixIfNecessary(CIImage *outputImage, CIFilter *itsFilter)
{
	if (!globalFilterHook)
		return outputImage;
	CGRect rect = itsFilter.inputImage.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:outputImage fromRect:rect];
	CIImage *fixedOutputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return fixedOutputImage;
}

/*static inline NSDictionary *dictionaryByAddingXMPSerializable(NSDictionary *inputDict)
{
	NSMutableDictionary *mutableInputDict = [inputDict mutableCopy];
	NSMutableArray *filterCategoriesArray = [(NSArray *)[mutableInputDict objectForKey:@"CIAttributeFilterCategories"] mutableCopy];
	if (filterCategoriesArray == nil)
		return inputDict;
	if (![filterCategoriesArray containsObject:@"CICategoryXMPSerializable"])
		[filterCategoriesArray addObject:@"CICategoryXMPSerializable"];
	[mutableInputDict setObject:filterCategoriesArray forKey:@"CIAttributeFilterCategories"];
	return (NSDictionary *)mutableInputDict;
}*/

%hook CIGaussianBlur

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIStretch

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIMirror

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CITriangleKaleidoscope

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIPinchDistortion

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CITwirlDistortion

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
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

/*%hook CIThermal
%end

%hook CIBloom
%end

%hook CIGloom
%end

%hook CIPhotoEffectMono
%end

%hook CIPhotoEffectNoir
%end

%hook CIPhotoEffectProcess
%end

%hook CIPhotoEffectTonal
%end

%hook CIPhotoEffectFade
%end

%hook CIPhotoEffectChrome
%end

%hook CIPhotoEffectTransfer
%end

%hook CIPhotoEffectInstant
%end*/

%hook PLImageAdjustmentView

// Workaround for preventing the mismatch of image size checking, it causes crashing if the old image size is not equal to the edited image size
- (void)replaceEditedImage:(UIImage *)image
{
	[self setEditedImage:image];
}

%end

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
	unsigned filterCount = [[%c(PLEffectFilterManager) sharedInstance] filterCount];
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
	return 9 + [(NSArray *)[prefDict objectForKey:@"EnabledEffects"] count];
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

%hook PLEffectsGridLabelsView

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

%end

static void effectCorrection(CIFilter *filter, CGRect extent, int orientation)
{
	NSString *filterName = filter.name;
	CIVector *normalHalfExtent = [CIVector vectorWithX:extent.size.width/2 Y:extent.size.height/2];
	CIVector *invertHalfExtent = [CIVector vectorWithX:extent.size.height/2 Y:extent.size.width/2];
	BOOL normal = (orientation == 1 || orientation == 3 || orientation == 5 || orientation == 6 || orientation == 8);
	#define valueCorrection(value) @((extent.size.width/640)*value)
	if ([filterName isEqualToString:@"CIMirror"]) {
		[(CIMirror *)filter setInputPoint:normalHalfExtent];
		if (orientation != 1)
			[(CIMirror *)filter setInputAngle:@(1.5*M_PI)];
	}
	else if ([filterName isEqualToString:@"CITriangleKaleidoscope"]) {
		[(CITriangleKaleidoscope *)filter setInputPoint:normalHalfExtent];
		[(CITriangleKaleidoscope *)filter setInputSize:valueCorrection(CITriangleKaleidoscope_inputSize)];
	}
	else if ([filterName isEqualToString:@"CIPixellate"])
		[(CIPixellate *)filter setInputScale:valueCorrection(CIPixellate_inputScale)];
	else if ([filterName isEqualToString:@"CIStretch"])
		[(CIStretch *)filter setInputPoint:normal ? normalHalfExtent : invertHalfExtent];
	else if ([filterName isEqualToString:@"CIPinchDistortion"]) {
		[(CIPinchDistortion *)filter setInputRadius:valueCorrection(CIPinchDistortion_inputRadius)];
		[(CIPinchDistortion *)filter setInputCenter:normal ? normalHalfExtent : invertHalfExtent];
	}
	else if ([filterName isEqualToString:@"CITwirlDistortion"]) {
		[(CITwirlDistortion *)filter setInputRadius:valueCorrection(CITwirlDistortion_inputRadius)];
		[(CITwirlDistortion *)filter setInputCenter:normal ? normalHalfExtent : invertHalfExtent];
	}
	else if ([filterName isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputRadius:valueCorrection(CIGloom_inputRadius)];
	else if ([filterName isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputRadius:valueCorrection(CIBloom_inputRadius)];
	else if ([filterName isEqualToString:@"CIGaussianBlur"])
		[(CIGaussianBlur *)filter setInputRadius:valueCorrection(CIGaussianBlur_inputRadius)];
	else if ([filterName isEqualToString:@"CISharpenLuminance"])
		[(CISharpenLuminance *)filter setInputSharpness:valueCorrection(CISharpenLuminance_inputSharpness)];
}

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
	CIFilter *filter1 = (CIFilter *)[filters objectAtIndex:0];
	/*CIFilter *anotherFilter = nil;
	NSString *filter2 = filter1.anotherFilter;*/
	//BOOL multiple = (filter2 != nil);
	effectCorrection(filter1, extent, orientation);
	/*if (multiple) {
		anotherFilter = [CIFilter filterWithName:filter2];
		effectCorrection(anotherFilter, extent, orientation);
	}*/
	
	// Multiple filters is possible! I will add this feature soon ;)
	CIImage *outputImage = %orig(/*multiple ? @[filter1, anotherFilter] : */filters, image, orientation, copyFirst);
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
}

static void _addCIEffect(NSString *displayName, NSString *filterName, PLEffectFilterManager *manager)
{
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
		#define addCIEffect(arg) _addCIEffect(displayNameFromCIFilterName(arg), arg, manager)
		NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
		if (prefDict != nil) {
			NSMutableArray *effects = [[prefDict objectForKey:@"EnabledEffects"] mutableCopy];
			for (int i=0;i<[effects count];i++) {
				NSString *string = [effects objectAtIndex:i];
				addCIEffect(string);
			}
		} else {
			addCIEffect(@"CISepiaTone"); addCIEffect(@"CIVibrance"); addCIEffect(@"CIColorInvert");
			addCIEffect(@"CIColorMonochrome"); addCIEffect(@"CIColorPosterize"); addCIEffect(@"CIGloom");
			addCIEffect(@"CIBloom"); addCIEffect(@"CISharpenLuminance"); addCIEffect(@"CILinearToSRGBToneCurve");
			addCIEffect(@"CIPixellate"); addCIEffect(@"CIGaussianBlur"); addCIEffect(@"CIFalseColor");
			addCIEffect(@"CITwirlDistortion"); addCIEffect(@"CIWrapMirror"); addCIEffect(@"CIStretch");
			addCIEffect(@"CIMirror"); addCIEffect(@"CITriangleKaleidoscope"); addCIEffect(@"CIPinchDistortion");
			addCIEffect(@"CIThermal"); //addCIEffect(@"CIBloom_CIThermal");
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
		val = [dict objectForKey:[NSString stringWithUTF8String:#val]] ? [[dict objectForKey:[NSString stringWithUTF8String:#val]] floatValue] : defaultVal
	readFloat(CIColorMonochrome_R, .5);
	readFloat(CIColorMonochrome_G, .6);
	readFloat(CIColorMonochrome_B, .7);
	readFloat(CIFalseColor_R1, .5);
	readFloat(CIFalseColor_G1, .6);
	readFloat(CIFalseColor_B1, .7);
	readFloat(CIFalseColor_R2, .5);
	readFloat(CIFalseColor_G2, .6);
	readFloat(CIFalseColor_B2, .7);
	readFloat(CISepiaTone_inputIntensity, 1);
	readFloat(CIVibrance_inputAmount, 1);
	readFloat(CIColorMonochrome_inputIntensity, 1);
	readFloat(CIColorPosterize_inputLevels, 6);
	readFloat(CIGloom_inputRadius, 10);
	readFloat(CIGloom_inputIntensity, 1);
	readFloat(CIBloom_inputRadius, 10);
	readFloat(CIBloom_inputIntensity, 1);
	readFloat(CISharpenLuminance_inputSharpness, .4);
	readFloat(CIPixellate_inputScale, 8);
	readFloat(CIGaussianBlur_inputRadius, 10);
	readFloat(CITwirlDistortion_inputRadius, 300);
	readFloat(CITwirlDistortion_inputAngle, 3.14);
	CITwirlDistortion_inputAngle *= M_PI/180;
	readFloat(CITriangleKaleidoscope_inputSize, 300);
	readFloat(CITriangleKaleidoscope_inputDecay, .85);
	readFloat(CIPinchDistortion_inputRadius, 300);
	readFloat(CIPinchDistortion_inputScale, .5);
	
	readFloat(qualityFactor, 1);
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall Camera MobileSlideshow");
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