#import "../Common.h"
#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>

static NSString *identifierFix;
static BOOL internalBlurHook = NO;
static BOOL globalFilterHook = NO;

static float CISepiaTone_inputIntensity;
static float CIVibrance_inputAmount;
static float CIColorMonochrome_inputIntensity;
static float CIColorMonochrome_R, CIColorMonochrome_G, CIColorMonochrome_B;
static float CIPosterize_inputLevels;
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

- (CIImage *)filteredImage:(CIImage *)inputImage withCIContext:(CIContext *)context
{
	globalFilterHook = YES;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		globalFilterHook = NO;
	});
	return %orig;
}

- (void)generateThumbnailsWithImageSource:(CGImageSourceRef)arg1 imageData:(id)arg2 updateExistingLargePreview:(BOOL)arg3 allowMediumPreview:(BOOL)arg4 outSmallThumbnail:(id *)arg5 outLargeThumbnail:(id *)arg6
{
	globalFilterHook = YES;
	%orig;
	globalFilterHook = NO;
}

%end

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

%hook PLImageAdjustmentView

// Workaround for preventing the mismatch of image size checking, it causes crashing if the old image size is not equal to the edited image size
- (void)replaceEditedImage:(UIImage *)image
{
	[self setEditedImage:image];
}

%end

%hook PLImageUtilties

// This very long method call -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] so we have to override that method here
+ (BOOL)generateThumbnailsFromJPEGData:(id)data inputSize:(CGSize)size preCropLargeThumbnailSize:(BOOL)crop postCropLargeThumbnailSize:(CGSize)arg4 preCropSmallThumbnailSize:(CGSize)arg5 postCropSmallThumbnailSize:(CGSize)arg6 outSmallThumbnailImageRef:(CGImage *)arg7 outLargeThumbnailImageRef:(CGImage *)arg8 outLargeThumbnailJPEGData:(id *)arg9 generateFiltersBlock:(void(^)(void))arg10
{
	globalFilterHook = YES;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		globalFilterHook = NO;
	});
	return %orig;
}

%end

%hook PLCameraView

- (void)cameraController:(id)controller didStartTransitionToShowEffectsGrid:(BOOL)showEffectsGrid animated:(BOOL)animated
{
	%orig;
	self._bottomBar.hidden = showEffectsGrid;
}

%end

%hook PLEffectsGridView

// Set the exact cell count per row of the filters grid to fit all filters there
- (unsigned)_cellsPerRow
{
	if ([self _cellCount] <= 9)
		return %orig;
	if ([self _cellCount] <= 16)
		return 4;
	if ([self _cellCount] <= 25)
		return 5;
	if ([self _cellCount] <= 36)
		return 6;
	return %orig;
}

// Return the exact filters count to reduce the CPU processing for filters
- (unsigned)_cellCount
{
	NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
	return 9 + [[(NSArray *)[prefDict objectForKey:@"EnabledEffects"] mutableCopy] count];
}

