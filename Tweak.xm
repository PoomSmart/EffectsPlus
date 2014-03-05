#import <CoreImage/CIFilter.h>

@interface _UIBackdropView : UIView
@end

@interface CIBloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGaussianBlur : CIFilter
@property(retain) CIImage *inputImage;
@property(copy) NSNumber *inputRadius;
@end

@interface CIStretch : CIFilter
@property(retain) CIImage *inputImage;
@end

@interface CITwirlDistortion : CIFilter
@property(retain) CIImage *inputImage;
@property(retain) CIVector *inputCenter;
@property(retain) NSNumber *inputRadius;
@end

@interface CIMirror : CIFilter
@property(retain) CIImage *inputImage;
@property(retain, nonatomic) NSNumber *inputAngle;
@property(copy) CIVector *inputPoint;
@end

@interface CITriangleKaleidoscope : CIFilter
@property(retain) CIImage *inputImage;
@property(retain, nonatomic) NSNumber *inputAngle;
@property(copy) CIVector *inputPoint;
@end

@interface PBFilter : CIFilter
+ (PBFilter *)filterWithName:(NSString *)name;
- (CIFilter *)ciFilter;
- (void)applyParametersToCIFilter:(CIFilter *)ciFilter extent:(CGRect)extent;
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

@interface PLEffectFilterManager (EffectsPlusAddition)
- (void)EffectsPlus_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;
@end

@interface PLImageAdjustmentView
- (void)setEditedImage:(UIImage *)image;
@end

@interface CAMBottomBar : UIToolbar
@end

@interface PLCameraView
@property(readonly, assign, nonatomic) CAMBottomBar* _bottomBar;
@end

@interface CIFilter (LEPAddition)
- (NSDictionary *)_outputProperties;
@end

static NSString *identifierFix;
static BOOL internalBlurHook = NO;

%hook PLManagedAsset

