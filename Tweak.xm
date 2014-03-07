#import <CoreImage/CIFilter.h>
#import <ImageIO/ImageIO.h>

@interface _UIBackdropView : UIView
@end

@interface CIFilter (Addition)
@property(retain) CIImage *inputImage;
- (NSDictionary *)_outputProperties;
@end

@interface CIBloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGaussianBlur : CIFilter
@property(copy) NSNumber *inputRadius;
@end

@interface CIStretch : CIFilter
@property(copy) CIVector *inputPoint;
@property(copy) CIVector *inputSize;
@end

@interface CITwirlDistortion : CIFilter
@property(retain) CIVector *inputCenter;
@property(retain) NSNumber *inputRadius;
@property(retain) NSNumber *inputAngle;
@end

@interface CIPinchDistortion : CIFilter
@property(retain) CIVector *inputCenter;
@property(retain) NSNumber *inputRadius;
@end

@interface CIMirror : CIFilter
@property(retain, nonatomic) NSNumber *inputAngle;
@property(copy) CIVector *inputPoint;
@end

@interface CITriangleKaleidoscope : CIFilter
@property(copy) NSNumber *inputDecay;
@property(copy) NSNumber *inputSize;
@property(retain, nonatomic) NSNumber *inputAngle;
@property(copy) CIVector *inputPoint;
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

@interface PLImageAdjustmentView
- (void)setEditedImage:(UIImage *)image;
@end

@interface CAMBottomBar : UIToolbar
@end

@interface PLCameraView
@property(readonly, assign, nonatomic) CAMBottomBar* _bottomBar;
@end

static NSString *identifierFix;
static BOOL internalBlurHook = NO;
static BOOL globalFilterHook = NO;

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
	return 6;
}

// Return the exact filters count to reduce the CPU processing for filters
- (unsigned)_cellCount
{
	return 28;
}

// No more internal hook after its -[PLCIFilterUtilities outputImageFromFilters:inputImage:orientation:copyFiltersFirst:] call
- (void)_renderGridFilters:(id)filters withInputImage:(id)inputImage ciContext:(id)context mirrorRendering:(BOOL)rendering
{
	%orig;
	internalBlurHook = NO;
	globalFilterHook = NO;
}

/*- (void)_updatePixelBufferPoolForSize:(CGSize)size
{
	%orig(CGSizeMake(size.width*0.6, size.height*0.6));
}

- (CVBufferRef)_createPixelBufferForSize:(CGSize)size
{
	return %orig(CGSizeMake(size.width*0.6, size.height*0.6));
}*/

/*- (CGRect)rectForFilterIndex:(unsigned)index
{
	CGRect orig = %orig;
	//NSLog(@"%@", NSStringFromCGRect(orig));
	return orig;
}*/

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
	if ([filterName isEqualToString:@"CIMirror"]) {
		[(CIMirror *)filter setInputPoint:normalHalfExtent];
		if (orientation != 1)
			[(CIMirror *)filter setInputAngle:@(1.5*M_PI)];
	}
	else if ([filterName isEqualToString:@"CITriangleKaleidoscope"]) {
		[(CITriangleKaleidoscope *)filter setInputPoint:normalHalfExtent];
		[(CITriangleKaleidoscope *)filter setInputSize:@(extent.size.width/2)];
	}
	else if ([filterName isEqualToString:@"CIStretch"]) {
		[(CIStretch *)filter setInputPoint:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
	}
	else if ([filterName isEqualToString:@"CIPinchDistortion"]) {
		[(CITwirlDistortion *)filter setInputRadius:@(extent.size.width/3.5)];
		[(CIPinchDistortion *)filter setInputCenter:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
	}
	else if ([filterName isEqualToString:@"CITwirlDistortion"]) {
	%log;
		[(CITwirlDistortion *)filter setInputRadius:@(extent.size.width/3)];
		[(CITwirlDistortion *)filter setInputCenter:(orientation == 1 || orientation == 5 || orientation == 6) ? normalHalfExtent : invertHalfExtent];
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
	if ([filter.name isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputRadius:@32];
	else if ([filter.name isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputRadius:@32];
	else if ([filter.name isEqualToString:@"CITwirlDistortion"])
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI/2)];
	[manager _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter];
}

%hook PLEffectFilterManager

- (PLEffectFilterManager *)init
{
	PLEffectFilterManager *manager = %orig;
	if (manager != nil) {
		#define addCIEffect(arg1, arg2) _addCIEffect(arg1, arg2, manager)
		addCIEffect(@"Sepia", @"CISepiaTone");
		addCIEffect(@"Vibrance", @"CIVibrance");
		addCIEffect(@"Invert", @"CIColorInvert");
		addCIEffect(@"MonoC", @"CIColorMonochrome");
		addCIEffect(@"Posterize", @"CIColorPosterize");
		addCIEffect(@"Gloom", @"CIGloom");
		addCIEffect(@"Bloom", @"CIBloom");
		addCIEffect(@"Sharp", @"CISharpenLuminance");
		addCIEffect(@"SRGB", @"CILinearToSRGBToneCurve");
		addCIEffect(@"Pixel", @"CIPixellate");
		addCIEffect(@"Blur", @"CIGaussianBlur");
		addCIEffect(@"False", @"CIFalseColor");
		addCIEffect(@"Twirl", @"CITwirlDistortion");
		addCIEffect(@"Mirrors", @"CIWrapMirror");
		addCIEffect(@"Stretch", @"CIStretch");
		addCIEffect(@"Mirror", @"CIMirror");
		addCIEffect(@"Triangle", @"CITriangleKaleidoscope");
		addCIEffect(@"Squeeze", @"CIPinchDistortion");
		addCIEffect(@"Thermal", @"CIThermal");
	}
	return manager;
}

%end

%ctor
{
	%init;
}
