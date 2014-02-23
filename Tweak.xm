#import <CoreImage/CIFilter.h>

@interface _UIBackdropView : UIView
@end

@interface CIBloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface CIGloom : CIFilter
@property(retain, nonatomic) NSNumber *inputRadius;
@end

@interface PBFilter : CIFilter
+ (PBFilter *)filterWithName:(NSString *)name;
- (CIFilter *)ciFilter;
- (void)applyParametersToCIFilter:(CIFilter *)ciFilter extent:(CGRect)extent;
@end

@interface PLEffectFilterManager
+ (id)sharedInstance;
- (id)aggdNameForFilter:(id)filter;
- (id)displayNameForFilter:(id)filter;
- (id)displayNameForIndex:(unsigned)index;
- (unsigned)_indexForFilter:(id)filter;
- (void)_addEffectNamed:(NSString *)named aggdName:(NSString *)name filter:(CIFilter *)filter;
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

@interface CIFilter (LEPAddition)
- (NSDictionary *)_outputProperties;
@end

static NSString *identifierFix;

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

- (int)_cellsPerRow
{
	return 6;
}

/*- (void)_updatePixelBufferPoolForSize:(CGSize)size
{
	%orig(CGSizeMake(21, 16));
}*/

/*- (CVBufferRef)_createPixelBufferForSize:(CGSize)size
{
	//NSLog(@"%@", NSStringFromCGSize(size));
	return %orig(CGSizeMake(21, 16));
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

/*%hook PLCIFilterUtilities

+ (CIImage *)outputImageFromFilters:(NSArray *)filters inputImage:(CIImage *)image orientation:(int)orientation copyFiltersFirst:(BOOL)copyFirst
{
	if ([((CIFilter *)[filters objectAtIndex:0]).name isEqualToString:@"CITwirlDistortion"]) {
		CIImage *outputImage = %orig;
		//MSHookIvar<CGRect>(outputImage, "_priv") = CGRectMake(0, 0, 640, 852);
		NSLog(@"%@", NSStringFromCGRect([outputImage extent]));
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			MSHookIvar<CGRect>(outputImage, "_priv") = defaultRect;
		});
		return outputImage;
	}
	return %orig;
}

%end*/

/*%hook CIContext

- (void)drawImage:(CIImage)image inRect:(CGRect)rect fromRect:(CGRect)rect2
{
	NSLog(@"An image: %@\ninRect: %@\nfromRect: %@", image, NSStringFromCGRect(rect), NSStringFromCGRect(rect2));
	%orig;
}

%end*/

%hook PLEffectFilterManager

- (id)init
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		// Do not add these extra filters again if they are added already (filters count > 0)
		if ([self filterCount] == 0) {
			NSDictionary *filters = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Sepia", @"CISepiaTone",
				@"Vignette", @"CIVignette",
				@"VE", @"CIVignetteEffect",
				@"Vibrance", @"CIVibrance",
				@"Invert", @"CIColorInvert",
				@"MC", @"CIColorMonochrome",
				@"Posterize", @"CIColorPosterize",
				@"Gloom", @"CIGloom",
				@"Bloom", @"CIBloom",
				@"Sharp", @"CISharpenLuminance",
				@"Pixel", @"CIPixellate",
				@"SRGB", @"CILinearToSRGBToneCurve",
				@"G-Blur", @"CIGaussianBlur",
				@"False", @"CIFalseColor",
				@"TempTint", @"CITemperatureAndTint",
				@"ToneCurve", @"CIToneCurve",
				//@"Triangle", @"PBKaleidoscopeFilter",
				@"Twirl", @"PBTwirlFilter",
				@"Mirror", @"PBMirrorFilter",
				@"Squeeze", @"PBSqueezeFilter",
				@"Stretch", @"PBStretchFilter",
				nil];
			NSArray *keys = [filters allKeys];
			NSArray *values = [filters allValues];
			NSUInteger count = [keys count];
			for (int i = 0; i < count; i++) {
				NSString *filterName = [keys objectAtIndex:i];
				NSString *displayName = [values objectAtIndex:i];
				if ([filterName hasPrefix:@"PB"]) {
					PBFilter *filter = [PBFilter filterWithName:filterName];
					CIFilter *filter2 = [filter ciFilter];
					[filter applyParametersToCIFilter:filter2 extent:[UIScreen mainScreen].bounds];
					[self _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter2];
				} else {
					CIFilter *filter = [CIFilter filterWithName:filterName];
					if ([filter.name isEqualToString:@"CIGloom"])
						[(CIGloom *)filter setInputRadius:@5];
					if ([filter.name isEqualToString:@"CIBloom"])
						[(CIBloom *)filter setInputRadius:@5];
					[self _addEffectNamed:displayName aggdName:[displayName lowercaseString] filter:filter]; }
			}
		}
	});
	return %orig;
}

%end

%ctor
{
	%init;
}