// Workaround for bypassing the filter identifier checking
- (id)_serializedPropertyDataFromFilter:(CIFilter *)filter
{
	return [filter _outputProperties];
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

%hook CIGaussianBlur

- (CIImage *)outputImage
{
	CIImage *output = %orig;
	CGRect rect = self.inputImage.extent;
	/*double blur = [self.inputRadius doubleValue];
	rect.origin.x += blur;
	rect.origin.y += blur;
	rect.size.height -= blur*2.0f;
	rect.size.width -= blur*2.0f;*/
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:output fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

%hook CIStretch

- (CIImage *)outputImage
{
	CIImage *output = %orig;
	CGRect rect = self.inputImage.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:output fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

%hook CIMirror

- (CIImage *)outputImage
{
	CIImage *output = %orig;
	CGRect rect = self.inputImage.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:output fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

%hook CITriangleKaleidoscope

- (CIImage *)outputImage
{
	CIImage *output = %orig;
	CGRect rect = self.inputImage.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:output fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

%hook CITwirlDistortion

- (CIImage *)outputImage
{
	CIImage *output = %orig;
	CGRect rect = self.inputImage.extent;
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:output fromRect:rect];
	CIImage *outputImage = [CIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return outputImage;
}

%end

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
	self._bottomBar.hidden = showEffectsGrid;
}

%end

%hook PLEffectsGridView

- (unsigned)_cellsPerRow
{
	return 6;
}

/*- (unsigned)_cellCount
{
	return 27;
}*/

- (void)_renderGridFilters:(id)filters withInputImage:(id)inputImage ciContext:(id)context mirrorRendering:(BOOL)rendering
{
	%orig;
	internalBlurHook = NO;
}

/*- (void)_updatePixelBufferPoolForSize:(CGSize)size
{
	%orig(CGSizeMake(size.width*0.8, size.height*0.8));
}

- (CVBufferRef)_createPixelBufferForSize:(CGSize)size
{
	return %orig(CGSizeMake(size.width*0.8, size.height*0.8));
}*/

/*- (CGRect)rectForFilterIndex:(unsigned)index
{
	CGRect orig = %orig;
	//NSLog(@"%@", NSStringFromCGRect(orig));
	return orig;
}*/

%end

%hook PLEffectsGridLabelsView

- (id)initWithFrame:(CGRect)frame
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[MSHookIvar<_UIBackdropView *>(self, "__backdropView") removeFromSuperview];
		[MSHookIvar<_UIBackdropView *>(self, "__backdropView") release];
		MSHookIvar<_UIBackdropView *>(self, "__backdropView") = nil;
	});
	return %orig;
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

+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)image orientation:(int)orientation copyFiltersFirst:(BOOL)copyFirst
{
	NSString *filterName = ((CIFilter *)[filters objectAtIndex:0]).name;
	if ([filterName isEqualToString:@"CIBloom"] || [filterName isEqualToString:@"CIGloom"])
		internalBlurHook = YES;
	return %orig;
}

%end

%hook PLEffectsFullSizeView

- (void)_renderWithInputImage:(id)inputImage ciContext:(id)context mirrorRendering:(BOOL)rendering
{
	%orig;
	internalBlurHook = NO;
}

%end

/*%hook CIContext

- (void)drawImage:(CIImage *)image inRect:(CGRect)rect fromRect:(CGRect)rect2
{
//MSHookIvar<struct CGRect>(image, "_priv") = CGRectMake(0, 0, 107, 142);
if (llog)
	NSLog(@"An image: %@\ninRect: %@\nfromRect: %@", image, NSStringFromCGRect(rect), NSStringFromCGRect(rect2));
	%orig;
}

%end*/

%hook PLEffectFilterManager

%new
- (void)EffectsPlus_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter
{
	NSMutableArray *effects = MSHookIvar<NSMutableArray *>(self, "_effects");
	if (![effects containsObject:filter])
		[self _addEffectNamed:name aggdName:aggdName filter:filter];
}

- (PLEffectFilterManager *)init
{
	PLEffectFilterManager *manager = %orig;
	if (manager != nil) {
		NSDictionary *filters = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Sepia", @"CISepiaTone",
			@"Vibrance", @"CIVibrance",
			@"Invert", @"CIColorInvert",
			@"MC", @"CIColorMonochrome",
			@"Posterize", @"CIColorPosterize",
			@"Gloom", @"CIGloom",
			@"Bloom", @"CIBloom",
			@"Sharp", @"CISharpenLuminance",
			@"Pixel", @"CIPixellate",
			@"SRGB", @"CILinearToSRGBToneCurve",
			@"Blur", @"CIGaussianBlur",
			@"False", @"CIFalseColor",
			@"Triangle", @"PBKaleidoscopeFilter",
			@"Twirl", @"CITwirlDistortion",
			@"WMirror", @"CIWrapMirror",
			@"Mirror", @"PBMirrorFilter",
			@"Squeeze", @"PBSqueezeFilter",
			@"Stretch", @"CIStretch",
			nil];
		NSArray *keys = [filters allKeys];
		NSArray *values = [filters allValues];
		NSUInteger count = [keys count];
		for (unsigned int i = 0; i < count; i++) {
			NSString *filterName = [keys objectAtIndex:i];
			NSString *displayName = [values objectAtIndex:i];
			if ([filterName hasPrefix:@"PB"]) {
				PBFilter *filter = [PBFilter filterWithName:filterName];
				CIFilter *filter2 = [filter ciFilter];
				[filter applyParametersToCIFilter:filter2 extent:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
				if ([filter2.name isEqualToString:@"CIMirror"])
					[(CIMirror *)filter2 setInputPoint:[CIVector vectorWithX:[UIScreen mainScreen].bounds.size.height Y:[UIScreen mainScreen].bounds.size.width]];
				[manager EffectsPlus_addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter2];
			} else {
				CIFilter *filter = [CIFilter filterWithName:filterName];
				if ([filter.name isEqualToString:@"CIGloom"])
					[(CIGloom *)filter setInputRadius:@15];
				else if ([filter.name isEqualToString:@"CIBloom"])
					[(CIBloom *)filter setInputRadius:@15];
				else if ([filter.name isEqualToString:@"CITwirlDistortion"]) {
					[(CITwirlDistortion *)filter setInputCenter:[CIVector vectorWithX:[UIScreen mainScreen].bounds.size.height Y:[UIScreen mainScreen].bounds.size.width]];
					[(CITwirlDistortion *)filter setInputRadius:@200];
				}
				[manager EffectsPlus_addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter];
			}
		}
	}
	return manager;
}

%end

%ctor
{
	%init;
}