// No more internal hook after its -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] call
- (void)_renderGridFilters:(id)filters withInputImage:(id)inputImage ciContext:(id)context mirrorRendering:(BOOL)rendering
{
	%orig;
	internalBlurHook = NO;
	globalFilterHook = NO;
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

%hook PLCIFilterUtilities

// This method is very important for rendering filters (Yes, more than 1 filter is permitted) onto the image, is used by Camera and Photos app
// These CIFilter written here need some modification in order to make them work correctly
+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)image orientation:(int)orientation copyFiltersFirst:(BOOL)copyFirst
{
	if ([filters count] == 0)
		return %orig; // FIXME: This causes crashing if there are no filters in the array
	@autoreleasepool {
		CIFilter *filter = (CIFilter *)[filters objectAtIndex:0];
		NSString *filterName = filter.name;
		if ([filterName isEqualToString:@"CIBloom"] || [filterName isEqualToString:@"CIGloom"])
			internalBlurHook = YES;
		if ([filterName isEqualToString:@"CIGaussianBlur"] ||
			[filterName isEqualToString:@"CIStretch"] ||
			[filterName isEqualToString:@"CIMirror"] ||
			[filterName isEqualToString:@"CITriangleKaleidoscope"] ||
			[filterName isEqualToString:@"CITwirlDistortion"] ||
			[filterName isEqualToString:@"CIPinchDistortion"])
			globalFilterHook = YES;
		CGRect extent = [image extent];
		CIVector *normalHalfExtent = [CIVector vectorWithX:extent.size.width/2 Y:extent.size.height/2];
		CIVector *invertHalfExtent = [CIVector vectorWithX:extent.size.height/2 Y:extent.size.width/2];
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
		else if ([filterName isEqualToString:@"CIPixellate"]) {
			[(CIPixellate *)filter setInputScale:valueCorrection(CIPixellate_inputScale)];
		}
		else if ([filterName isEqualToString:@"CIStretch"]) {
			[(CIStretch *)filter setInputPoint:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
		}
		else if ([filterName isEqualToString:@"CIPinchDistortion"]) {
			[(CIPinchDistortion *)filter setInputRadius:valueCorrection(CIPinchDistortion_inputRadius)];
			[(CIPinchDistortion *)filter setInputCenter:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
		}
		else if ([filterName isEqualToString:@"CITwirlDistortion"]) {
			[(CITwirlDistortion *)filter setInputRadius:valueCorrection(CITwirlDistortion_inputRadius)];
			[(CITwirlDistortion *)filter setInputCenter:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
		}
	}
	// Multiple filters is possible! I will add this feature soon ;)
	return %orig;
}

%end

%hook PLEffectsFullsizeView

// No more internal hook after its -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] call
- (void)_renderWithInputImage:(id)inputImage ciContext:(id)context mirrorRendering:(BOOL)rendering
{
	%orig;
	internalBlurHook = NO;
	globalFilterHook = NO;
}

%end

static void _addCIEffect(NSString *displayName, NSString *filterName, PLEffectFilterManager *manager)
{
	CIFilter *filter = [CIFilter filterWithName:filterName];
	if ([filter.name isEqualToString:@"CIGloom"]) {
		[(CIGloom *)filter setInputIntensity:@(CIGloom_inputIntensity)];
		[(CIGloom *)filter setInputRadius:@(CIGloom_inputRadius)];
	}
	else if ([filter.name isEqualToString:@"CIBloom"]) {
		[(CIBloom *)filter setInputIntensity:@(CIBloom_inputIntensity)];
		[(CIBloom *)filter setInputRadius:@(CIBloom_inputRadius)];
	}
	else if ([filter.name isEqualToString:@"CITwirlDistortion"])
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI/2+CITwirlDistortion_inputAngle)];
	else if ([filter.name isEqualToString:@"CIGaussianBlur"])
		[(CIGaussianBlur *)filter setInputRadius:@(CIGaussianBlur_inputRadius)];
	else if ([filterName isEqualToString:@"CIPinchDistortion"])
		[(CIPinchDistortion *)filter setInputScale:@(CIPinchDistortion_inputScale)];
	else if ([filterName isEqualToString:@"CIPosterize"])
		[(CIPosterize *)filter setInputLevels:@(CIPosterize_inputLevels)];
	else if ([filterName isEqualToString:@"CISepiaTone"])
		[(CISepiaTone *)filter setInputIntensity:@(CISepiaTone_inputIntensity)];
	else if ([filterName isEqualToString:@"CIVibrance"])
		[(CIVibrance *)filter setInputAmount:@(CIVibrance_inputAmount)];
	else if ([filterName isEqualToString:@"CISharpenLuminance"])
		[(CISharpenLuminance *)filter setInputSharpness:@(CISharpenLuminance_inputSharpness)];
	else if ([filterName isEqualToString:@"CIColorMonochrome"]) {
		[(CIColorMonochrome *)filter setInputIntensity:@(CIColorMonochrome_inputIntensity)];
		CIColor *color = [CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B];
		[(CIColorMonochrome *)filter setInputColor:color];
	}
	else if ([filterName isEqualToString:@"CIFalseColor"]) {
		CIColor *color0 = [CIColor colorWithRed:CIFalseColor_R1 green:CIFalseColor_G1 blue:CIFalseColor_B1];
		CIColor *color1 = [CIColor colorWithRed:CIFalseColor_R2 green:CIFalseColor_G2 blue:CIFalseColor_B2];
		[(CIFalseColor *)filter setInputColor0:color0];
		[(CIFalseColor *)filter setInputColor1:color1];
	}
	[manager _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter];
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
			addCIEffect(@"CIThermal");
		}
	}
	return manager;
}

%end

static void EPLoader()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
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
	readFloat(CIPosterize_inputLevels, 6);
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
	system("killall Camera");
	EPLoader();
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	EPLoader();
	%init;
	[pool drain];
}
